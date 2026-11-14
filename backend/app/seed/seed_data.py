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
            id="loc-03", seller_id=None, name="Pasar Raya Padang (Kandidat)",
            latitude=-0.951, longitude=100.360, address="Jl. Sandang Pangan, Kampung Jao, Padang Barat",
            source_type="CANDIDATE", is_active=False
        ),
        Location(
            id="loc-04", seller_id=None, name="Pantai Padang Taplau (Kandidat)",
            latitude=-0.945, longitude=100.354, address="Jl. Samudera, Purus, Padang Barat",
            source_type="CANDIDATE", is_active=False
        ),
    ]
    db.add_all(locs)

    # 5. Inventory: Gudang Pusat (Central) & Stok Seller
    invs = []
    for p in prods:
        # Gudang Pusat: 1.000 cup per item
        invs.append(Inventory(id=f"inv-central-{p.id}", product_id=p.id, scope_type="WAREHOUSE", scope_id="central", quantity=1000, reserved_quantity=0))
        # Seller 1 (UNP): 50 cup per produk
        invs.append(Inventory(id=f"inv-seller1-{p.id}", product_id=p.id, scope_type="SELLER", scope_id="usr-seller-01", quantity=50, reserved_quantity=0))
        # Seller 2 (Khatib Sulaiman): 40 cup per produk
        invs.append(Inventory(id=f"inv-seller2-{p.id}", product_id=p.id, scope_type="SELLER", scope_id="usr-seller-02", quantity=40, reserved_quantity=0))
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

    # 9. Tambahkan Transaksi Aktif 7 Hari Terakhir (November 8 - 14, 2026) untuk Demo Operasional
    now = datetime.datetime.utcnow()
    recent_txs = []
    recent_txis = []
    rec_idx = 1
    for d in range(7, 0, -1):
        dt = now - datetime.timedelta(days=d, hours=3)
        # Transaksi UNP
        t_id1 = f"tx-recent-unp-{d}"
        recent_txs.append({
            "id": t_id1, "seller_id": "usr-seller-01", "location_id": "loc-01",
            "total_amount": 24000, "payment_method": "CASH", "payment_status": "PAID",
            "idempotency_key": f"rec-idem-{rec_idx}", "created_at": dt
        })
        recent_txis.append({
            "id": f"txi-rec-{rec_idx}", "transaction_id": t_id1,
            "product_id": "prd-01", "quantity": 2, "unit_price": 12000, "subtotal": 24000
        })
        rec_idx += 1

        # Transaksi Khatib Sulaiman
        t_id2 = f"tx-recent-khatib-{d}"
        dt2 = now - datetime.timedelta(days=d, hours=2)
        recent_txs.append({
            "id": t_id2, "seller_id": "usr-seller-02", "location_id": "loc-02",
            "total_amount": 24000, "payment_method": "QRIS_STATIC", "payment_status": "PAID",
            "idempotency_key": f"rec-idem-{rec_idx}", "created_at": dt2
        })
        recent_txis.append({
            "id": f"txi-rec-{rec_idx}", "transaction_id": t_id2,
            "product_id": "prd-02", "quantity": 2, "unit_price": 12000, "subtotal": 24000
        })
        rec_idx += 1

    db.bulk_insert_mappings(Transaction, recent_txs)
    db.bulk_insert_mappings(TransactionItem, recent_txis)
    db.commit()

    total_tx_final = db.query(Transaction).count()
    db.close()
    print(f"Migrasi Seed Data Padang Selesai! Total transaksi di database: {total_tx_final}")

if __name__ == "__main__":
    run_seed(force_reset=True)
