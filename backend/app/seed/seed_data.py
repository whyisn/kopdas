"""
Seed Data & Migrasi Dataset Padang ke SQLite Single Source of Truth
Acuan: Dokumen Induk Bab 11, Kontrak Integrasi Bab 4, & Dataset Padang
Memuat:
- 4 Lokasi Padang (UNP, Khatib Sulaiman, Pasar Raya, Taplau)
- 6 Produk Resmi Minuman Padang (Coffee, Non-Coffee, Tea)
- 12.632 Transaksi historis dari dataset transactions.csv
- Transaksi riil masa kini (7 hari terakhir) untuk analitik operasional & baseline
- Data POI & Cuaca berlabel SIMULASI
"""
import datetime
import pathlib
import pandas as pd
from sqlalchemy.orm import Session
from sqlalchemy import text
from app.core.database import SessionLocal, engine, Base
from app.models import (
    User, UserRole, Category, Product, Location, Inventory,
    StockMovement, Transaction, TransactionItem, ExternalObservation,
    Order, OrderItem, PaymentEvent
)
from app.core.security import get_password_hash

DATA_DIR = pathlib.Path(__file__).resolve().parent.parent / "ai_engine" / "data"

def run_seed(force_reset: bool = False):
    Base.metadata.create_all(bind=engine)
    db: Session = SessionLocal()

    # Cek apakah dataset transaksi Padang sudah diimpor
    existing_tx_count = db.query(Transaction).count()
    if not force_reset and existing_tx_count >= 1000:
        db.close()
        return

    print("Memulai Migrasi Seed Data & Integrasi Dataset Padang...")

    if force_reset or existing_tx_count > 0:
        print("Membersihkan tabel database untuk migrasi bersih...")
        # Hapus data lama agar sinkron
        db.query(PaymentEvent).delete()
        db.query(OrderItem).delete()
        db.query(Order).delete()
        db.query(TransactionItem).delete()
        db.query(Transaction).delete()
        db.query(StockMovement).delete()
        db.query(Inventory).delete()
        db.query(ExternalObservation).delete()
        db.query(Location).delete()
        db.query(Product).delete()
        db.query(Category).delete()
        db.query(User).delete()
        db.commit()

    # 1. Users (Owner, Sellers Padang, Customer)
    hashed_pwd = get_password_hash("kopi123")
    users = [
        User(id="usr-owner-01", username="owner", name="Budi Santoso (Owner)", password_hash=hashed_pwd, role=UserRole.OWNER.value),
        User(id="usr-seller-01", username="seller1", name="Ahmad Fauzi (Seller UNP)", password_hash=hashed_pwd, role=UserRole.SELLER.value),
        User(id="usr-seller-02", username="seller2", name="Rian Syahputra (Seller Khatib Sulaiman)", password_hash=hashed_pwd, role=UserRole.SELLER.value),
        User(id="usr-seller-03", username="seller3", name="Fauzan Akbar (Seller Pasar Raya)", password_hash=hashed_pwd, role=UserRole.SELLER.value),
        User(id="usr-seller-04", username="seller4", name="Doni Pratama (Seller Taplau)", password_hash=hashed_pwd, role=UserRole.SELLER.value),
        User(id="usr-cust-01", username="customer", name="Maya Customer", password_hash=hashed_pwd, role=UserRole.CUSTOMER.value),
    ]
    db.add_all(users)

    # 2. Categories Padang (Coffee, Non-Coffee, Tea)
    cats = [
        Category(id="cat-01", name="Coffee", status="ACTIVE"),
        Category(id="cat-02", name="Non-Coffee", status="ACTIVE"),
        Category(id="cat-03", name="Tea", status="ACTIVE"),
    ]
    db.add_all(cats)

    # 3. Products Padang (6 Menu Utama)
    prods = [
        Product(id="prd-01", category_id="cat-01", name="Kopi Susu Aren", description="Espresso, susu segar, dan gula aren asli Padang", price=12000, cost_price=5000, status="ACTIVE"),
        Product(id="prd-02", category_id="cat-01", name="Americano", description="Espresso ganda air mineral dingin segar", price=12000, cost_price=4500, status="ACTIVE"),
        Product(id="prd-03", category_id="cat-02", name="Coklat", description="Coklat premium kental kaya rasa", price=12000, cost_price=5500, status="ACTIVE"),
        Product(id="prd-04", category_id="cat-02", name="Red Velvet", description="Red velvet lembut dengan foam susu gurih", price=12000, cost_price=5500, status="ACTIVE"),
        Product(id="prd-05", category_id="cat-03", name="Thai Tea", description="Teh rempah Thailand otentik dengan susu manis", price=8000, cost_price=3000, status="ACTIVE"),
        Product(id="prd-06", category_id="cat-03", name="Lemon Tea", description="Teh segar berpadu perasan sari lemon asli", price=8000, cost_price=3000, status="ACTIVE"),
    ]
    db.add_all(prods)

    # 4. Locations Padang (Koordinat resmi locations.csv)
    locs = [
        Location(
            id="loc-01", seller_id="usr-seller-01", name="Kampus UNP Air Tawar",
            latitude=-0.896, longitude=100.350, address="Jl. Prof. Dr. Hamka, Air Tawar, Padang Utara",
            source_type="ACTIVE_POINT", is_active=True
        ),
        Location(
            id="loc-02", seller_id="usr-seller-02", name="Perkantoran Khatib Sulaiman",
            latitude=-0.904, longitude=100.353, address="Jl. Khatib Sulaiman, Lolong Belanti, Padang Utara",
            source_type="ACTIVE_POINT", is_active=True
        ),
        Location(
            id="loc-03", seller_id="usr-seller-03", name="Pasar Raya Padang",
            latitude=-0.951, longitude=100.360, address="Jl. Sandang Pangan, Kampung Jao, Padang Barat",
            source_type="ACTIVE_POINT", is_active=True
        ),
        Location(
            id="loc-04", seller_id="usr-seller-04", name="Pantai Padang Taplau",
            latitude=-0.945, longitude=100.354, address="Jl. Samudera, Purus, Padang Barat",
            source_type="ACTIVE_POINT", is_active=True
        ),
    ]
    db.add_all(locs)

    # 5. Inventory: Gudang Pusat (Central) & Stok 4 Seller Resmi
    invs = []
    for p in prods:
        # Gudang Pusat: 1.000 cup per item
        invs.append(Inventory(id=f"inv-central-{p.id}", product_id=p.id, scope_type="WAREHOUSE", scope_id="central", quantity=1000, reserved_quantity=0))
        # Seller 1 (UNP Air Tawar): 50 cup per produk
        invs.append(Inventory(id=f"inv-seller1-{p.id}", product_id=p.id, scope_type="SELLER", scope_id="usr-seller-01", quantity=50, reserved_quantity=0))
        # Seller 2 (Khatib Sulaiman): 40 cup per produk
        invs.append(Inventory(id=f"inv-seller2-{p.id}", product_id=p.id, scope_type="SELLER", scope_id="usr-seller-02", quantity=40, reserved_quantity=0))
        # Seller 3 (Pasar Raya): 45 cup per produk
        invs.append(Inventory(id=f"inv-seller3-{p.id}", product_id=p.id, scope_type="SELLER", scope_id="usr-seller-03", quantity=45, reserved_quantity=0))
        # Seller 4 (Taplau): 55 cup per produk
        invs.append(Inventory(id=f"inv-seller4-{p.id}", product_id=p.id, scope_type="SELLER", scope_id="usr-seller-04", quantity=55, reserved_quantity=0))
    db.add_all(invs)

    # 6. Inbound Stock Movements Gudang
    for p in prods:
        db.add(StockMovement(
            id=f"mov-init-{p.id}", product_id=p.id, from_scope="SUPPLIER", to_scope="central",
            quantity=1000, movement_type="INBOUND", actor_id="usr-owner-01", notes="Inbound stok awal gudang pusat Padang"
        ))

    # 7. External Observations (POI untuk Location Scoring)
    obs = [
        ExternalObservation(id="obs-01", source="SIMULATED", location_id="loc-01", latitude=-0.896, longitude=100.350, metric="POI_COUNT", value="16", unit="places", data_label="SIMULASI"),
        ExternalObservation(id="obs-02", source="SIMULATED", location_id="loc-02", latitude=-0.904, longitude=100.353, metric="POI_COUNT", value="14", unit="places", data_label="SIMULASI"),
        ExternalObservation(id="obs-03", source="SIMULATED", location_id="loc-03", latitude=-0.951, longitude=100.360, metric="POI_COUNT", value="18", unit="places", data_label="SIMULASI"),
        ExternalObservation(id="obs-04", source="SIMULATED", location_id="loc-04", latitude=-0.945, longitude=100.354, metric="POI_COUNT", value="9", unit="places", data_label="SIMULASI"),
    ]
    db.add_all(obs)

    db.commit()

    # 8. Import 12.632 Transaksi Historis dari transactions.csv
    csv_path = DATA_DIR / "transactions.csv"
    if csv_path.exists():
        print(f"Membaca {csv_path.name}...")
        df_tx = pd.read_csv(csv_path)

        loc_map = {
            "Kampus UNP Air Tawar": ("loc-01", "usr-seller-01"),
            "Perkantoran Khatib Sulaiman": ("loc-02", "usr-seller-02"),
            "Pasar Raya Padang": ("loc-03", "usr-seller-03"),
            "Pantai Padang (Taplau)": ("loc-04", "usr-seller-04")
        }
        prod_map = {
            "Kopi Susu Aren": "prd-01",
            "Americano": "prd-02",
            "Coklat": "prd-03",
            "Red Velvet": "prd-04",
            "Thai Tea": "prd-05",
            "Lemon Tea": "prd-06"
        }

        tx_mappings = []
        txi_mappings = []

        for row in df_tx.itertuples(index=False):
            loc_id, seller_id = loc_map.get(row.lokasi, ("loc-01", "usr-seller-01"))
            prod_id = prod_map.get(row.produk, "prd-01")
            pay_method = "CASH" if str(row.metode_bayar).strip() == "Tunai" else "QRIS_STATIC"
            total = int(row.qty * row.harga)
            tx_time = datetime.datetime.fromisoformat(str(row.waktu))

            tx_mappings.append({
                "id": str(row.transaction_id),
                "seller_id": seller_id,
                "location_id": loc_id,
                "total_amount": total,
                "payment_method": pay_method,
                "payment_status": "PAID",
                "idempotency_key": f"seed-{row.transaction_id}",
                "created_at": tx_time
            })

            txi_mappings.append({
                "id": f"txi-{row.transaction_id}",
                "transaction_id": str(row.transaction_id),
                "product_id": prod_id,
                "quantity": int(row.qty),
                "unit_price": int(row.harga),
                "subtotal": total
            })

        print(f"Melakukan bulk insert {len(tx_mappings)} transaksi Padang...")
        db.bulk_insert_mappings(Transaction, tx_mappings)
        db.bulk_insert_mappings(TransactionItem, txi_mappings)
        db.commit()

    # 9. Tambahkan 48 Transaksi Aktif Terkini Tersinkronisasi (November 2026) untuk Demo Operasional
    now = datetime.datetime.utcnow()
    recent_txs = []
    recent_txis = []
    rec_idx = 1

    prod_catalog = [
        ("prd-01", 12000),  # Kopi Susu Aren
        ("prd-02", 12000),  # Americano
        ("prd-03", 12000),  # Coklat
        ("prd-04", 12000),  # Red Velvet
        ("prd-05", 8000),   # Thai Tea
        ("prd-06", 8000),   # Lemon Tea
    ]

    seller_configs = [
        ("usr-seller-01", "loc-01", "unp"),
        ("usr-seller-02", "loc-02", "khatib"),
        ("usr-seller-03", "loc-03", "pasarraya"),
        ("usr-seller-04", "loc-04", "taplau"),
    ]

    for s_idx, (s_id, l_id, s_code) in enumerate(seller_configs):
        for tx_num in range(1, 13):
            hours_ago = (12 - tx_num) * 5 + (s_idx * 1)
            tx_time = now - datetime.timedelta(hours=hours_ago)
            p_id, unit_p = prod_catalog[(tx_num + s_idx) % len(prod_catalog)]
            qty = 1 if tx_num % 3 == 0 else (2 if tx_num % 2 == 0 else 1)
            subtotal = qty * unit_p
            pay_method = "CASH" if tx_num % 2 == 1 else "QRIS_STATIC"
            t_id = f"tx-sync-{s_code}-{tx_num}"

            recent_txs.append({
                "id": t_id,
                "seller_id": s_id,
                "location_id": l_id,
                "total_amount": subtotal,
                "payment_method": pay_method,
                "payment_status": "PAID",
                "idempotency_key": f"sync-idem-{rec_idx}",
                "created_at": tx_time
            })
            recent_txis.append({
                "id": f"txi-sync-{rec_idx}",
                "transaction_id": t_id,
                "product_id": p_id,
                "quantity": qty,
                "unit_price": unit_p,
                "subtotal": subtotal
            })
            rec_idx += 1

    db.bulk_insert_mappings(Transaction, recent_txs)
    db.bulk_insert_mappings(TransactionItem, recent_txis)

    # 10. Tambahkan 4 Customer Pre-Order Aktif Terintegrasi
    sample_orders = [
        Order(
            id="ORD-9041", order_number="ORD-20261114-9041", customer_id="usr-cust-01", seller_id="usr-seller-01", location_id="loc-01",
            total_amount=24000, order_status="COMPLETED", payment_status="PAID", payment_method="QRIS_DYNAMIC",
            created_at=now - datetime.timedelta(hours=3)
        ),
        Order(
            id="ORD-9042", order_number="ORD-20261114-9042", customer_id="usr-cust-01", seller_id="usr-seller-01", location_id="loc-01",
            total_amount=24000, order_status="READY_FOR_PICKUP", payment_status="PAID", payment_method="QRIS_DYNAMIC",
            created_at=now - datetime.timedelta(hours=1, minutes=30)
        ),
        Order(
            id="ORD-9043", order_number="ORD-20261114-9043", customer_id="usr-cust-01", seller_id="usr-seller-02", location_id="loc-02",
            total_amount=20000, order_status="PREPARING", payment_status="PAID", payment_method="QRIS_DYNAMIC",
            created_at=now - datetime.timedelta(minutes=45)
        ),
        Order(
            id="ORD-9044", order_number="ORD-20261114-9044", customer_id="usr-cust-01", seller_id="usr-seller-04", location_id="loc-04",
            total_amount=16000, order_status="CONFIRMED", payment_status="PAID", payment_method="QRIS_DYNAMIC",
            created_at=now - datetime.timedelta(minutes=15)
        ),
    ]
    db.add_all(sample_orders)

    sample_order_items = [
        OrderItem(id="oi-9041-1", order_id="ORD-9041", product_id="prd-01", quantity=2, unit_price=12000, subtotal=24000),
        OrderItem(id="oi-9042-1", order_id="ORD-9042", product_id="prd-01", quantity=2, unit_price=12000, subtotal=24000),
        OrderItem(id="oi-9043-1", order_id="ORD-9043", product_id="prd-02", quantity=1, unit_price=12000, subtotal=12000),
        OrderItem(id="oi-9043-2", order_id="ORD-9043", product_id="prd-05", quantity=1, unit_price=8000, subtotal=8000),
        OrderItem(id="oi-9044-1", order_id="ORD-9044", product_id="prd-06", quantity=2, unit_price=8000, subtotal=16000),
    ]
    db.add_all(sample_order_items)
    db.commit()

    total_tx_final = db.query(Transaction).count()
    db.close()
    print(f"Migrasi Seed Data Padang Selesai! Total transaksi di database: {total_tx_final}")

if __name__ == "__main__":
    run_seed(force_reset=True)
