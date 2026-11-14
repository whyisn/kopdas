import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_weather_impact_rain_reduces_demand():
    """Menguji penyesuaian alokasi stok saat kondisi cuaca HUJAN (RAIN)."""
    # 1. Alokasi kondisi normal
    res_normal = client.post("/api/v1/ai/optimize", json={"weather_condition": "NORMAL"})
    assert res_normal.status_code == 200
    data_normal = res_normal.json()
    total_normal = data_normal["total_recommended_cups"]

    # 2. Alokasi kondisi hujan
    res_rain = client.post("/api/v1/ai/optimize", json={"weather_condition": "RAIN"})
    assert res_rain.status_code == 200
    data_rain = res_rain.json()
    total_rain = data_rain["total_recommended_cups"]

    assert data_rain["weather_condition"] == "RAIN"
    assert "Hujan" in data_rain["weather_summary"]
    # Total alokasi saat hujan harus lebih rendah daripada normal
    assert total_rain < total_normal

    # Verifikasi rationale & weather_impact pada item
    for item in data_rain["recommendations"]:
        assert item["weather_condition"] == "RAIN"
        assert "Hujan" in item["weather_impact"]
        # Pastikan ada narasi alasan cuaca di rationale
        has_weather_rationale = any("Hujan" in r for r in item["rationale"])
        assert has_weather_rationale, f"Rationale tidak mengandung alasan cuaca: {item['rationale']}"

def test_weather_impact_peak_sunny_increases_demand():
    """Menguji penyesuaian alokasi stok saat kondisi cuaca CERAH PANAS / RAMAI (PEAK_SUNNY)."""
    res_normal = client.post("/api/v1/ai/optimize", json={"weather_condition": "NORMAL"})
    assert res_normal.status_code == 200
    total_normal = res_normal.json()["total_recommended_cups"]

    res_sunny = client.post("/api/v1/ai/optimize", json={"weather_condition": "PEAK_SUNNY"})
    assert res_sunny.status_code == 200
    data_sunny = res_sunny.json()
    total_sunny = data_sunny["total_recommended_cups"]

    assert data_sunny["weather_condition"] == "PEAK_SUNNY"
    assert "Cerah Panas" in data_sunny["weather_summary"]
    # Total alokasi saat cerah panas harus lebih tinggi atau sama dengan normal (dibatasi kapasitas fisik)
    assert total_sunny >= total_normal

    # Varian dingin (prd-01, prd-06) harus mendapat rekomendasi lebih tinggi
    cold_sunny = sum(r["recommended_stock"] for r in data_sunny["recommendations"] if r["product_id"] in ("prd-01", "prd-06"))
    cold_normal = sum(r["recommended_stock"] for r in res_normal.json()["recommendations"] if r["product_id"] in ("prd-01", "prd-06"))
    assert cold_sunny >= cold_normal

def test_weather_invariants_respected():
    """Menguji bahwa batas kapasitas gerobak (maks 120 cup) dan batas gudang tetap dipatuhi saat lonjakan cuaca panas."""
    res_sunny = client.post("/api/v1/ai/optimize", json={"weather_condition": "PEAK_SUNNY"})
    assert res_sunny.status_code == 200
    data_sunny = res_sunny.json()

    # Hitung alokasi per seller / lokasi
    per_location = {}
    for r in data_sunny["recommendations"]:
        loc_id = r["location_id"]
        per_location[loc_id] = per_location.get(loc_id, 0) + r["recommended_stock"]

    # Tidak boleh ada lokasi / gerobak yang dialokasikan melebihi batas fisik 120 cup
    for loc_id, total_cups in per_location.items():
        assert total_cups <= 120, f"Gerobak {loc_id} melebihi kapasitas fisik: {total_cups} cup > 120"
