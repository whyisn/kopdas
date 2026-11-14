"""
Penyedia data keramaian (crowd density) untuk fitur Lokasi Seller.

SUMBER DATA:
- Sampai tersedia integrasi data aktual, modul ini menghasilkan estimasi
  SIMULASI yang deterministik: pola hotspot spasial diturunkan dari koordinat
  area, dikalikan profil keramaian per jam (WIB). Hasilnya stabil untuk
  koordinat + jam yang sama, sehingga tidak berubah-ubah antar request.
- Jalur integrasi data aktual sudah disiapkan: simpan observasi nyata ke
  tabel external_observations dengan metric="FOOTFALL_ESTIMATE",
  data_label="REAL", dan value = estimasi jumlah orang. Endpoint yang sama
  akan otomatis memprioritaskan data nyata tersebut (data_label="REAL").

Jangan pernah menyajikan hasil simulasi sebagai data real-time.
"""
import datetime
import hashlib
import math
import random
from typing import List, Optional

from sqlalchemy.orm import Session

from app.models import ExternalObservation

WIB = datetime.timezone(datetime.timedelta(hours=7))

# Ambang level keramaian berdasarkan intensitas 0..1
_LEVELS = [
    (0.28, 1, "SEPI"),
    (0.52, 2, "SEDANG"),
    (0.75, 3, "RAMAI"),
    (1.01, 4, "SANGAT_RAMAI"),
]

# Profil keramaian per jam (WIB): aktivitas khas area komersial/kampus
_HOUR_PROFILE = {
    0: 0.10, 1: 0.08, 2: 0.06, 3: 0.06, 4: 0.10, 5: 0.22,
    6: 0.55, 7: 0.85, 8: 0.95, 9: 0.80, 10: 0.62, 11: 0.68,
    12: 0.92, 13: 0.88, 14: 0.60, 15: 0.58, 16: 0.66, 17: 0.88,
    18: 1.00, 19: 0.90, 20: 0.72, 21: 0.52, 22: 0.32, 23: 0.18,
}

_HOUR_LABELS = [
    (range(0, 5), "dini hari"),
    (range(5, 10), "jam aktivitas pagi"),
    (range(10, 12), "menjelang siang"),
    (range(12, 14), "jam makan siang"),
    (range(14, 16), "siang sore"),
    (range(16, 20), "jam pulang kerja & malam"),
    (range(20, 24), "malam hari"),
]

# Faktor konversi intensitas -> estimasi orang pada radius ±150 m
_PEOPLE_AT_FULL_INTENSITY = 220

SIMULATION_DISCLAIMER = (
    "Data keramaian ini adalah ESTIMASI SIMULASI untuk keperluan demo, "
    "bukan pengamatan real-time. Angka dihasilkan model simulasi deterministik "
    "berdasarkan pola area dan profil jam, sehingga dapat berbeda dari kondisi lapangan."
)
REAL_DISCLAIMER = (
    "Data keramaian berasal dari observasi eksternal terakhir yang tercatat, "
    "bukan pemantauan live. Perbarui observasi secara berkala agar tetap relevan."
)


def _clamp01(x: float) -> float:
    return max(0.0, min(1.0, x))


def _level_for(intensity: float):
    for threshold, code, label in _LEVELS:
        if intensity < threshold:
            return code, label
    return 4, "SANGAT_RAMAI"


def _hour_label(hour: int) -> str:
    for hours, label in _HOUR_LABELS:
        if hour in hours:
            return label
    return "jam aktif"


def _area_hotspots(lat: float, lng: float) -> List[dict]:
    """
    Hotspot deterministik untuk sel area ~0.01° (±1.1 km).
    Titik yang berdekatan berbagi pola hotspot yang sama sehingga heatmap
    tidak berubah acak saat pin digeser sedikit.
    """
    cell_lat = round(lat, 2)
    cell_lng = round(lng, 2)
    seed = int(hashlib.md5(f"kopdas-crowd:{cell_lat}:{cell_lng}".encode()).hexdigest()[:12], 16)
    rng = random.Random(seed)
    hotspots = []
    for _ in range(6):
        hotspots.append({
            "lat": cell_lat + rng.uniform(-0.007, 0.007),
            "lng": cell_lng + rng.uniform(-0.007, 0.007),
            "sigma_m": rng.uniform(130, 340),
            "weight": rng.uniform(0.45, 1.0),
        })
    return hotspots


def _field_intensity(lat: float, lng: float, hotspots: List[dict]) -> float:
    """Intensitas spasial dasar (0..1) dari akumulasi hotspot Gaussian."""
    meters_per_deg_lat = 111_320.0
    meters_per_deg_lng = 111_320.0 * max(0.2, math.cos(math.radians(lat)))
    total = 0.06  # aktivitas latar minimum
    for h in hotspots:
        dy = (lat - h["lat"]) * meters_per_deg_lat
        dx = (lng - h["lng"]) * meters_per_deg_lng
        dist_sq = dx * dx + dy * dy
        total += h["weight"] * math.exp(-dist_sq / (2 * h["sigma_m"] ** 2))
    return _clamp01(total)


def _potential(intensity: float):
    score = round(intensity * 100)
    if score >= 75:
        label = "SANGAT_POTENSIAL"
    elif score >= 50:
        label = "POTENSIAL"
    elif score >= 30:
        label = "CUKUP_POTENSIAL"
    else:
        label = "KURANG_POTENSIAL"
    return score, label


def _point_info(intensity: float, hour: int, observed_at: datetime.datetime) -> dict:
    code, label = _level_for(intensity)
    people = round(intensity * _PEOPLE_AT_FULL_INTENSITY)
    score, potential_label = _potential(intensity)
    factors = [
        f"Intensitas keramaian {round(intensity * 100)}% pada pukul {hour:02d}:00 WIB ({_hour_label(hour)}).",
        f"Estimasi ±{people} orang berada dalam radius ±150 m dari titik.",
        "Potensi dihitung dari tingkat keramaian pada jam yang dipilih.",
    ]
    return {
        "level": label,
        "level_code": code,
        "intensity": round(intensity, 3),
        "estimated_people": people,
        "potential_score": score,
        "potential_label": potential_label,
        "factors": factors,
        "observed_at": observed_at,
    }


def _simulation_report(lat: float, lng: float, radius_m: int, hour: int) -> dict:
    now = datetime.datetime.now(datetime.timezone.utc)
    hotspots = _area_hotspots(lat, lng)
    hour_factor = _HOUR_PROFILE[hour % 24]

    grid_n = 19
    step_m = (radius_m * 2) / (grid_n - 1)
    d_lat = step_m / 111_320.0
    d_lng = step_m / (111_320.0 * max(0.2, math.cos(math.radians(lat))))
    grid = []
    for i in range(grid_n):
        for j in range(grid_n):
            g_lat = lat + (i - (grid_n - 1) / 2) * d_lat
            g_lng = lng + (j - (grid_n - 1) / 2) * d_lng
            intensity = _clamp01(_field_intensity(g_lat, g_lng, hotspots) * hour_factor)
            grid.append({"lat": round(g_lat, 6), "lng": round(g_lng, 6), "intensity": round(intensity, 3)})

    point_intensity = _clamp01(_field_intensity(lat, lng, hotspots) * hour_factor)
    return {
        "data_label": "SIMULASI",
        "source": "SIMULATED_FOOTFALL_V1",
        "disclaimer": SIMULATION_DISCLAIMER,
        "generated_at": now,
        "hour_used": hour % 24,
        "radius_m": radius_m,
        "center_lat": lat,
        "center_lng": lng,
        "grid": grid,
        "point": _point_info(point_intensity, hour % 24, now),
    }


def _real_report(obs: ExternalObservation, lat: float, lng: float, radius_m: int, hour: int) -> dict:
    try:
        people = int(float(obs.value))
    except (TypeError, ValueError):
        people = 0
    intensity = _clamp01(people / _PEOPLE_AT_FULL_INTENSITY)
    observed_at = obs.observed_at or datetime.datetime.now(datetime.timezone.utc)
    return {
        "data_label": "REAL",
        "source": obs.source,
        "disclaimer": REAL_DISCLAIMER,
        "generated_at": datetime.datetime.now(datetime.timezone.utc),
        "hour_used": hour,
        "radius_m": radius_m,
        "center_lat": lat,
        "center_lng": lng,
        "grid": [{"lat": obs.latitude, "lng": obs.longitude, "intensity": round(intensity, 3)}],
        "point": _point_info(intensity, hour, observed_at),
    }


def get_crowd_report(
    db: Session,
    lat: float,
    lng: float,
    radius_m: int = 700,
    hour: Optional[int] = None,
) -> dict:
    """
    Ambil laporan keramaian di sekitar (lat, lng).

    Prioritas: observasi nyata terbaru (FOOTFALL_ESTIMATE, data_label REAL)
    dalam radius; jika tidak ada, gunakan simulasi deterministik berlabel SIMULASI.
    """
    if hour is None:
        hour = datetime.datetime.now(WIB).hour
    hour = hour % 24

    d_lat = radius_m / 111_320.0
    d_lng = radius_m / (111_320.0 * max(0.2, math.cos(math.radians(lat))))
    obs = (
        db.query(ExternalObservation)
        .filter(
            ExternalObservation.metric == "FOOTFALL_ESTIMATE",
            ExternalObservation.data_label == "REAL",
            ExternalObservation.latitude.between(lat - d_lat, lat + d_lat),
            ExternalObservation.longitude.between(lng - d_lng, lng + d_lng),
        )
        .order_by(ExternalObservation.observed_at.desc())
        .first()
    )
    if obs is not None:
        return _real_report(obs, lat, lng, radius_m, hour)
    return _simulation_report(lat, lng, radius_m, hour)
