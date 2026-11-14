import uuid
from fastapi.testclient import TestClient
from app.main import app
from app.core.config import settings
from app.services.midtrans_service import midtrans_service

client = TestClient(app)

def test_midtrans_config():
    res = client.get("/api/v1/payments/midtrans/config")
    assert res.status_code == 200
    data = res.json()
    assert data["client_key"] == "Mid-client-xVYN5mUwjQwAH_-o"
    assert "127.0.0.1:8000/api/v1/payments/midtrans/notification" in data["notification_url"]

def test_midtrans_charge_and_notification_flow():
    # 1. Buat Pre-order customer di backend
    order_res = client.post("/api/v1/customer/orders", json={
        "customer_id": "usr-cust-01",
        "seller_id": "usr-seller-01",
        "location_id": "loc-01",
        "items": [
            {"product_id": "prd-01", "quantity": 1}
        ]
    })
    assert order_res.status_code == 200
    order_data = order_res.json()
    order_id = order_data["id"]
    assert order_data["order_status"] == "PENDING_PAYMENT"

    # 2. Charge Midtrans untuk order
    charge_res = client.post("/api/v1/payments/midtrans/charge", json={
        "order_id": order_id,
        "payment_type": "snap"
    })
    assert charge_res.status_code == 200
    charge_data = charge_res.json()
    assert charge_data["order_id"] == order_id
    assert charge_data["snap_token"] is not None
    assert charge_data["client_key"] == "Mid-client-xVYN5mUwjQwAH_-o"

    # 3. Kirim Webhook Notification Midtrans ke link lokal
    status_code = "200"
    gross_amount = f"{order_data['total_amount']}.00"
    valid_sig = midtrans_service.generate_signature(order_id, status_code, gross_amount)
    tx_id = f"test-midtrans-tx-{uuid.uuid4().hex[:8]}"

    notif_res = client.post("/api/v1/payments/midtrans/notification", json={
        "order_id": order_id,
        "status_code": status_code,
        "gross_amount": gross_amount,
        "signature_key": valid_sig,
        "transaction_status": "settlement",
        "payment_type": "qris",
        "transaction_id": tx_id,
        "fraud_status": "accept"
    })
    assert notif_res.status_code == 200
    notif_data = notif_res.json()
    assert notif_data["status"] == "SETTLED"
    assert notif_data["payment_status"] == "PAID"
    assert notif_data["order_status"] == "CONFIRMED"

    # 4. Verifikasi status order lewat GET
    get_res = client.get(f"/api/v1/customer/orders/{order_id}")
    assert get_res.status_code == 200
    final_order = get_res.json()
    assert final_order["payment_status"] == "PAID"
    assert final_order["order_status"] == "CONFIRMED"

def test_midtrans_invalid_signature_rejected():
    order_res = client.post("/api/v1/customer/orders", json={
        "customer_id": "usr-cust-01",
        "seller_id": "usr-seller-01",
        "location_id": "loc-01",
        "items": [
            {"product_id": "prd-02", "quantity": 1}
        ]
    })
    assert order_res.status_code == 200
    order_id = order_res.json()["id"]

    # Kirim webhook dengan signature salah
    notif_res = client.post("/api/v1/payments/midtrans/notification", json={
        "order_id": order_id,
        "status_code": "200",
        "gross_amount": "12000.00",
        "signature_key": "invalidsignature123456789",
        "transaction_status": "settlement",
        "payment_type": "qris"
    })
    assert notif_res.status_code == 400
    assert "Invalid Midtrans Signature Key" in notif_res.json()["detail"]
