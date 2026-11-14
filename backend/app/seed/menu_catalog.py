"""Katalog menu kasir: gambar produk & grup varian (ukuran/penyajian/tambahan).

Dipakai saat startup untuk memperkaya database yang sudah ada secara aditif:
- Produk lama hanya diisi image_url/options bila masih kosong (tidak ditimpa).
- Produk baru ditambahkan beserta stok gudang & seller mengikuti pola seed.
Tidak ada penghapusan/perubahan harga produk lama.
"""
import json

from sqlalchemy.orm import Session

from app.models import Category, Inventory, Product

_SIZE = {
    "id": "size",
    "name": "Ukuran",
    "multi": False,
    "choices": [
        {"id": "regular", "name": "Regular", "price_delta": 0},
        {"id": "large", "name": "Large", "price_delta": 3000},
        {"id": "extra_large", "name": "Extra Large", "price_delta": 5000},
    ],
}


def _serving(hot_first: bool = False) -> dict:
    choices = [
        {"id": "hot", "name": "Hot", "price_delta": 0},
        {"id": "ice", "name": "Ice", "price_delta": 0},
    ]
    if not hot_first:
        choices.reverse()
    return {"id": "serving", "name": "Penyajian", "multi": False, "choices": choices}


def _extras(*ids: str) -> dict:
    catalog = {
        "extra_shot": {"id": "extra_shot", "name": "Extra Shot", "price_delta": 4000},
        "extra_milk": {"id": "extra_milk", "name": "Extra Milk", "price_delta": 3000},
        "extra_sugar": {"id": "extra_sugar", "name": "Extra Sugar", "price_delta": 1000},
    }
    return {
        "id": "extras",
        "name": "Tambahan",
        "multi": True,
        "choices": [catalog[i] for i in ids],
    }


def _options(hot_first: bool, *extra_ids: str) -> list:
    return [_SIZE, _serving(hot_first), _extras(*extra_ids)]


# image_url relatif terhadap origin backend (disajikan dari /static).
MENU_CATALOG = [
    {
        "id": "prd-01", "category_id": "cat-01", "name": "Kopi Susu Aren",
        "description": "Espresso, susu segar, dan gula aren asli Padang",
        "price": 12000, "cost_price": 5000,
        "image_url": "/static/products/es-kopi-susu.jpg",
        "options": _options(False, "extra_shot", "extra_milk", "extra_sugar"),
    },
    {
        "id": "prd-02", "category_id": "cat-01", "name": "Americano",
        "description": "Espresso ganda air mineral dingin segar",
        "price": 12000, "cost_price": 4500,
        "image_url": "/static/products/americano.jpg",
        "options": _options(False, "extra_shot", "extra_sugar"),
    },
    {
        "id": "prd-03", "category_id": "cat-02", "name": "Coklat",
        "description": "Coklat premium kental kaya rasa",
        "price": 12000, "cost_price": 5500,
        "image_url": "/static/products/chocolate.jpg",
        "options": _options(False, "extra_milk", "extra_sugar"),
    },
    {
        "id": "prd-04", "category_id": "cat-02", "name": "Red Velvet",
        "description": "Red velvet lembut dengan foam susu gurih",
        "price": 12000, "cost_price": 5500,
        "image_url": "/static/products/red-velvet.jpg",
        "options": _options(False, "extra_milk", "extra_sugar"),
    },
    {
        "id": "prd-05", "category_id": "cat-03", "name": "Thai Tea",
        "description": "Teh rempah Thailand otentik dengan susu manis",
        "price": 8000, "cost_price": 3000,
        "image_url": "/static/products/thai-tea.jpg",
        "options": _options(False, "extra_milk", "extra_sugar"),
    },
    {
        "id": "prd-06", "category_id": "cat-03", "name": "Lemon Tea",
        "description": "Teh segar berpadu perasan sari lemon asli",
        "price": 8000, "cost_price": 3000,
        "image_url": "/static/products/lemon-tea.jpg",
        "options": _options(False, "extra_sugar"),
    },
    {
        "id": "prd-07", "category_id": "cat-01", "name": "Cappuccino",
        "description": "Espresso dengan steamed milk dan foam tebal yang lembut",
        "price": 14000, "cost_price": 6000,
        "image_url": "/static/products/cappuccino.jpg",
        "options": _options(True, "extra_shot", "extra_milk", "extra_sugar"),
    },
    {
        "id": "prd-08", "category_id": "cat-01", "name": "Cafe Latte",
        "description": "Espresso lembut berpadu susu segar creamy dengan latte art",
        "price": 14000, "cost_price": 6000,
        "image_url": "/static/products/cafe-latte.jpg",
        "options": _options(True, "extra_shot", "extra_milk", "extra_sugar"),
    },
    {
        "id": "prd-09", "category_id": "cat-02", "name": "Matcha Latte",
        "description": "Matcha premium Jepang berpadu susu segar, earthy dan creamy",
        "price": 16000, "cost_price": 7000,
        "image_url": "/static/products/matcha-latte.jpg",
        "options": _options(False, "extra_milk", "extra_sugar"),
    },
    {
        "id": "prd-10", "category_id": "cat-01", "name": "Caramel Macchiato",
        "description": "Susu vanilla, espresso, dan saus karamel berlapis menggoda",
        "price": 17000, "cost_price": 7000,
        "image_url": "/static/products/caramel-macchiato.jpg",
        "options": _options(False, "extra_shot", "extra_milk", "extra_sugar"),
    },
    {
        "id": "prd-11", "category_id": "cat-01", "name": "Vanilla Latte",
        "description": "Latte creamy dengan sirup vanilla yang harum dan manis seimbang",
        "price": 15000, "cost_price": 6500,
        "image_url": "/static/products/vanilla-latte.jpg",
        "options": _options(False, "extra_shot", "extra_milk", "extra_sugar"),
    },
]

# Stok awal produk baru mengikuti pola seed_data (gudang pusat + 2 seller aktif).
_INITIAL_STOCK = [
    ("WAREHOUSE", "central", 1000),
    ("SELLER", "usr-seller-01", 50),
    ("SELLER", "usr-seller-02", 40),
]


def apply_menu_upgrade(db: Session) -> None:
    changed = False
    for entry in MENU_CATALOG:
        prod = db.query(Product).filter(Product.id == entry["id"]).first()
        if prod is None:
            if db.query(Category).filter(Category.id == entry["category_id"]).first() is None:
                continue
            prod = Product(
                id=entry["id"],
                category_id=entry["category_id"],
                name=entry["name"],
                description=entry["description"],
                price=entry["price"],
                cost_price=entry["cost_price"],
                status="ACTIVE",
                image_url=entry["image_url"],
                options=json.dumps(entry["options"], ensure_ascii=False),
            )
            db.add(prod)
            for scope_type, scope_id, qty in _INITIAL_STOCK:
                inv_id = f"inv-{scope_id}-{entry['id']}"
                exists = db.query(Inventory).filter(
                    Inventory.product_id == entry["id"],
                    Inventory.scope_type == scope_type,
                    Inventory.scope_id == scope_id,
                ).first()
                if exists is None:
                    db.add(Inventory(
                        id=inv_id, product_id=entry["id"],
                        scope_type=scope_type, scope_id=scope_id,
                        quantity=qty, reserved_quantity=0,
                    ))
            changed = True
            print(f"Menu upgrade: produk baru '{entry['name']}' ditambahkan")
        else:
            if not prod.image_url:
                prod.image_url = entry["image_url"]
                changed = True
            if not prod.options:
                prod.options = json.dumps(entry["options"], ensure_ascii=False)
                changed = True
    if changed:
        db.commit()
