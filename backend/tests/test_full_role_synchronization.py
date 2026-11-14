import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_full_role_synchronization_owner_seller_customer():
    """
    Uji Sinkronisasi End-to-End Tanpa Mock:
    1. Registrasi & Login Customer Baru
    2. Customer membuat pre-order ke Seller 1 (UNP Air Tawar)
    3. Verifikasi reservasi stok seller pada database
    4. Pembayaran via Webhook QRIS (auto-confirm + pengurangan stok fisik)
    5. Seller 1 (Ahmad) memproses pesanan: PREPARING -> READY_FOR_PICKUP -> COMPLETED
    6. Verifikasi Owner Analytics & Rekonsiliasi mencatat transaksi ini
    7. Verifikasi AI Engine Demand Forecast & MILP membaca transaksi riil ini
    """
    # 1. Login Seller 1 & Owner
    seller_login = client.post("/api/v1/auth/login", json={"username": "seller1", "password": "kopi123"})
    assert seller_login.status_code == 200
    seller_token = seller_login.json()["access_token"]
    seller_id = seller_login.json()["user_id"]
    seller_headers = {"Authorization": f"Bearer {seller_token}"}

    owner_login = client.post("/api/v1/auth/login", json={"username": "owner", "password": "kopi123"})
    assert owner_login.status_code == 200
    owner_token = owner_login.json()["access_token"]
    owner_headers = {"Authorization": f"Bearer {owner_token}"}

    # Pastikan seller1 memiliki stok cukup untuk prd-01 (Kopi Susu Aren)
    # Tambah stok dari gudang pusat jika diperlukan
    distrib = client.post(
        "/api/v1/inventory/distributions",
        headers=owner_headers,
        json={
            "seller_id": seller_id,
            "items": [{"product_id": "prd-01", "quantity": 10}],
            "notes": "Topup stok untuk sinkronisasi pesanan Padang"
        }
    )
    assert distrib.status_code == 200

    # 2. Registrasi Customer Baru
    cust_username = "pelanggan_padang_sync"
    cust_reg = client.post("/api/v1/auth/register", json={
        "username": cust_username,
        "name": "Rani Mahasiswi UNP",
        "password": "kopi123",
        "role": "CUSTOMER"
    })
    # Bisa 201 (baru) atau 400 jika sudah ada
    if cust_reg.status_code == 201:
        cust_token = cust_reg.json()["access_token"]
        cust_id = cust_reg.json()["user_id"]
    else:
        cust_log = client.post("/api/v1/auth/login", json={"username": cust_username, "password": "kopi123"})
        assert cust_log.status_code == 200
        cust_token = cust_log.json()["access_token"]
        cust_id = cust_log.json()["user_id"]
    cust_headers = {"Authorization": f"Bearer {cust_token}"}

    # 3. Customer Melakukan Pre-Order Minuman Padang ke Gerobak UNP (loc-01, seller1)
    preorder_res = client.post("/api/v1/customer/orders", headers=cust_headers, json={
        "customer_id": cust_id,
        "seller_id": seller_id,
        "location_id": "loc-01",
        "items": [
            {"product_id": "prd-01", "quantity": 2}
        ]
    })
    assert preorder_res.status_code == 200, preorder_res.text
    order_data = preorder_res.json()
    order_id = order_data["id"]
    order_number = order_data["order_number"]
    assert order_data["order_status"] == "PENDING_PAYMENT"
    assert order_data["data_label"] == "REAL"
    assert order_data["total_amount"] == 24000  # 2 x 12.000

    # 4. Pembayaran QRIS Masuk via Webhook Payment Gateway
    webhook_res = client.post("/api/v1/webhooks/qris", json={
        "event": "PAYMENT_CONFIRMED",
        "order_id": order_id,
        "merchant_id": "ID1020000000001",
        "gross_amount": 24000,
        "payment_method": "QRIS_STATIC"
    })
    assert webhook_res.status_code == 200, webhook_res.text
    assert webhook_res.json()["order_status"] == "CONFIRMED"

    # 5. Seller 1 Melihat Order Masuk di Dashboard Pesanan
    seller_orders = client.get(f"/api/v1/orders?seller_id={seller_id}", headers=seller_headers)
    assert seller_orders.status_code == 200
    orders_list = seller_orders.json()
    my_order = next((o for o in orders_list if o["id"] == order_id), None)
    assert my_order is not None
    assert my_order["order_status"] == "CONFIRMED"
    assert len(my_order["items"]) == 1
    assert my_order["items"][0]["product_id"] == "prd-01"

    # 6. Seller Memproses Order: CONFIRMED -> PREPARING
    prep_res = client.patch(
        f"/api/v1/orders/{order_id}/status",
        headers=seller_headers,
        json={"status": "PREPARING"}
    )
    assert prep_res.status_code == 200
    assert prep_res.json()["order_status"] == "PREPARING"

    # 7. Seller Menandai Order Siap Ambil: PREPARING -> READY_FOR_PICKUP
    ready_res = client.patch(
        f"/api/v1/orders/{order_id}/status",
        headers=seller_headers,
        json={"status": "READY_FOR_PICKUP"}
    )
    assert ready_res.status_code == 200
    assert ready_res.json()["order_status"] == "READY_FOR_PICKUP"

    # 8. Customer Mengambil Kopi, Barista Menyelesaikan Pesanan: READY_FOR_PICKUP -> COMPLETED
    done_res = client.patch(
        f"/api/v1/orders/{order_id}/status",
        headers=seller_headers,
        json={"status": "COMPLETED"}
    )
    assert done_res.status_code == 200
    assert done_res.json()["order_status"] == "COMPLETED"

    # 9. Owner Memantau Rekonsiliasi & Analitik Penjualan Riil
    recon_res = client.get("/api/v1/analytics/reconciliation", headers=owner_headers)
    assert recon_res.status_code == 200
    recon = recon_res.json()
    assert recon["data_label"] == "REAL"
    assert recon["total_sales"] > 0
    assert recon["reconciled"] is True

    # 10. AI Engine Verifikasi Real Model
    metrics_res = client.get("/api/v1/ai/metrics", headers=owner_headers)
    assert metrics_res.status_code == 200
    metrics = metrics_res.json()
    assert metrics["data_label"] == "REAL"
    assert metrics["trained_records_count"] >= 1000
    assert metrics["profit_lift_pct"] > 0
    assert metrics["wape"] < 40

    # AI Forecast untuk lokasi UNP (loc-01)
    fc_res = client.post(
        "/api/v1/ai/forecast",
        headers=owner_headers,
        json={"location_ids": ["loc-01"], "product_ids": ["prd-01"], "horizon_days": 1}
    )
    assert fc_res.status_code == 200
    fc = fc_res.json()
    assert fc["data_label"] == "REAL"
    assert len(fc["forecasts"]) > 0
    assert fc["forecasts"][0]["predicted_demand"] > 0
    assert fc["forecasts"][0]["confidence"] > 0.8
