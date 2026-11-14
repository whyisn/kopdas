"""
Test Suite: Fitur Lokasi Seller (peta interaktif + keramaian + ownership)
Memverifikasi:
- Endpoint /locations/crowd wajib auth, validasi koordinat, label SIMULASI,
  determinisme, profil jam, dan prioritas observasi REAL (hook data aktual).
- /locations/mine wajib auth; seller hanya dapat mengelola lokasi miliknya sendiri
  (403 lintas seller), seller_id tidak bisa dipalsukan dari body.
"""
import uuid
import pytest
from fastapi.testclient import TestClient
from app.main import app
from app.core.database import SessionLocal
from app.models import Location, ExternalObservation

client = TestClient(app)


def _login(username: str) -> dict:
    res = client.post("/api/v1/auth/login", json={"username": username, "password": "kopi123"})
    assert res.status_code == 200, f"Login seed {username} gagal: {res.text}"
    return {"Authorization": f"Bearer {res.json()['access_token']}"}


@pytest.fixture(scope="module")
def seller1_headers():
    return _login("seller1")


@pytest.fixture(scope="module")
def seller2_headers():
    return _login("seller2")


def _delete_location(loc_id: str):
    db = SessionLocal()
    try:
        db.query(Location).filter(Location.id == loc_id).delete()
        db.commit()
    finally:
        db.close()


# --- Crowd density ---

def test_crowd_requires_auth():
    res = client.get("/api/v1/locations/crowd", params={"lat": -0.896, "lng": 100.350})
    assert res.status_code == 401


def test_crowd_invalid_coordinates_rejected(seller1_headers):
    res = client.get("/api/v1/locations/crowd", params={"lat": 999, "lng": 100.350}, headers=seller1_headers)
    assert res.status_code == 422
    res = client.get("/api/v1/locations/crowd", params={"lat": -0.9, "lng": -200}, headers=seller1_headers)
    assert res.status_code == 422


def test_crowd_simulation_labeled_and_deterministic(seller1_headers):
    params = {"lat": -0.896, "lng": 100.350, "hour": 8}
    res = client.get("/api/v1/locations/crowd", params=params, headers=seller1_headers)
    assert res.status_code == 200
    body = res.json()

    # Label simulasi harus eksplisit, bukan diklaim real-time
    assert body["data_label"] == "SIMULASI"
    assert body["source"] == "SIMULATED_FOOTFALL_V1"
    assert "SIMULASI" in body["disclaimer"]
    assert body["hour_used"] == 8

    # Grid heatmap terisi dan intensitas dalam rentang valid
    assert len(body["grid"]) == 19 * 19
    for p in body["grid"]:
        assert 0.0 <= p["intensity"] <= 1.0

    point = body["point"]
    assert point["level"] in {"SEPI", "SEDANG", "RAMAI", "SANGAT_RAMAI"}
    assert 1 <= point["level_code"] <= 4
    assert point["estimated_people"] >= 0
    assert 0 <= point["potential_score"] <= 100
    assert point["potential_label"] in {"SANGAT_POTENSIAL", "POTENSIAL", "CUKUP_POTENSIAL", "KURANG_POTENSIAL"}
    assert point["observed_at"]

    # Deterministik: request identik menghasilkan pola identik
    res2 = client.get("/api/v1/locations/crowd", params=params, headers=seller1_headers)
    assert res2.status_code == 200
    assert res2.json()["grid"] == body["grid"]
    assert res2.json()["point"]["intensity"] == point["intensity"]


def test_crowd_hour_profile_changes_intensity(seller1_headers):
    base = {"lat": -0.896, "lng": 100.350}
    night = client.get("/api/v1/locations/crowd", params={**base, "hour": 3}, headers=seller1_headers).json()
    peak = client.get("/api/v1/locations/crowd", params={**base, "hour": 18}, headers=seller1_headers).json()
    assert peak["point"]["intensity"] > night["point"]["intensity"]
    assert peak["point"]["estimated_people"] > night["point"]["estimated_people"]


def test_crowd_prefers_real_observation(seller1_headers):
    """Hook data aktual: observasi FOOTFALL_ESTIMATE REAL harus diprioritaskan."""
    db = SessionLocal()
    obs_id = f"obs-test-{uuid.uuid4().hex[:8]}"
    try:
        db.add(ExternalObservation(
            id=obs_id, source="TEST_SENSOR", location_id=None,
            latitude=-0.950, longitude=100.360,
            metric="FOOTFALL_ESTIMATE", value="180", unit="people",
            data_label="REAL",
        ))
        db.commit()
    finally:
        db.close()

    try:
        res = client.get("/api/v1/locations/crowd", params={"lat": -0.950, "lng": 100.360}, headers=seller1_headers)
        assert res.status_code == 200
        body = res.json()
        assert body["data_label"] == "REAL"
        assert body["source"] == "TEST_SENSOR"
        assert body["point"]["estimated_people"] == 180
    finally:
        db = SessionLocal()
        try:
            db.query(ExternalObservation).filter(ExternalObservation.id == obs_id).delete()
            db.commit()
        finally:
            db.close()


# --- Seller-owned locations ---

def test_my_locations_requires_auth():
    res = client.get("/api/v1/locations/mine")
    assert res.status_code == 401


def test_seller_location_lifecycle_and_ownership(seller1_headers, seller2_headers):
    # 1. Seller1 menyimpan titik baru
    res = client.post("/api/v1/locations/mine", json={
        "name": "Titik Tes QC", "latitude": -0.900, "longitude": 100.350,
        "address": "Jl. Tes No. 1, Padang",
    }, headers=seller1_headers)
    assert res.status_code == 201, res.text
    loc = res.json()
    loc_id = loc["id"]
    try:
        assert loc["seller_id"] == "usr-seller-01"
        assert loc["source_type"] == "ACTIVE_POINT"
        assert loc["is_active"] is True

        # 2. Hanya muncul di daftar milik seller1, bukan seller2
        mine1 = client.get("/api/v1/locations/mine", headers=seller1_headers).json()
        mine2 = client.get("/api/v1/locations/mine", headers=seller2_headers).json()
        assert any(l["id"] == loc_id for l in mine1)
        assert all(l["id"] != loc_id for l in mine2)

        # 3. Seller2 tidak boleh mengubah lokasi seller1
        res_forbidden = client.patch(f"/api/v1/locations/mine/{loc_id}", json={
            "latitude": -0.910,
        }, headers=seller2_headers)
        assert res_forbidden.status_code == 403

        # 4. Seller1 boleh memperbarui lokasinya sendiri
        res_update = client.patch(f"/api/v1/locations/mine/{loc_id}", json={
            "latitude": -0.910, "longitude": 100.355, "address": "Alamat Baru, Padang",
        }, headers=seller1_headers)
        assert res_update.status_code == 200
        updated = res_update.json()
        assert updated["latitude"] == -0.910
        assert updated["longitude"] == 100.355
        assert updated["address"] == "Alamat Baru, Padang"

        # 5. Lokasi tidak dikenal -> 404
        res_missing = client.patch("/api/v1/locations/mine/loc-tidak-ada", json={
            "name": "X",
        }, headers=seller1_headers)
        assert res_missing.status_code == 404
    finally:
        _delete_location(loc_id)


def test_seller_id_cannot_be_spoofed(seller1_headers):
    """seller_id pada body harus diabaikan; lokasi tetap milik pemilik token."""
    res = client.post("/api/v1/locations/mine", json={
        "name": "Titik Spoof Tes", "latitude": -0.900, "longitude": 100.350,
        "seller_id": "usr-seller-02",
    }, headers=seller1_headers)
    assert res.status_code == 201
    loc = res.json()
    try:
        assert loc["seller_id"] == "usr-seller-01"
    finally:
        _delete_location(loc["id"])


def test_save_location_invalid_coordinates_rejected(seller1_headers):
    res = client.post("/api/v1/locations/mine", json={
        "name": "Titik Invalid", "latitude": 999, "longitude": 100.350,
    }, headers=seller1_headers)
    assert res.status_code == 422
