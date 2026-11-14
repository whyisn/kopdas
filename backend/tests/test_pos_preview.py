"""Tes fitur preview minuman kasir: gambar produk, grup varian, dan harga varian.

Jalankan pada salinan DB agar data live tidak termutasi, mis.:
  DATABASE_URL=sqlite:///./test_preview.db pytest tests/test_pos_preview.py
"""
import uuid

from fastapi.testclient import TestClient

from app.core.database import SessionLocal
from app.main import app
from app.models import Inventory

client = TestClient(app)


def _seller_headers():
    res = client.post("/api/v1/auth/login", json={"username": "seller1", "password": "kopi123"})
    assert res.status_code == 200
    return {"Authorization": f"Bearer {res.json()['access_token']}"}


def _seller_stock(product_id: str) -> int:
    db = SessionLocal()
    try:
        inv = db.query(Inventory).filter(
            Inventory.scope_type == "SELLER",
            Inventory.scope_id == "usr-seller-01",
            Inventory.product_id == product_id,
        ).first()
        return inv.quantity if inv else 0
    finally:
        db.close()


def test_products_have_images_and_options():
    res = client.get("/api/v1/products")
    assert res.status_code == 200
    prods = {p["id"]: p for p in res.json()}

    # Produk lama tetap ada dengan harga asli, kini dilengkapi gambar & varian
    assert prods["prd-01"]["price"] == 12000
    assert prods["prd-01"]["image_url"] == "/static/products/es-kopi-susu.jpg"
    assert [g["id"] for g in prods["prd-01"]["options"]] == ["size", "serving", "extras"]

    # Produk baru katalog menu hadir dengan gambar & varian
    for pid in ["prd-07", "prd-08", "prd-09", "prd-10", "prd-11"]:
        assert pid in prods, f"produk katalog {pid} hilang"
        assert prods[pid]["image_url"].startswith("/static/products/")
        assert prods[pid]["options"], f"produk {pid} tanpa grup varian"

    # Semua gambar katalog menunjuk file yang benar-benar tersaji
    for p in prods.values():
        if p["image_url"] and p["image_url"].startswith("/static/products/"):
            img = client.get(p["image_url"])
            assert img.status_code == 200, p["image_url"]
            assert img.headers["content-type"] == "image/jpeg"


def test_static_image_cors_for_flutter_web():
    res = client.get("/static/products/americano.jpg", headers={"Origin": "http://localhost:8080"})
    assert res.status_code == 200
    assert res.headers.get("access-control-allow-origin") is not None


def test_transaction_variant_priced_by_backend():
    headers = _seller_headers()
    before = _seller_stock("prd-07")
    res = client.post("/api/v1/transactions", headers=headers, json={
        "seller_id": "usr-seller-01",
        "location_id": "loc-01",
        "payment_method": "CASH",
        "items": [{"product_id": "prd-07", "quantity": 2, "option_ids": ["large", "hot", "extra_shot"]}],
    })
    assert res.status_code == 200, res.text
    data = res.json()
    # Cappuccino 14000 + Large 3000 + Extra Shot 4000 = 21000/cup × 2
    assert data["total_amount"] == 42000
    item = data["items"][0]
    assert item["unit_price"] == 21000
    assert item["subtotal"] == 42000
    assert item["variant_label"] == "Large · Hot · Extra Shot"
    assert _seller_stock("prd-07") == before - 2


def test_transaction_multi_extras_accumulate():
    headers = _seller_headers()
    res = client.post("/api/v1/transactions", headers=headers, json={
        "seller_id": "usr-seller-01",
        "location_id": "loc-01",
        "payment_method": "CASH",
        "items": [{"product_id": "prd-01", "quantity": 1,
                   "option_ids": ["large", "ice", "extra_shot", "extra_milk", "extra_sugar"]}],
    })
    assert res.status_code == 200, res.text
    # 12000 + 3000 + 4000 + 3000 + 1000
    assert res.json()["total_amount"] == 23000
    assert res.json()["items"][0]["variant_label"] == "Large · Ice · Extra Shot · Extra Milk · Extra Sugar"


def test_transaction_legacy_without_options_unchanged():
    headers = _seller_headers()
    res = client.post("/api/v1/transactions", headers=headers, json={
        "seller_id": "usr-seller-01",
        "location_id": "loc-01",
        "payment_method": "CASH",
        "items": [{"product_id": "prd-02", "quantity": 1}],
    })
    assert res.status_code == 200, res.text
    data = res.json()
    assert data["total_amount"] == 12000
    assert data["items"][0]["variant_label"] is None


def test_invalid_options_rejected_and_stock_untouched():
    headers = _seller_headers()
    before = _seller_stock("prd-07")
    base = {
        "seller_id": "usr-seller-01",
        "location_id": "loc-01",
        "payment_method": "CASH",
    }

    # Dua pilihan pada grup single-select
    res = client.post("/api/v1/transactions", headers=headers, json={
        **base, "items": [{"product_id": "prd-07", "quantity": 1, "option_ids": ["large", "extra_large"]}],
    })
    assert res.status_code == 400

    # Opsi tidak dikenal
    res = client.post("/api/v1/transactions", headers=headers, json={
        **base, "items": [{"product_id": "prd-07", "quantity": 1, "option_ids": ["jumbo"]}],
    })
    assert res.status_code == 400

    # Opsi tidak ditawarkan untuk produk tsb (Matcha tanpa extra shot)
    res = client.post("/api/v1/transactions", headers=headers, json={
        **base, "items": [{"product_id": "prd-09", "quantity": 1, "option_ids": ["extra_shot"]}],
    })
    assert res.status_code == 400

    # Opsi duplikat
    res = client.post("/api/v1/transactions", headers=headers, json={
        **base, "items": [{"product_id": "prd-07", "quantity": 1, "option_ids": ["extra_shot", "extra_shot"]}],
    })
    assert res.status_code == 400

    assert _seller_stock("prd-07") == before


def test_idempotency_with_variants_no_double_stock():
    headers = _seller_headers()
    before = _seller_stock("prd-08")
    key = f"pos-preview-{uuid.uuid4().hex[:10]}"
    payload = {
        "seller_id": "usr-seller-01",
        "location_id": "loc-01",
        "payment_method": "CASH",
        "idempotency_key": key,
        "items": [{"product_id": "prd-08", "quantity": 3, "option_ids": ["extra_large", "ice"]}],
    }
    first = client.post("/api/v1/transactions", headers=headers, json=payload)
    second = client.post("/api/v1/transactions", headers=headers, json=payload)
    assert first.status_code == 200
    assert second.status_code == 200
    assert first.json()["id"] == second.json()["id"]
    # Cafe Latte 14000 + Extra Large 5000 = 19000 × 3
    assert first.json()["total_amount"] == 57000
    assert _seller_stock("prd-08") == before - 3
