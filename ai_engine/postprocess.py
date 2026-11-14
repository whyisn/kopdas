"""
Langkah setelah optimasi:
  1. split_products  : cup per kategori -> cup per produk (porsi penjualan historis di lokasi itu)
  2. assign_sellers  : pegawai mana ke lokasi mana (assignment problem, algoritma Hungarian)
"""
import math

import numpy as np
import pandas as pd
from scipy.optimize import linear_sum_assignment

MIN_HISTORY_CUPS = 30        # di bawah ini, porsi lokasi digabung dengan porsi global
EXPERIENCE_KM_PER_DAY = 0.1  # 1 hari pengalaman di lokasi = "senilai" 100 m lebih dekat
EXPERIENCE_CAP_DAYS = 20     # bonus pengalaman maksimum 2 km


# ---------------------------------------------------------------- 1. rincian per produk
def product_shares(daily: pd.DataFrame) -> dict:
    """Porsi produk dalam kategori, per lokasi, dari histori penjualan.
    Return {(lokasi, kategori): {produk: porsi}}; key (None, kategori) = porsi global."""
    shares = {}
    glob = daily.groupby(["kategori", "produk"])["terjual"].sum()
    for cat, g in glob.groupby(level=0):
        shares[(None, cat)] = (g / g.sum()).droplevel(0).to_dict()
    loc = daily.groupby(["lokasi", "kategori", "produk"])["terjual"].sum()
    for (l, cat), g in loc.groupby(level=[0, 1]):
        tot = g.sum()
        local = (g / tot).droplevel([0, 1]).to_dict() if tot else {}
        if tot < MIN_HISTORY_CUPS:  # histori tipis -> campur dengan porsi global
            w = tot / MIN_HISTORY_CUPS
            local = {p: w * local.get(p, 0) + (1 - w) * s for p, s in shares[(None, cat)].items()}
        shares[(l, cat)] = local
    return shares


def split_cups(total: int, shares: dict) -> dict:
    """Bagi `total` cup sesuai porsi; metode sisa terbesar agar jumlahnya tepat sama dengan total."""
    if total <= 0 or not shares:
        return {p: 0 for p in shares}
    raw = {p: total * s for p, s in shares.items()}
    out = {p: int(math.floor(v)) for p, v in raw.items()}
    rest = total - sum(out.values())
    for p in sorted(raw, key=lambda p: raw[p] - out[p], reverse=True)[:rest]:
        out[p] += 1
    return out


# ---------------------------------------------------------------- 2. penugasan pegawai
def haversine_km(a, b):
    (lat1, lon1), (lat2, lon2) = a, b
    p1, p2 = math.radians(lat1), math.radians(lat2)
    dp, dl = p2 - p1, math.radians(lon2 - lon1)
    h = math.sin(dp / 2) ** 2 + math.cos(p1) * math.cos(p2) * math.sin(dl / 2) ** 2
    return 2 * 6371 * math.asin(math.sqrt(h))


def assign_sellers(open_locs: list, sellers: list, coords: dict) -> dict:
    """
    open_locs : [location_id] yang dibuka
    sellers   : [{"seller_id","name","last_location_id","days_at": {location_id: hari}}]
    coords    : {location_id: (lat, lon)}
    Biaya pegawai s di lokasi l = jarak(posisi terakhir s, l) - 0,1 km x min(hari jualan s di l, 20).
    Diselesaikan dengan algoritma Hungarian (optimal untuk total biaya minimum).
    Return {location_id: {"seller_id","name","distance_km","days_at","reason"}}
    """
    if not open_locs or not sellers:
        return {}
    cost = np.zeros((len(sellers), len(open_locs)))
    info = {}
    for i, s in enumerate(sellers):
        start = coords.get(s.get("last_location_id"))
        for j, loc in enumerate(open_locs):
            dist = haversine_km(start, coords[loc]) if start and loc in coords else 3.0
            days = int(s.get("days_at", {}).get(loc, 0))
            cost[i, j] = dist - EXPERIENCE_KM_PER_DAY * min(days, EXPERIENCE_CAP_DAYS)
            info[(i, j)] = (dist, days)
    rows, cols = linear_sum_assignment(cost)
    out = {}
    for i, j in zip(rows, cols):
        dist, days = info[(i, j)]
        s = sellers[i]
        parts = []
        if days:
            parts.append(f"sudah {days} hari berjualan di sini")
        parts.append("posisi terakhir sudah di lokasi ini" if dist < 0.05 else f"{dist:.1f} km dari posisi terakhir")
        out[open_locs[j]] = {"seller_id": s["seller_id"], "name": s["name"],
                             "distance_km": round(dist, 2), "days_at": days,
                             "reason": f"{s['name']}: " + "; ".join(parts) + "."}
    return out
