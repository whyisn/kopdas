"""
KopiCerdas AI - mesin rekomendasi.

1) Forecast permintaan per lokasi x kategori x tanggal
   - Model: HistGradientBoostingRegressor (loss Poisson) dengan fitur hari, akhir pekan,
     lokasi, kategori, hujan, curah hujan, suhu, hari libur.
   - Koreksi sensor sederhana: hari stockout -> penjualan dianggap batas bawah permintaan
     (dinaikkan STOCKOUT_UPLIFT).
   - Confidence dari jumlah histori lokasi x (hari kerja/akhir pekan).

2) Optimasi alokasi (MILP, scipy.optimize.milp / HiGHS)
   Keputusan: lokasi mana yang dibuka (maks. N pegawai) & berapa cup per kategori.
   Tujuan: maksimalkan ekspektasi laba
       sum  harga * E[min(D, q)] - HPP * q  - biaya_operasional_lokasi
   E[min(D,q)] dilinierkan per cup: cup ke-k laku dengan peluang P(D >= k).
   Kendala: kapasitas gerobak, kapasitas produksi pusat per kategori, jumlah pegawai.
"""
from dataclasses import dataclass, field

import numpy as np
import pandas as pd
from scipy.optimize import Bounds, LinearConstraint, milp
from scipy.stats import norm
from sklearn.ensemble import HistGradientBoostingRegressor

CATEGORIES = ["Coffee", "Non-Coffee", "Tea"]
PRICE = {"Coffee": 12000, "Non-Coffee": 12000, "Tea": 8000}
HPP = {"Coffee": 4825, "Non-Coffee": 5500, "Tea": 3000}  # rata-rata tertimbang porsi produk
STOCKOUT_UPLIFT = 1.15
FEATURES = ["lok", "kat", "dow", "weekend", "hujan", "curah_hujan_mm", "suhu_c", "libur"]


@dataclass
class Config:
    n_vendors: int = 3                 # jumlah pegawai/gerobak
    cart_capacity: int = 90            # cup maksimum per gerobak
    central_capacity: dict = field(default_factory=lambda: {"Coffee": 110, "Non-Coffee": 70, "Tea": 65})
    location_cost: int = 25000         # bensin/parkir/retribusi per lokasi per hari
    max_cups_per_cell: int = 90        # batas K untuk linearisasi
    min_history_days: int = 3          # < ini: lokasi tidak dibuka otomatis, jadi kandidat uji coba


def to_category_level(daily: pd.DataFrame) -> pd.DataFrame:
    g = (daily.groupby(["tanggal", "lokasi", "kategori"])
              .agg(terjual=("terjual", "sum"), stockout=("stockout", "max"))
              .reset_index())
    return g


def add_features(df: pd.DataFrame, weather: pd.DataFrame, loc_index: dict) -> pd.DataFrame:
    df = df.merge(weather, on="tanggal", how="left")
    t = pd.to_datetime(df["tanggal"])
    df["dow"] = t.dt.dayofweek
    df["weekend"] = (df["dow"] >= 5).astype(int)
    df["lok"] = df["lokasi"].map(loc_index)
    df["kat"] = df["kategori"].map({c: i for i, c in enumerate(CATEGORIES)})
    return df


class DemandForecaster:
    def __init__(self, locations):
        self.locations = list(locations)
        self.loc_index = {l: i for i, l in enumerate(self.locations)}
        self.model = HistGradientBoostingRegressor(
            loss="poisson", max_iter=150, learning_rate=0.05, max_leaf_nodes=8,
            min_samples_leaf=15, l2_regularization=1.0,
            categorical_features=[0, 1], random_state=0)
        self.phi = 1.5  # dispersi (Var = phi * mean), diestimasi saat fit
        self.history_counts = {}

    def fit(self, cat_daily: pd.DataFrame, weather: pd.DataFrame, em_iters: int = 4):
        """Fit dengan koreksi data tersensor (EM sederhana).
        Saat stok habis, permintaan asli >= penjualan. Target pada baris stockout diganti
        dengan E[D | D >= terjual] dari distribusi normal(mu, sd) model saat ini, lalu model
        dilatih ulang. Diulang beberapa kali."""
        df = add_features(cat_daily, weather, self.loc_index)
        sold = df["terjual"].to_numpy(float)
        cens = df["stockout"].to_numpy() == 1
        y = np.where(cens, sold * STOCKOUT_UPLIFT, sold)
        for _ in range(em_iters):
            self.model.fit(df[FEATURES], y)
            mu = self.model.predict(df[FEATURES])
            unc = ~cens
            self.phi = float(np.clip(np.mean((sold[unc] - mu[unc]) ** 2 / np.maximum(mu[unc], 1)), 1.0, 5.0))
            sd = np.sqrt(self.phi * np.maximum(mu, 1))
            a = (sold - mu) / sd
            tail_mean = mu + sd * norm.pdf(a) / np.maximum(norm.sf(a), 1e-6)
            y = np.where(cens, np.maximum(sold, tail_mean), sold)
        days = df.drop_duplicates(["tanggal", "lokasi"])
        self.history_counts = days.groupby(["lokasi", "weekend"]).size().to_dict()
        return self

    def predict(self, date: str, weather: pd.DataFrame) -> pd.DataFrame:
        grid = pd.DataFrame([{"tanggal": date, "lokasi": l, "kategori": c}
                             for l in self.locations for c in CATEGORIES])
        df = add_features(grid, weather, self.loc_index)
        df["forecast"] = self.model.predict(df[FEATURES])
        df["sd"] = np.sqrt(self.phi * np.maximum(df["forecast"], 1))
        n = df.apply(lambda r: self.history_counts.get((r["lokasi"], r["weekend"]), 0), axis=1)
        df["n_histori"] = n
        df["confidence"] = np.select([n >= 20, n >= 6], ["tinggi", "sedang"], "rendah")
        return df[["tanggal", "lokasi", "kategori", "forecast", "sd", "n_histori", "confidence",
                   "hujan", "libur", "weekend"]]


def optimize_allocation(fc: pd.DataFrame, cfg: Config) -> pd.DataFrame:
    """MILP: pilih lokasi & jumlah cup per kategori. Mengembalikan rencana per lokasi x kategori."""
    locs = list(dict.fromkeys(fc["lokasi"]))
    L, C, K = len(locs), len(CATEGORIES), cfg.max_cups_per_cell
    n_y = L
    n_z = L * C * K
    n = n_y + n_z

    def zi(l, c, k):  # indeks variabel z
        return n_y + (l * C + c) * K + k

    obj = np.zeros(n)
    obj[:n_y] = cfg.location_cost
    for l, loc in enumerate(locs):
        for c, cat in enumerate(CATEGORIES):
            r = fc[(fc.lokasi == loc) & (fc.kategori == cat)].iloc[0]
            k = np.arange(1, K + 1)
            p_sell = 1 - norm.cdf(k - 0.5, loc=r["forecast"], scale=r["sd"])  # P(D >= k)
            # milp meminimalkan -> pakai negatif laba marginal
            for kk in range(K):
                obj[zi(l, c, kk)] = -(PRICE[cat] * p_sell[kk] - HPP[cat])

    rows, lb, ub = [], [], []
    # kapasitas gerobak & hanya jika lokasi dibuka: sum z - cap*y <= 0
    for l in range(L):
        a = np.zeros(n)
        a[l] = -cfg.cart_capacity
        for c in range(C):
            for kk in range(K):
                a[zi(l, c, kk)] = 1
        rows.append(a); lb.append(-np.inf); ub.append(0)
    # jumlah pegawai
    a = np.zeros(n); a[:n_y] = 1
    rows.append(a); lb.append(0); ub.append(cfg.n_vendors)
    # kapasitas produksi pusat per kategori
    for c, cat in enumerate(CATEGORIES):
        a = np.zeros(n)
        for l in range(L):
            for kk in range(K):
                a[zi(l, c, kk)] = 1
        rows.append(a); lb.append(0); ub.append(cfg.central_capacity[cat])

    # lokasi tanpa histori memadai pada kondisi serupa tidak dibuka otomatis
    # (forecast-nya ekstrapolasi -> risiko tinggi). Ditandai sebagai kandidat uji coba.
    y_ub = np.ones(n)
    for l, loc in enumerate(locs):
        if fc.loc[fc.lokasi == loc, "n_histori"].min() < cfg.min_history_days:
            y_ub[l] = 0

    integrality = np.zeros(n); integrality[:n_y] = 1
    res = milp(obj, constraints=LinearConstraint(np.array(rows), lb, ub),
               integrality=integrality, bounds=Bounds(0, y_ub))
    if not res.success:
        raise RuntimeError(res.message)

    x = res.x
    out = []
    for l, loc in enumerate(locs):
        open_ = x[l] > 0.5
        for c, cat in enumerate(CATEGORIES):
            q = int(round(sum(x[zi(l, c, kk)] for kk in range(K)))) if open_ else 0
            r = fc[(fc.lokasi == loc) & (fc.kategori == cat)].iloc[0]
            out.append({"lokasi": loc, "kategori": cat, "buka": bool(open_), "stok_rekomendasi": q,
                        "forecast": round(float(r["forecast"]), 1), "confidence": r["confidence"],
                        "n_histori": int(r["n_histori"])})
    return pd.DataFrame(out)


def explain(plan: pd.DataFrame, fc: pd.DataFrame) -> list:
    """Alasan berbasis data untuk tiap lokasi (bisa dikirim ke LLM untuk diparafrasekan)."""
    msgs = []
    w = fc.iloc[0]
    cond = ("hujan" if w["hujan"] else "cerah") + (", akhir pekan" if w["weekend"] else ", hari kerja") \
        + (", hari libur" if w["libur"] else "")
    for loc, g in plan.groupby("lokasi", sort=False):
        tot_fc = g["forecast"].sum()
        conf = g["confidence"].iloc[0]
        if g["n_histori"].min() < 3:
            msgs.append(f"UJI COBA? {loc}: histori kondisi serupa hanya {g['n_histori'].min()} hari; "
                        f"perkiraan {tot_fc:.0f} cup belum bisa dipercaya. Pertimbangkan uji coba stok kecil.")
        elif g["buka"].iloc[0]:
            mix = ", ".join(f"{r.kategori} {r.stok_rekomendasi}" for r in g.itertuples())
            msgs.append(f"BUKA {loc}: perkiraan {tot_fc:.0f} cup ({cond}); bawa {mix}. Confidence {conf}.")
        else:
            msgs.append(f"LEWATI {loc}: perkiraan hanya {tot_fc:.0f} cup ({cond}); laba harapan kalah dari lokasi lain. Confidence {conf}.")
    return msgs
