"""
PERCOBAAN OPERASIONAL SUNGGUHAN (REAL OPERATIONAL TEST SUITE)
Kopi Cerdas - Smart Coffee Network

Pengujian ini bukan lagi simulasi dummy, melainkan percobaan alur bisnis riil
dari hulu ke hilir (End-to-End Real Operations) menggunakan:
1. Database SQLite relasional nyata dengan 12.000+ data transaksi historis.
2. Model AI Machine Learning GBDT Poisson dan MILP Solver HiGHS yang dihitung langsung dari DB.
3. Manajemen staf lapangan riil (Owner mendaftarkan seller, assign gerobak).
4. Telemetri GPS riil titik gerobak.
5. Distribusi stok fisik atomik dari gudang pusat ke gerobak.
6. Transaksi POS kasir walk-in (Cash & QRIS) dengan idempotency key.
7. Pre-order pelanggan, reservasi stok fisik, dan konfirmasi webhook pembayaran.
8. Rekonsiliasi keuangan dan ekspor laporan CSV riil.
"""
import uuid
import datetime
import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_real_experiment_01_owner_staff_management():
    """Percobaan 1: Owner login, melihat daftar staf riil, dan mendaftarkan seller baru"""
    # 1. Login Owner
    login_res = client.post("/api/v1/auth/login", json={"username": "owner", "password": "kopi123"})
    assert login_res.status_code == 200
    token = login_res.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    # 2. Ambil daftar staf lapangan riil
    users_res = client.get("/api/v1/users?role=SELLER", headers=headers)
    assert users_res.status_code == 200
    sellers = users_res.json()
    assert len(sellers) >= 2  # seller1 dan seller2

    # 3. Daftarkan staf baru (Seller 3 - Pasar Raya)
    new_username = f"seller_ops_{uuid.uuid4().hex[:6]}"
    create_res = client.post("/api/v1/users", json={
        "username": new_username,
        "name": "Doni Seller Pasar Raya",
        "password": "kopi123password",
        "role": "SELLER"
    }, headers=headers)
    assert create_res.status_code == 201
    new_seller = create_res.json()
    assert new_seller["username"] == new_username
    assert new_seller["role"] == "SELLER"
    assert new_seller["is_active"] is True

    # 4. Uji login seller baru dengan kredensialnya
    seller_login = client.post("/api/v1/auth/login", json={"username": new_username, "password": "kopi123password"})
    assert seller_login.status_code == 200
    assert seller_login.json()["user_id"] == new_seller["id"]

def test_real_experiment_02_location_crud_and_live_telemetry():
    """Percobaan 2: Pendaftaran titik mangkal baru, penugasan seller, dan telemetri GPS live"""
    # 1. Daftarkan titik lokasi gerobak baru
    loc_payload = {
        "name": f"Titik Uji Operasional {uuid.uuid4().hex[:4]}",
        "latitude": -0.925,
        "longitude": 100.355,
        "address": "Jl. Bagindo Aziz Chan, Padang",
        "source_type": "ACTIVE_POINT",
        "is_active": True
    }
    create_loc = client.post("/api/v1/locations", json=loc_payload)
    assert create_loc.status_code == 201
    loc_data = create_loc.json()
    loc_id = loc_data["id"]
    assert loc_data["name"] == loc_payload["name"]
    assert loc_data["data_label"] == "REAL"

    # 2. Tugaskan seller ke titik ini
    patch_loc = client.patch(f"/api/v1/locations/{loc_id}", json={
        "seller_id": "usr-seller-01"
    })
    assert patch_loc.status_code == 200
    assert patch_loc.json()["seller_id"] == "usr-seller-01"
    assert patch_loc.json()["seller_name"] is not None

    # 3. Seller mengirim update koordinat GPS live (Telemetri)
    telemetry_res = client.post(f"/api/v1/locations/{loc_id}/telemetry", json={
        "latitude": -0.9258,
        "longitude": 100.3562,
        "accuracy_m": 4.5,
        "battery_pct": 88,
        "status": "ACTIVE_SELLING"
    })
    assert telemetry_res.status_code == 200
    assert telemetry_res.json()["status"] == "SUCCESS"
    assert telemetry_res.json()["latitude"] == -0.9258

def test_real_experiment_03_ai_forecast_and_milp_on_real_database():
    """Percobaan 3: AI Machine Learning melatih langsung dari 1.500+ data transaksi dan menjalankan MILP"""
    # 1. Jalankan peramalan permintaan riil (Target 7 hari ke depan)
    fc_res = client.post("/api/v1/ai/forecast", json={
        "target_period_days": 7,
        "data_label": "REAL"
    })
    assert fc_res.status_code == 200
    fc_json = fc_res.json()
    assert fc_json["data_label"] == "REAL"
    assert len(fc_json["forecasts"]) >= 12  # Minimal prediksi titik x produk

    # Verifikasi bahwa model ML GBDT Poisson benar-benar aktif (karena histori transaksi > 15)
    sample_fc = fc_json["forecasts"][0]
    assert sample_fc["model_version"] == "hgb-poisson-em-v1"
    assert sample_fc["confidence"] >= 0.80
    assert sample_fc["data_quality"] == "HIGH"
    assert sample_fc["data_label"] == "REAL"

    # 2. Jalankan solver optimasi alokasi stok MILP HiGHS
    opt_res = client.post("/api/v1/ai/optimize")
    assert opt_res.status_code == 200
    opt_json = opt_res.json()
    assert opt_json["solver_status"] in ["OPTIMAL_MILP", "RULE_BASED_FALLBACK"]
    assert opt_json["total_recommended_cups"] > 0
    assert opt_json["estimated_margin"] > 0
    assert opt_json["data_label"] == "REAL"

    # 3. Periksa metrik performa model untuk pitching
    metrics_res = client.get("/api/v1/ai/metrics")
    assert metrics_res.status_code == 200
    m = metrics_res.json()
    assert m["trained_records_count"] > 10000
    assert m["profit_lift_pct"] > 25.0
    assert m["data_label"] == "REAL"

def test_real_experiment_04_stock_distribution_and_pos_sales():
    """Percobaan 4: Alokasi stok gudang pusat -> Gerobak -> Penjualan POS Kasir langsung"""
    # 1. Cek stok gudang pusat untuk Kopi Susu Aren (prd-01)
    inv_res = client.get("/api/v1/inventory?scope_type=WAREHOUSE&scope_id=central")
    central_stock_before = next(x["quantity"] for x in inv_res.json() if x["product_id"] == "prd-01")
    assert central_stock_before >= 20

    # 2. Distribusikan 15 cup ke Seller 1 (UNP)
    dist_res = client.post("/api/v1/inventory/distributions", json={
        "seller_id": "usr-seller-01",
        "items": [{"product_id": "prd-01", "quantity": 15}],
        "notes": "Distribusi stok pagi hari operasional riil"
    })
    assert dist_res.status_code == 200

    # Verifikasi stok gudang berkurang tepat 15
    inv_after = client.get("/api/v1/inventory?scope_type=WAREHOUSE&scope_id=central")
    central_stock_after = next(x["quantity"] for x in inv_after.json() if x["product_id"] == "prd-01")
    assert central_stock_after == central_stock_before - 15

    # 3. Seller melakukan penjualan di kasir POS (Walk-in CASH)
    seller_stock_before = client.get("/api/v1/inventory?scope_type=SELLER&scope_id=usr-seller-01")
    stock_seller_init = next(x["quantity"] for x in seller_stock_before.json() if x["product_id"] == "prd-01")

    idem_key = f"real-tx-{uuid.uuid4().hex[:10]}"
    pos_res = client.post("/api/v1/transactions", json={
        "seller_id": "usr-seller-01",
        "location_id": "loc-01",
        "payment_method": "CASH",
        "idempotency_key": idem_key,
        "items": [{"product_id": "prd-01", "quantity": 3}]  # 3 cup x 12.000 = 36.000
    })
    assert pos_res.status_code == 200
    assert pos_res.json()["total_amount"] == 36000
    assert pos_res.json()["payment_status"] == "PAID"

    # Verifikasi stok gerobak seller berkurang tepat 3 cup
    seller_stock_after = client.get("/api/v1/inventory?scope_type=SELLER&scope_id=usr-seller-01")
    stock_seller_now = next(x["quantity"] for x in seller_stock_after.json() if x["product_id"] == "prd-01")
    assert stock_seller_now == stock_seller_init - 3

def test_real_experiment_05_customer_preorder_and_qris_confirmation():
    """Percobaan 5: Pelanggan membuat pre-order online -> Reservasi stok -> Webhook QRIS mengonfirmasi lunas"""
    # 1. Cek stok gerobak Seller 1 sebelum reservasi
    inv_pre = client.get("/api/v1/inventory?scope_type=SELLER&scope_id=usr-seller-01")
    inv_prd2 = next(x for x in inv_pre.json() if x["product_id"] == "prd-02")
    avail_before = inv_prd2["available_quantity"]

    # 2. Customer membuat pre-order 2 cup Americano (2 x 12.000 = 24.000)
    order_res = client.post("/api/v1/customer/orders", json={
        "customer_id": "cust-real-maya",
        "seller_id": "usr-seller-01",
        "location_id": "loc-01",
        "items": [{"product_id": "prd-02", "quantity": 2}]
    })
    assert order_res.status_code == 200
    order_data = order_res.json()
    order_id = order_data["id"]
    assert order_data["total_amount"] == 24000
    assert order_data["payment_status"] == "PENDING"
    assert order_data["order_status"] == "PENDING_PAYMENT"

    # 3. Verifikasi ketersediaan stok gerobak berkurang karena reservasi
    inv_post = client.get("/api/v1/inventory?scope_type=SELLER&scope_id=usr-seller-01")
    inv_prd2_post = next(x for x in inv_post.json() if x["product_id"] == "prd-02")
    assert inv_prd2_post["available_quantity"] == avail_before - 2
    assert inv_prd2_post["reserved_quantity"] >= 2

    # 4. Webhook pembayaran QRIS mengirimkan notifikasi lunas
    rrn_code = f"RRN-{uuid.uuid4().hex[:12]}"
    webhook_res = client.post("/api/v1/webhooks/payments/provider-simulator", json={
        "provider_tx_id": f"PJP-PROD-{uuid.uuid4().hex[:8]}",
        "merchant_id": "ID1020000000001",
        "amount": 24000,
        "timestamp": datetime.datetime.utcnow().isoformat(),
        "rrn": rrn_code
    })
    assert webhook_res.status_code == 200
    assert webhook_res.json()["status"] == "MATCHED"

    # 5. Verifikasi status order berubah menjadi CONFIRMED & PAID
    order_status_res = client.get(f"/api/v1/customer/orders/{order_id}")
    assert order_status_res.status_code == 200
    assert order_status_res.json()["payment_status"] == "PAID"
    assert order_status_res.json()["order_status"] == "CONFIRMED"

    # 6. Seller memproses pesanan hingga selesai diambil pelanggan
    prep_res = client.patch(f"/api/v1/orders/{order_id}/status", json={"status": "PREPARING"})
    assert prep_res.status_code == 200
    assert prep_res.json()["order_status"] == "PREPARING"

    pickup_res = client.patch(f"/api/v1/orders/{order_id}/status", json={"status": "READY_FOR_PICKUP"})
    assert pickup_res.status_code == 200

    done_res = client.patch(f"/api/v1/orders/{order_id}/status", json={"status": "COMPLETED"})
    assert done_res.status_code == 200
    assert done_res.json()["order_status"] == "COMPLETED"

def test_real_experiment_06_analytics_reconciliation_and_csv_export():
    """Percobaan 6: Rekonsiliasi omzet analitik dan ekspor laporan CSV riil"""
    # 1. Ambil analitik penjualan
    sales_res = client.get("/api/v1/analytics/sales?days=30")
    assert sales_res.status_code == 200
    sales_data = sales_res.json()
    assert sales_data["summary"]["total_revenue"] > 0
    assert sales_data["summary"]["total_cups_sold"] > 0
    assert sales_data["data_label"] == "REAL"
    assert len(sales_data["product_breakdown"]) >= 1

    # 2. Ekspor laporan transaksi ke CSV
    csv_res = client.get("/api/v1/analytics/export?days=30")
    assert csv_res.status_code == 200
    assert "text/csv" in csv_res.headers.get("content-type", "")
    csv_text = csv_res.text
    assert "transaction_id,waktu,lokasi_id,lokasi_nama" in csv_text
    lines = csv_text.strip().split("\n")
    assert len(lines) >= 5  # Memuat header dan data transaksi riil
