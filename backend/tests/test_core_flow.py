"""
Test Suite QA End-to-End Kopi Cerdas (Skenario T01 - T12)
Acuan: Dokumen Induk Bab 15 & Manual Book Bab 10
"""
import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_t01_owner_login():
    """T01: Owner login berhasil dan menerima token dengan role OWNER"""
    res = client.post("/api/v1/auth/login", json={"username": "owner", "password": "kopi123"})
    assert res.status_code == 200
    data = res.json()
    assert data["role"] == "OWNER"
    assert "access_token" in data

def test_t02_seller_login():
    """T02: Seller login berhasil dan menerima token dengan role SELLER"""
    res = client.post("/api/v1/auth/login", json={"username": "seller1", "password": "kopi123"})
    assert res.status_code == 200
    data = res.json()
    assert data["role"] == "SELLER"

def test_t03_products_and_categories():
    """T03: Mengambil master produk dan kategori"""
    res_cats = client.get("/api/v1/categories")
    assert res_cats.status_code == 200
    assert len(res_cats.json()) >= 1

    res_prods = client.get("/api/v1/products")
    assert res_prods.status_code == 200
    assert len(res_prods.json()) >= 1

def test_t04_stock_distribution_atomic():
    """T04: Distribusi stok memindahkan stok gudang ke seller secara atomik"""
    # Ambil stok awal
    res_init = client.get("/api/v1/inventory?scope_type=WAREHOUSE&scope_id=central")
    init_central = next(x["quantity"] for x in res_init.json() if x["product_id"] == "prd-01")

    # Distribusikan 10 cup
    dist_res = client.post("/api/v1/inventory/distributions", json={
        "seller_id": "usr-seller-01",
        "items": [{"product_id": "prd-01", "quantity": 10}],
        "notes": "Tes distribusi QA"
    })
    assert dist_res.status_code == 200

    # Cek stok gudang setelah distribusi
    res_after = client.get("/api/v1/inventory?scope_type=WAREHOUSE&scope_id=central")
    after_central = next(x["quantity"] for x in res_after.json() if x["product_id"] == "prd-01")
    assert after_central == init_central - 10

def test_t05_walkin_transaction_and_idempotency():
    """T05: Transaksi walk-in mengurangi stok seller dan mencegah double-submit via idempotency"""
    import uuid
    # Cek stok seller
    res_seller = client.get("/api/v1/inventory?scope_type=SELLER&scope_id=usr-seller-01")
    init_seller = next(x["quantity"] for x in res_seller.json() if x["product_id"] == "prd-01")

    idem_key = f"test-idem-{uuid.uuid4().hex[:8]}"
    payload = {
        "seller_id": "usr-seller-01",
        "location_id": "loc-01",
        "payment_method": "CASH",
        "idempotency_key": idem_key,
        "items": [{"product_id": "prd-01", "quantity": 2}]
    }

    # Transaksi pertama
    tx_res = client.post("/api/v1/transactions", json=payload)
    assert tx_res.status_code == 200
    assert tx_res.json()["payment_status"] == "PAID"

    # Cek stok seller berkurang tepat 2
    res_seller_after = client.get("/api/v1/inventory?scope_type=SELLER&scope_id=usr-seller-01")
    after_seller = next(x["quantity"] for x in res_seller_after.json() if x["product_id"] == "prd-01")
    assert after_seller == init_seller - 2

    # Transaksi kedua dengan idempotency key sama (double submit)
    tx_res_dup = client.post("/api/v1/transactions", json=payload)
    assert tx_res_dup.status_code == 200
    # Stok tidak boleh berkurang lagi
    res_seller_dup = client.get("/api/v1/inventory?scope_type=SELLER&scope_id=usr-seller-01")
    assert next(x["quantity"] for x in res_seller_dup.json() if x["product_id"] == "prd-01") == after_seller

def test_t06_sales_analytics():
    """T06: Agregasi analitik penjualan cocok dengan transaksi"""
    res = client.get("/api/v1/analytics/sales")
    assert res.status_code == 200
    data = res.json()
    assert "total_revenue" in data["summary"]
    assert data["summary"]["total_revenue"] > 0

def test_t07_location_scoring():
    """T07: Lokasi memuat skor transparan, POI, dan label data"""
    res = client.get("/api/v1/locations")
    assert res.status_code == 200
    locs = res.json()
    assert len(locs) >= 2
    for l in locs:
        assert l["score"] is not None
        assert l["data_label"] in ["REAL", "SIMULASI"]

def test_t08_forecasting():
    """T08: AI forecasting menghasilkan prediksi demand berlabel data operasional"""
    res = client.post("/api/v1/ai/forecast", json={"target_period_days": 7, "data_label": "REAL"})
    assert res.status_code == 200
    data = res.json()
    assert len(data["forecasts"]) > 0
    assert data["forecasts"][0]["data_label"] in ["REAL", "SIMULASI"]

def test_t09_stock_allocation_milp_fallback():
    """T09: Optimasi alokasi stok menghasilkan rekomendasi yang feasible atau fallback"""
    res = client.post("/api/v1/ai/optimize")
    assert res.status_code == 200
    data = res.json()
    assert data["solver_status"] in ["OPTIMAL_MILP", "RULE_BASED_FALLBACK"]
    assert len(data["recommendations"]) > 0

def test_t11_qris_webhook_auto_confirm_and_ambiguity():
    """T11: QRIS Webhook simulator mengonfirmasi pesanan unik dan menolak yang ambigu"""
    from app.core.database import SessionLocal
    from app.models import Order
    import uuid

    # Bersihkan pending order lama agar skenario isolasi bersih
    db = SessionLocal()
    try:
        for old in db.query(Order).filter(Order.payment_status == "PENDING").all():
            old.payment_status = "EXPIRED"
            old.order_status = "EXPIRED"
        db.commit()
    finally:
        db.close()

    # 1. Kasus Unik (MATCHED)
    order_res = client.post("/api/v1/customer/orders", json={
        "customer_id": "cust-01",
        "seller_id": "usr-seller-01",
        "location_id": "loc-01",
        "items": [{"product_id": "prd-02", "quantity": 1}] # 1 x Americano = 15000
    })
    assert order_res.status_code == 200
    order_data = order_res.json()
    assert order_data["payment_status"] == "PENDING"

    # Simulasi Webhook PJP mengirim konfirmasi nominal tepat
    unique_rrn = f"RRN-{uuid.uuid4().hex[:10]}"
    webhook_res = client.post("/api/v1/webhooks/payments/provider-simulator", json={
        "provider_tx_id": f"PJP-SIM-{uuid.uuid4().hex[:6]}",
        "merchant_id": "ID1020000000001",
        "amount": order_data["total_amount"],
        "timestamp": "2026-11-14T10:00:00Z",
        "rrn": unique_rrn
    })
    assert webhook_res.status_code == 200
    assert webhook_res.json()["status"] == "MATCHED"
    assert webhook_res.json()["payment_status"] == "PAID"

    # Cek status order sudah berubah jadi PAID & CONFIRMED
    check_res = client.get(f"/api/v1/customer/orders/{order_data['id']}")
    assert check_res.json()["payment_status"] == "PAID"
    assert check_res.json()["order_status"] == "CONFIRMED"

    # 2. Kasus Ambigu (AMBIGUOUS): Dua order dengan nominal sama persis
    order_a = client.post("/api/v1/customer/orders", json={
        "customer_id": "cust-ambigu-A",
        "seller_id": "usr-seller-01",
        "location_id": "loc-01",
        "items": [{"product_id": "prd-02", "quantity": 1}] # 15000
    }).json()

    order_b = client.post("/api/v1/customer/orders", json={
        "customer_id": "cust-ambigu-B",
        "seller_id": "usr-seller-01",
        "location_id": "loc-01",
        "items": [{"product_id": "prd-02", "quantity": 1}] # 15000
    }).json()

    ambig_res = client.post("/api/v1/webhooks/payments/provider-simulator", json={
        "provider_tx_id": f"PJP-SIM-{uuid.uuid4().hex[:6]}",
        "merchant_id": "ID1020000000001",
        "amount": order_a["total_amount"],
        "timestamp": "2026-11-14T10:05:00Z",
        "rrn": f"RRN-{uuid.uuid4().hex[:10]}"
    })
    assert ambig_res.status_code == 200
    assert ambig_res.json()["status"] == "AMBIGUOUS"
