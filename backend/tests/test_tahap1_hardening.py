"""
Test Suite: Tahap 1 Hardening & Invariant Protection
Memverifikasi perbaikan bug kritis:
- Input validation (kuantitas negatif, items kosong, enum payment_method)
- Availability check (walk-in tidak boleh memotong stok yang direservasi)
- Idempotency & Replay Attack prevention pada Webhook QRIS
- Pelepasan reservasi saat order dibatalkan atau expired
- Ketersediaan endpoint /orders dengan field kompatibilitas Flutter (total, customer_name)
- Penegakan otorisasi JWT, Role, dan Ownership Seller isolation
"""
import datetime
import uuid
import pytest
from fastapi.testclient import TestClient
from app.main import app
from app.core.database import SessionLocal
from app.models import Inventory, Order, Product, User

client = TestClient(app)

def test_negative_quantity_rejected_on_transaction():
    """Kuantitas negatif pada walk-in harus ditolak dengan HTTP 422 oleh schema validation"""
    res = client.post("/api/v1/transactions", json={
        "seller_id": "usr-seller-01",
        "location_id": "loc-01",
        "payment_method": "CASH",
        "items": [{"product_id": "prd-01", "quantity": -2}]
    })
    assert res.status_code == 422

def test_empty_items_rejected_on_transaction():
    """Daftar item kosong pada walk-in harus ditolak dengan HTTP 422"""
    res = client.post("/api/v1/transactions", json={
        "seller_id": "usr-seller-01",
        "location_id": "loc-01",
        "payment_method": "CASH",
        "items": []
    })
    assert res.status_code == 422

def test_invalid_payment_method_rejected():
    """Metode pembayaran di luar CASH/QRIS_STATIC harus ditolak dengan HTTP 422"""
    res = client.post("/api/v1/transactions", json={
        "seller_id": "usr-seller-01",
        "location_id": "loc-01",
        "payment_method": "BITCOIN",
        "items": [{"product_id": "prd-01", "quantity": 1}]
    })
    assert res.status_code == 422

def test_negative_quantity_rejected_on_preorder():
    """Kuantitas negatif pada pre-order customer harus ditolak dengan HTTP 422"""
    res = client.post("/api/v1/orders", json={
        "customer_id": "cust-test",
        "seller_id": "usr-seller-01",
        "location_id": "loc-01",
        "items": [{"product_id": "prd-01", "quantity": -5}]
    })
    assert res.status_code == 422

def test_walkin_checks_available_quantity_not_just_physical():
    """
    Walk-in memeriksa available_quantity = (quantity - reserved_quantity).
    Jika stok fisik ada tetapi seluruhnya sudah direservasi untuk pre-order, walk-in harus ditolak!
    """
    db = SessionLocal()
    try:
        # Cari stok seller untuk prd-01
        inv = db.query(Inventory).filter(
            Inventory.scope_type == "SELLER",
            Inventory.scope_id == "usr-seller-01",
            Inventory.product_id == "prd-01"
        ).first()
        assert inv is not None

        # Atur kondisi: quantity fisik 5, tapi reserved_quantity 5 -> available = 0
        original_qty = inv.quantity
        original_res = inv.reserved_quantity
        inv.quantity = 5
        inv.reserved_quantity = 5
        db.commit()

        # Coba beli walk-in 1 cup
        res = client.post("/api/v1/transactions", json={
            "seller_id": "usr-seller-01",
            "location_id": "loc-01",
            "payment_method": "CASH",
            "items": [{"product_id": "prd-01", "quantity": 1}]
        })
        assert res.status_code == 400
        assert "tidak mencukupi" in res.json()["detail"].lower()

        # Kembalikan kondisi awal stok
        inv.quantity = original_qty
        inv.reserved_quantity = original_res
        db.commit()
    finally:
        db.close()

def test_webhook_idempotency_prevents_replay_attack():
    """
    Webhook simulator QRIS harus menolak replay attack dengan RRN yang sama (Idempotency).
    """
    # 1. Buat pesanan baru
    order_res = client.post("/api/v1/orders", json={
        "customer_id": "cust-idempotency-test",
        "seller_id": "usr-seller-01",
        "location_id": "loc-01",
        "items": [{"product_id": "prd-01", "quantity": 1}]
    })
    assert order_res.status_code == 200
    order_data = order_res.json()
    order_id = order_data["id"]
    amount = order_data["total_amount"]

    test_rrn = f"RRN-TEST-{uuid.uuid4().hex[:8]}"

    # 2. Kirim webhook pertama kali
    wh_payload = {
        "provider_tx_id": f"TX-{uuid.uuid4().hex[:6]}",
        "merchant_id": "ID1020000000001",
        "amount": amount,
        "timestamp": "2026-11-14T12:00:00Z",
        "rrn": test_rrn
    }
    wh_res1 = client.post("/api/v1/webhooks/payments/provider-simulator", json=wh_payload)
    assert wh_res1.status_code == 200
    assert wh_res1.json()["status"] == "MATCHED"
    assert wh_res1.json()["payment_status"] == "PAID"

    # 3. Kirim webhook replay (RRN sama persis)
    wh_res2 = client.post("/api/v1/webhooks/payments/provider-simulator", json=wh_payload)
    assert wh_res2.status_code == 200
    # Harus dideteksi sebagai DUPLICATE_EVENT
    assert wh_res2.json()["status"] == "DUPLICATE_EVENT"

def test_webhook_rejects_invalid_merchant_id():
    """Webhook dengan merchant_id tidak sesuai konfigurasi QRIS_NMID harus ditolak"""
    wh_res = client.post("/api/v1/webhooks/payments/provider-simulator", json={
        "provider_tx_id": "TX-WRONG-NMID",
        "merchant_id": "ID9999999999999",  # Salah
        "amount": 25000,
        "timestamp": "2026-11-14T12:00:00Z",
        "rrn": f"RRN-{uuid.uuid4().hex[:8]}"
    })
    assert wh_res.status_code == 200
    assert wh_res.json()["status"] == "UNMATCHED"

def test_order_cancellation_releases_reservation():
    """
    Pembatalan order yang belum dibayar harus melepas reserved_quantity seller.
    """
    db = SessionLocal()
    try:
        inv_before = db.query(Inventory).filter(
            Inventory.scope_type == "SELLER",
            Inventory.scope_id == "usr-seller-01",
            Inventory.product_id == "prd-01"
        ).first()
        res_before = inv_before.reserved_quantity if inv_before else 0

        # Buat pre-order 2 cup
        create_res = client.post("/api/v1/orders", json={
            "customer_id": "cust-cancel-test",
            "seller_id": "usr-seller-01",
            "location_id": "loc-01",
            "items": [{"product_id": "prd-01", "quantity": 2}]
        })
        assert create_res.status_code == 200
        order_id = create_res.json()["id"]

        # Cek reservasi naik 2
        db.refresh(inv_before)
        assert inv_before.reserved_quantity == res_before + 2

        # Batalkan order
        cancel_res = client.post(f"/api/v1/orders/{order_id}/cancel")
        assert cancel_res.status_code == 200
        assert cancel_res.json()["order_status"] == "CANCELLED"
        assert cancel_res.json()["payment_status"] == "REJECTED"

        # Cek reservasi kembali ke semula
        db.refresh(inv_before)
        assert inv_before.reserved_quantity == res_before
    finally:
        db.close()

def test_order_expiration_releases_reservation():
    """
    Order yang melewati batas waktu (expired) harus otomatis ditandai EXPIRED dan reservasi dilepas.
    """
    db = SessionLocal()
    try:
        inv = db.query(Inventory).filter(
            Inventory.scope_type == "SELLER",
            Inventory.scope_id == "usr-seller-01",
            Inventory.product_id == "prd-01"
        ).first()
        res_before = inv.reserved_quantity

        # Buat order
        create_res = client.post("/api/v1/orders", json={
            "customer_id": "cust-expire-test",
            "seller_id": "usr-seller-01",
            "location_id": "loc-01",
            "items": [{"product_id": "prd-01", "quantity": 3}]
        })
        assert create_res.status_code == 200
        order_id = create_res.json()["id"]

        # Simulasikan waktu kadaluarsa (ubah expires_at ke masa lalu di DB)
        order_db = db.query(Order).filter(Order.id == order_id).first()
        order_db.expires_at = datetime.datetime.utcnow() - datetime.timedelta(minutes=10)
        db.commit()

        # Panggil GET status order
        get_res = client.get(f"/api/v1/orders/{order_id}")
        assert get_res.status_code == 200
        assert get_res.json()["order_status"] == "EXPIRED"
        assert get_res.json()["payment_status"] == "EXPIRED"

        # Cek reservasi dilepaskan
        db.refresh(inv)
        assert inv.reserved_quantity == res_before
    finally:
        db.close()

def test_orders_endpoint_exists_and_flutter_compatible():
    """
    Endpoint GET /api/v1/orders harus tersedia untuk Owner dashboard,
    dan memuat field kompatibilitas: 'total', 'customer_name', dan 'items'.
    """
    res = client.get("/api/v1/orders")
    assert res.status_code == 200
    orders = res.json()
    assert isinstance(orders, list)
    if len(orders) > 0:
        o = orders[0]
        assert "total" in o
        assert "total_amount" in o
        assert o["total"] == o["total_amount"]
        assert "customer_name" in o
        assert "items" in o

def test_auth_me_requires_valid_bearer_token():
    """
    GET /api/v1/auth/me wajib menyertakan Authorization Bearer token yang valid.
    Jika tidak ada atau palsu, harus ditolak dengan HTTP 401.
    """
    # 1. Tanpa header -> 401
    res_no_auth = client.get("/api/v1/auth/me")
    assert res_no_auth.status_code == 401

    # 2. Token palsu -> 401
    res_fake_token = client.get("/api/v1/auth/me", headers={"Authorization": "Bearer fake-token-12345"})
    assert res_fake_token.status_code == 401

    # 3. Login riil dan gunakan token sah -> 200
    login_res = client.post("/api/v1/auth/login", json={"username": "owner", "password": "kopi123"})
    assert login_res.status_code == 200
    token = login_res.json()["access_token"]

    res_auth = client.get("/api/v1/auth/me", headers={"Authorization": f"Bearer {token}"})
    assert res_auth.status_code == 200
    assert res_auth.json()["username"] == "owner"
    assert res_auth.json()["role"] == "OWNER"

def test_seller_role_isolation():
    """
    Isolasi Seller:
    - Seller tidak boleh melihat stok seller lain (HTTP 403)
    - Seller tidak boleh mendistribusikan stok gudang (HTTP 403)
    - Seller tidak boleh mencatat transaksi atas nama seller lain (HTTP 403)
    """
    # Login seller1
    login_seller = client.post("/api/v1/auth/login", json={"username": "seller1", "password": "kopi123"})
    assert login_seller.status_code == 200
    seller_token = login_seller.json()["access_token"]
    seller_headers = {"Authorization": f"Bearer {seller_token}"}

    # 1. Seller1 mencoba melihat stok seller2 -> 403
    res_inv_other = client.get("/api/v1/inventory?scope_type=SELLER&scope_id=usr-seller-02", headers=seller_headers)
    assert res_inv_other.status_code == 403

    # 2. Seller1 mencoba mendistribusikan stok gudang -> 403
    res_dist = client.post("/api/v1/inventory/distributions", headers=seller_headers, json={
        "seller_id": "usr-seller-01",
        "items": [{"product_id": "prd-01", "quantity": 5}]
    })
    assert res_dist.status_code == 403

    # 3. Seller1 mencoba mencatat transaksi dengan seller_id seller2 -> 403
    res_tx_other = client.post("/api/v1/transactions", headers=seller_headers, json={
        "seller_id": "usr-seller-02",
        "location_id": "loc-02",
        "payment_method": "CASH",
        "items": [{"product_id": "prd-01", "quantity": 1}]
    })
    assert res_tx_other.status_code == 403
