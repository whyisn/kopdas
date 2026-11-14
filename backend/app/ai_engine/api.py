"""
Pintu masuk ai_engine untuk backend (task 0-09).

    from ai_engine.api import recommend
    rec = recommend("2026-11-14", n_sellers=3)          # pakai data CSV simulasi
    rec = recommend("2026-11-14", sales_df=df_dari_db)  # nanti (task 1-06): data dari DB
    rec = recommend("2026-11-14", sellers=[...])        # + penugasan pegawai otomatis

Output mengikuti docs/api-contract.md -> objek "Recommendation" (tanpa id/created_at,
yang diisi backend saat menyimpan).
"""
import os
import sys
import time

import pandas as pd

HERE = os.path.dirname(os.path.abspath(__file__))
if HERE not in sys.path:
    sys.path.insert(0, HERE)

from engine import (CATEGORIES, Config, DemandForecaster, optimize_allocation,  # noqa: E402
                    to_category_level)
from postprocess import assign_sellers, product_shares, split_cups  # noqa: E402

MODEL_VERSION = "hgb-poisson-em+milp-0.2"

# pemetaan nama di dataset simulasi -> ID stabil di kontrak
LOCATION_IDS = {
    "Kampus UNP Air Tawar": "loc-kampus-unp",
    "Perkantoran Khatib Sulaiman": "loc-khatib-sulaiman",
    "Pasar Raya Padang": "loc-pasar-raya",
    "Pantai Padang (Taplau)": "loc-taplau",
}
CATEGORY_IDS = {"Coffee": "cat-coffee", "Non-Coffee": "cat-noncoffee", "Tea": "cat-tea"}
PRODUCT_IDS = {
    "Kopi Susu Aren": "prod-kopi-susu-aren", "Americano": "prod-americano",
    "Coklat": "prod-coklat", "Red Velvet": "prod-red-velvet",
    "Thai Tea": "prod-thai-tea", "Lemon Tea": "prod-lemon-tea",
}


def _load(data_dir):
    weather = pd.read_csv(os.path.join(data_dir, "weather.csv"))
    daily = pd.read_csv(os.path.join(data_dir, "daily_sales.csv"))
    loc_df = pd.read_csv(os.path.join(data_dir, "locations.csv"))
    coords = {LOCATION_IDS.get(r.lokasi, r.lokasi): (r.lat, r.lon) for r in loc_df.itertuples()}
    return weather, daily, loc_df["lokasi"].tolist(), coords


def _fallback_plan(fc, cfg):
    """Rumus transparan bila solver gagal: 3 lokasi dengan forecast tertinggi, stok = ceil(forecast x 1,1)."""
    import math
    tot = fc.groupby("lokasi")["forecast"].sum().sort_values(ascending=False)
    chosen = set(tot.index[: cfg.n_vendors])
    rows = []
    for r in fc.itertuples():
        q = int(math.ceil(round(r.forecast * 1.1, 6))) if r.lokasi in chosen else 0
        rows.append({"lokasi": r.lokasi, "kategori": r.kategori, "buka": r.lokasi in chosen,
                     "stok_rekomendasi": q, "forecast": round(float(r.forecast), 1),
                     "confidence": r.confidence, "n_histori": int(r.n_histori)})
    return pd.DataFrame(rows)


def recommend(target_date, n_sellers=3, sales_df=None, weather_df=None,
              data_dir=os.path.join(HERE, "data"), cfg=None, sellers=None):
    """sellers (opsional): [{"seller_id","name","last_location_id","days_at":{location_id: hari}}].
    Jika diberikan, n_sellers = jumlah pegawai dan setiap lokasi BUKA mendapat assigned_seller."""
    t0 = time.time()
    weather, daily, locs, coords = _load(data_dir)
    if sellers:
        n_sellers = len(sellers)
    if sales_df is not None:
        daily = sales_df
    if weather_df is not None:
        weather = weather_df
    if target_date not in set(weather["tanggal"]):
        # belum ada prakiraan untuk tanggal itu: pakai cuaca hari yang sama minggu lalu (berlabel)
        last = weather.iloc[-7 + (pd.Timestamp(target_date).dayofweek - pd.Timestamp(weather.iloc[-7]["tanggal"]).dayofweek) % 7]
        weather = pd.concat([weather, pd.DataFrame([{**last.to_dict(), "tanggal": target_date}])])
        weather_note = "prakiraan cuaca belum tersedia; memakai cuaca hari yang sama minggu lalu"
    else:
        weather_note = None

    cfg = cfg or Config(n_vendors=n_sellers)
    history = daily[daily["tanggal"] < target_date]
    cat_daily = to_category_level(history)
    shares = product_shares(history)
    model = DemandForecaster(locs).fit(cat_daily, weather)
    fc = model.predict(target_date, weather)

    try:
        plan = optimize_allocation(fc, cfg)
        solver_status = "optimal"
    except Exception as e:  # noqa: BLE001
        plan = _fallback_plan(fc, cfg)
        solver_status = f"fallback ({e})"

    w = fc.iloc[0]
    cond = ("hujan" if w["hujan"] else "cerah") + (", akhir pekan" if w["weekend"] else ", hari kerja")
    out_plan = []
    for loc, g in plan.groupby("lokasi", sort=False):
        total = float(g["forecast"].sum())
        n_hist = int(g["n_histori"].min())
        if n_hist < cfg.min_history_days:
            decision = "UJI_COBA"
            reason = f"Histori kondisi serupa hanya {n_hist} hari; perkiraan {total:.0f} cup belum bisa dipercaya."
        elif bool(g["buka"].iloc[0]):
            decision = "BUKA"
            reason = f"Perkiraan {total:.0f} cup ({cond}); laba harapan termasuk tertinggi."
        else:
            decision = "LEWATI"
            reason = f"Perkiraan hanya {total:.0f} cup ({cond}); laba harapan kalah dari lokasi lain."
        out_plan.append({
            "location_id": LOCATION_IDS.get(loc, loc),
            "location_name": loc,
            "decision": decision,
            "forecast_total": round(total, 1),
            "confidence": g["confidence"].iloc[0],
            "history_days": n_hist,
            "items": [{"category_id": CATEGORY_IDS[r.kategori], "forecast": r.forecast,
                       "stock": int(r.stok_rekomendasi),
                       "products": [{"product_id": PRODUCT_IDS.get(p, p), "qty": q}
                                    for p, q in sorted(split_cups(int(r.stok_rekomendasi),
                                                                  shares.get((loc, r.kategori), shares[(None, r.kategori)])).items(),
                                                       key=lambda kv: -kv[1])]}
                      for r in g.itertuples()],
            "reason": reason,
            "assigned_seller": None,
        })
    order = {"BUKA": 0, "UJI_COBA": 1, "LEWATI": 2}
    out_plan.sort(key=lambda p: (order[p["decision"]], -p["forecast_total"]))

    if sellers:
        opened = [p["location_id"] for p in out_plan if p["decision"] == "BUKA"]
        assigned = assign_sellers(opened, sellers, coords)
        for p in out_plan:
            p["assigned_seller"] = assigned.get(p["location_id"])

    return {
        "target_date": target_date,
        "model_version": MODEL_VERSION,
        "data_label": "SIMULASI",
        "solver_status": solver_status,
        "conditions": {"rain": bool(w["hujan"]), "weekend": bool(w["weekend"]),
                       "holiday": bool(w["libur"]), "note": weather_note},
        "constraints": {"n_sellers": cfg.n_vendors, "cart_capacity": cfg.cart_capacity,
                        "central_capacity": {CATEGORY_IDS[k]: v for k, v in cfg.central_capacity.items()}},
        "plan": out_plan,
        "runtime_ms": int((time.time() - t0) * 1000),
    }


if __name__ == "__main__":
    import json
    demo_sellers = [
        {"seller_id": "usr-seller-a", "name": "Pegawai A", "last_location_id": "loc-pasar-raya",
         "days_at": {"loc-pasar-raya": 20, "loc-taplau": 3}},
        {"seller_id": "usr-seller-b", "name": "Pegawai B", "last_location_id": "loc-kampus-unp",
         "days_at": {"loc-kampus-unp": 18, "loc-khatib-sulaiman": 2}},
        {"seller_id": "usr-seller-c", "name": "Pegawai C", "last_location_id": "loc-khatib-sulaiman",
         "days_at": {"loc-khatib-sulaiman": 15, "loc-taplau": 6}},
    ]
    print(json.dumps(recommend(sys.argv[1] if len(sys.argv) > 1 else "2026-11-01", sellers=demo_sellers),
                     indent=2, ensure_ascii=False))
