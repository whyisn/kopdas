"""
KopiCerdas AI - Generator dataset SIMULASI 12 minggu.

Semua angka di sini sintetis (is_simulated = 1). Pola sengaja ditanam agar
model forecast dan optimasi bisa diuji:
  - Kampus ramai hari kerja, sepi akhir pekan & hari libur nasional
  - Perkantoran hampir hanya hari kerja
  - Pasar stabil, naik di akhir pekan
  - Pantai (Taplau) ramai akhir pekan, sangat sensitif hujan
  - Hujan menurunkan Coffee dingin & Non-Coffee, menaikkan Tea hangat sedikit
  - Penjualan tercatat = min(permintaan, stok yang dibawa) -> ada stockout (data tersensor)

Pemakaian:
    python generate_data.py --weeks 12 --seed 42 --out data
Output:
    data/weather.csv        tanggal, hujan, curah_hujan_mm, suhu_c, libur
    data/daily_sales.csv    tanggal, lokasi, produk, kategori, stok_bawa, permintaan_asli, terjual, stockout
    data/transactions.csv   transaksi per cup (untuk seed database aplikasi)
    data/locations.csv      koordinat kandidat lokasi
    data/ground_truth_demand.csv  permintaan asli semua lokasi (khusus evaluasi)
"""
import argparse
import os

import numpy as np
import pandas as pd

LOCATIONS = {
    # nama: (lat, lon, dict faktor hari 0=Senin..6=Minggu)
    "Kampus UNP Air Tawar":        (-0.8960, 100.3500, [1.00, 1.05, 1.05, 1.00, 0.90, 0.35, 0.20]),
    "Perkantoran Khatib Sulaiman": (-0.9040, 100.3530, [1.00, 1.00, 1.00, 1.00, 0.95, 0.25, 0.10]),
    "Pasar Raya Padang":           (-0.9510, 100.3600, [0.85, 0.85, 0.90, 0.90, 1.00, 1.25, 1.20]),
    "Pantai Padang (Taplau)":      (-0.9450, 100.3540, [0.45, 0.45, 0.50, 0.50, 0.75, 1.45, 1.60]),
}

# permintaan dasar per kategori per lokasi (cup/hari, hari normal tidak hujan)
BASE = {
    "Kampus UNP Air Tawar":        {"Coffee": 42, "Non-Coffee": 24, "Tea": 20},
    "Perkantoran Khatib Sulaiman": {"Coffee": 38, "Non-Coffee": 14, "Tea": 12},
    "Pasar Raya Padang":           {"Coffee": 24, "Non-Coffee": 18, "Tea": 20},
    "Pantai Padang (Taplau)":      {"Coffee": 26, "Non-Coffee": 26, "Tea": 22},
}

PRODUCTS = {
    # produk: (kategori, harga, HPP, porsi dalam kategori)
    "Kopi Susu Aren": ("Coffee", 12000, 5000, 0.65),
    "Americano":      ("Coffee", 12000, 4500, 0.35),
    "Coklat":         ("Non-Coffee", 12000, 5500, 0.55),
    "Red Velvet":     ("Non-Coffee", 12000, 5500, 0.45),
    "Thai Tea":       ("Tea", 8000, 3000, 0.60),
    "Lemon Tea":      ("Tea", 8000, 3000, 0.40),
}

RAIN_EFFECT = {"Coffee": 0.80, "Non-Coffee": 0.75, "Tea": 1.05}
PANTAI_RAIN_EXTRA = 0.45  # pantai jauh lebih sepi saat hujan

# libur nasional dalam rentang contoh (Agustus-November 2026)
HOLIDAYS = {"2026-08-17"}

# lokasi yang dipakai owner selama periode histori (kebiasaan manual)
MANUAL_LOCATIONS = ["Kampus UNP Air Tawar", "Perkantoran Khatib Sulaiman", "Pasar Raya Padang"]


def make_weather(dates, rng):
    rows = []
    for d in dates:
        # Padang basah: peluang hujan ~40%
        rain = rng.random() < 0.40
        mm = float(np.round(rng.gamma(2.0, 6.0), 1)) if rain else 0.0
        temp = float(np.round(rng.normal(30.5 if not rain else 27.5, 1.0), 1))
        rows.append({
            "tanggal": d.date().isoformat(),
            "hujan": int(rain),
            "curah_hujan_mm": mm,
            "suhu_c": temp,
            "libur": int(d.date().isoformat() in HOLIDAYS),
            "is_simulated": 1,
        })
    return pd.DataFrame(rows)


def true_demand_mean(loc, cat, dow, rain, holiday, temp):
    mu = BASE[loc][cat] * LOCATIONS[loc][2][dow]
    if rain:
        mu *= RAIN_EFFECT[cat]
        if loc == "Pantai Padang (Taplau)":
            mu *= PANTAI_RAIN_EXTRA
    if holiday:
        mu *= 0.3 if loc in ("Kampus UNP Air Tawar", "Perkantoran Khatib Sulaiman") else 1.3
    if not rain and temp > 31 and cat != "Tea":
        mu *= 1.08  # hari panas -> minuman dingin naik
    return mu


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--weeks", type=int, default=12)
    ap.add_argument("--seed", type=int, default=42)
    ap.add_argument("--start", default="2026-08-10")  # Senin
    ap.add_argument("--out", default="data")
    args = ap.parse_args()

    rng = np.random.default_rng(args.seed)
    dates = pd.date_range(args.start, periods=args.weeks * 7, freq="D")
    weather = make_weather(dates, rng)

    daily_rows, tx_rows, gt_rows = [], [], []
    tx_id = 1
    for _, w in weather.iterrows():
        d = pd.Timestamp(w["tanggal"])
        dow = d.dayofweek
        for loc in LOCATIONS:
            # owner hanya berjualan di 3 lokasi tetap; Pantai tidak punya histori
            # kecuali sesekali uji coba akhir pekan (agar ada sedikit data)
            visited = loc in MANUAL_LOCATIONS or (dow >= 5 and rng.random() < 0.5)
            for prod, (cat, price, hpp, share) in PRODUCTS.items():
                mu = true_demand_mean(loc, cat, dow, w["hujan"], w["libur"], w["suhu_c"]) * share
                # negative binomial (lebih bervariasi dari Poisson)
                k = 8.0
                demand = int(rng.negative_binomial(k, k / (k + mu))) if mu > 0 else 0
                gt_rows.append({"tanggal": w["tanggal"], "lokasi": loc, "produk": prod,
                                 "kategori": cat, "permintaan_asli": demand})
                if not visited:
                    continue
                # kebiasaan owner: bawa stok tetap ~ rata-rata kasar
                stock = int(round(BASE[loc][cat] * share * 1.0))
                sold = min(demand, stock)
                daily_rows.append({
                    "tanggal": w["tanggal"], "lokasi": loc, "produk": prod, "kategori": cat,
                    "harga": price, "hpp": hpp, "stok_bawa": stock,
                    "permintaan_asli": demand,  # TIDAK teramati di dunia nyata; hanya untuk evaluasi
                    "terjual": sold, "stockout": int(demand >= stock),
                    "is_simulated": 1,
                })
                # pecah menjadi transaksi per cup dengan jam acak (07-21)
                for _ in range(sold):
                    hour = int(np.clip(rng.normal(14 if loc.startswith("Pantai") else 11, 3.5), 7, 21))
                    minute = int(rng.integers(0, 60))
                    tx_rows.append({
                        "transaction_id": f"TX{tx_id:07d}",
                        "waktu": f"{w['tanggal']} {hour:02d}:{minute:02d}:00",
                        "lokasi": loc, "produk": prod, "kategori": cat, "qty": 1,
                        "harga": price,
                        "metode_bayar": "QRIS" if rng.random() < 0.45 else "Tunai",
                        "status": "selesai", "is_simulated": 1,
                    })
                    tx_id += 1

    os.makedirs(args.out, exist_ok=True)
    weather.to_csv(os.path.join(args.out, "weather.csv"), index=False)
    daily = pd.DataFrame(daily_rows)
    daily.to_csv(os.path.join(args.out, "daily_sales.csv"), index=False)
    tx = pd.DataFrame(tx_rows).sort_values("waktu")
    tx.to_csv(os.path.join(args.out, "transactions.csv"), index=False)

    # ground truth permintaan SEMUA lokasi (termasuk yang tidak didatangi).
    # Hanya untuk evaluasi/backtest - jangan dipakai sebagai fitur model.
    pd.DataFrame(gt_rows).to_csv(os.path.join(args.out, "ground_truth_demand.csv"), index=False)

    loc_df = pd.DataFrame([{"lokasi": k, "lat": v[0], "lon": v[1]} for k, v in LOCATIONS.items()])
    loc_df.to_csv(os.path.join(args.out, "locations.csv"), index=False)

    print(f"{len(weather)} hari, {len(daily)} baris harian, {len(tx)} transaksi -> {args.out}/")
    print("Stockout rate:", round(daily["stockout"].mean(), 3))


if __name__ == "__main__":
    main()
