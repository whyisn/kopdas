"""
Backtest 3 minggu terakhir: bandingkan 3 kebijakan pada permintaan asli (simulasi).
  1. Manual    : 3 lokasi tetap, stok tetap tiap hari (kebiasaan owner)
  2. Rumus     : 3 lokasi tetap, stok = ceil(penjualan hari sama minggu lalu x 1,1)  (rumus proposal awal)
  3. AI        : forecast ML + optimasi MILP (lokasi & stok)
Juga mengevaluasi akurasi forecast vs baseline (MAE, WAPE).
Model dilatih ulang tiap minggu hanya dengan data SEBELUM minggu uji (time split).

    python backtest.py --data data --test-weeks 3
"""
import argparse
import json
import math

import numpy as np
import pandas as pd

from engine import (CATEGORIES, HPP, PRICE, Config, DemandForecaster, explain,
                    optimize_allocation, to_category_level)

MANUAL_LOCATIONS = ["Kampus UNP Air Tawar", "Perkantoran Khatib Sulaiman", "Pasar Raya Padang"]


def ceil_safe(x):
    return int(math.ceil(round(x, 6)))  # hindari ceil(33.0000000004) = 34


def evaluate(plan, truth, cfg):
    opened = plan.groupby("lokasi")["stok"].sum()
    plan = plan[plan.lokasi.isin(opened[opened > 0].index)]  # hanya lokasi yang dibuka
    m = plan.merge(truth, on=["lokasi", "kategori"], how="left").fillna({"permintaan": 0})
    m["terjual"] = np.minimum(m["permintaan"], m["stok"])
    m["sisa"] = m["stok"] - m["terjual"]
    m["hilang"] = m["permintaan"] - m["terjual"]
    m["laba"] = m["kategori"].map(PRICE) * m["terjual"] - m["kategori"].map(HPP) * m["stok"]
    n_open = m.loc[m["stok"] > 0, "lokasi"].nunique()
    return {"laba": m["laba"].sum() - cfg.location_cost * n_open, "terjual": m["terjual"].sum(),
            "sisa": m["sisa"].sum(), "hilang": m["hilang"].sum(), "stok": m["stok"].sum()}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--data", default="data")
    ap.add_argument("--test-weeks", type=int, default=3)
    args = ap.parse_args()

    cfg = Config()
    weather = pd.read_csv(f"{args.data}/weather.csv")
    daily = pd.read_csv(f"{args.data}/daily_sales.csv")
    gt = pd.read_csv(f"{args.data}/ground_truth_demand.csv")
    locs = pd.read_csv(f"{args.data}/locations.csv")["lokasi"].tolist()

    cat_daily = to_category_level(daily)
    truth_cat = gt.groupby(["tanggal", "lokasi", "kategori"])["permintaan_asli"].sum().reset_index()
    manual_stock = (daily[daily.lokasi.isin(MANUAL_LOCATIONS)]
                    .groupby(["lokasi", "kategori", "tanggal"])["stok_bawa"].sum()
                    .groupby(["lokasi", "kategori"]).first().rename("stok").reset_index())

    dates = sorted(weather["tanggal"])
    test_dates = dates[-7 * args.test_weeks:]

    fc_rows, totals = [], {"Manual": [], "Rumus (+10%)": [], "AI (forecast + MILP)": []}
    sample = None
    for w in range(args.test_weeks):
        week = test_dates[7 * w: 7 * (w + 1)]
        train = cat_daily[cat_daily["tanggal"] < week[0]]
        model = DemandForecaster(locs).fit(train, weather)

        for d in week:
            truth = truth_cat[truth_cat.tanggal == d].rename(columns={"permintaan_asli": "permintaan"})[
                ["lokasi", "kategori", "permintaan"]]
            obs = cat_daily[cat_daily.tanggal < d]

            # ---------- forecast & baseline (dievaluasi di 3 lokasi yang punya histori) ----------
            fc = model.predict(d, weather)
            dt = pd.Timestamp(d)
            for loc in MANUAL_LOCATIONS:
                for cat in CATEGORIES:
                    hist = obs[(obs.lokasi == loc) & (obs.kategori == cat)].copy()
                    hist["dow"] = pd.to_datetime(hist.tanggal).dt.dayofweek
                    same = hist[hist.dow == dt.dayofweek].sort_values("tanggal")
                    fc_rows.append({
                        "tanggal": d, "lokasi": loc, "kategori": cat,
                        "aktual": int(truth[(truth.lokasi == loc) & (truth.kategori == cat)]["permintaan"].iloc[0]),
                        "Hari sama minggu lalu": same["terjual"].iloc[-1],
                        "Rata-rata 4 hari sama": same["terjual"].tail(4).mean(),
                        "Model ML": float(fc[(fc.lokasi == loc) & (fc.kategori == cat)]["forecast"].iloc[0]),
                    })

            # ---------- kebijakan ----------
            totals["Manual"].append(evaluate(manual_stock, truth, cfg))

            last = obs[obs.tanggal == (dt - pd.Timedelta(days=7)).date().isoformat()]
            rp = last[last.lokasi.isin(MANUAL_LOCATIONS)][["lokasi", "kategori", "terjual"]].copy()
            rp["stok"] = rp["terjual"].apply(lambda x: ceil_safe(x * 1.1))
            for cat in CATEGORIES:  # hormati kapasitas pusat
                s = rp.loc[rp.kategori == cat, "stok"].sum()
                if s > cfg.central_capacity[cat]:
                    rp.loc[rp.kategori == cat, "stok"] = (rp.loc[rp.kategori == cat, "stok"]
                                                          * cfg.central_capacity[cat] / s).astype(int)
            totals["Rumus (+10%)"].append(evaluate(rp[["lokasi", "kategori", "stok"]], truth, cfg))

            plan = optimize_allocation(fc, cfg)
            ai = plan.rename(columns={"stok_rekomendasi": "stok"})[["lokasi", "kategori", "stok"]]
            totals["AI (forecast + MILP)"].append(evaluate(ai, truth, cfg))
            if sample is None and dt.dayofweek == 5:
                sample = {"tanggal": d, "rencana": plan.to_dict("records"), "alasan": explain(plan, fc)}

    # ---------- ringkasan ----------
    f = pd.DataFrame(fc_rows)
    acc = {}
    for col in ["Hari sama minggu lalu", "Rata-rata 4 hari sama", "Model ML"]:
        err = (f[col] - f["aktual"]).abs()
        acc[col] = {"MAE": round(err.mean(), 2), "WAPE_%": round(100 * err.sum() / f["aktual"].sum(), 1),
                    "bias": round((f[col] - f["aktual"]).mean(), 2)}

    pol = {}
    for k, v in totals.items():
        df = pd.DataFrame(v).sum()
        pol[k] = {"laba_rp": int(df["laba"]), "terjual": int(df["terjual"]), "sisa_cup": int(df["sisa"]),
                  "hilang_cup": int(df["hilang"]), "stok_dibawa": int(df["stok"]),
                  "sisa_%": round(100 * df["sisa"] / df["stok"], 1)}

    out = {"periode_uji": [test_dates[0], test_dates[-1]], "akurasi_forecast": acc,
           "kebijakan": pol, "contoh_rekomendasi_sabtu": sample, "catatan": "SEMUA DATA SIMULASI"}
    with open("results.json", "w") as fh:
        json.dump(out, fh, indent=2, ensure_ascii=False, default=str)
    print(json.dumps({k: out[k] for k in ["periode_uji", "akurasi_forecast", "kebijakan"]}, indent=2, ensure_ascii=False))
    print("\n".join(sample["alasan"]) if sample else "")


if __name__ == "__main__":
    main()
