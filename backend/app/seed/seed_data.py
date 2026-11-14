import datetime
from sqlalchemy.orm import Session
from app.core.database import SessionLocal, engine, Base
from app.models import (
    User, UserRole, Category, Product, Location, Inventory,
    StockMovement, Transaction, TransactionItem, ExternalObservation
)
from app.core.security import get_password_hash

def run_seed():
    Base.metadata.create_all(bind=engine)
    db: Session = SessionLocal()

    # Cek apakah sudah ada data
    if db.query(User).first():
        db.close()
        return

    print("Membuat Seed Data Demo KopiCerdas AI...")

    # 1. Users
    users = [
        User(id="usr-owner-01", username="owner", name="Budi Owner", password_hash=get_password_hash("kopi123"), role=UserRole.OWNER.value),
        User(id="usr-seller-01", username="seller1", name="Ahmad Seller Sudirman", password_hash=get_password_hash("kopi123"), role=UserRole.SELLER.value),
        User(id="usr-seller-02", username="seller2", name="Rian Seller Salemba", password_hash=get_password_hash("kopi123"), role=UserRole.SELLER.value),
        User(id="usr-cust-01", username="customer", name="Maya Customer", password_hash=get_password_hash("kopi123"), role=UserRole.CUSTOMER.value),
    ]
    db.add_all(users)

    # 2. Categories
    cats = [
        Category(id="cat-01", name="Kopi Susu Spesial", status="ACTIVE"),
        Category(id="cat-02", name="Black Coffee", status="ACTIVE"),
        Category(id="cat-03", name="Non-Coffee", status="ACTIVE"),
    ]
    db.add_all(cats)

    # 3. Products
    prods = [
        Product(id="prd-01", category_id="cat-01", name="Kopi Susu Gula Aren", description="Espresso, susu segar, dan gula aren organik", price=18000, cost_price=8000, status="ACTIVE"),
        Product(id="prd-02", category_id="cat-02", name="Americano Dingin", description="Espresso ganda dengan air dingin dan es", price=15000, cost_price=5000, status="ACTIVE"),
        Product(id="prd-03", category_id="cat-03", name="Matcha Latte", description="Matcha murni Jepang dengan steamed milk", price=20000, cost_price=9000, status="ACTIVE"),
        Product(id="prd-04", category_id="cat-01", name="Kopi Cerdas Signature", description="Espresso blend rahasia dengan sentuhan kayu manis", price=22000, cost_price=10000, status="ACTIVE"),
    ]
    db.add_all(prods)

    # 4. Locations
    locs = [
        Location(id="loc-01", seller_id="usr-seller-01", name="Stasiun Sudirman Pintu Barat", latitude=-6.2024, longitude=106.8227, address="Jl. Kendal No. 1, Menteng", source_type="ACTIVE_POINT", is_active=True),
        Location(id="loc-02", seller_id="usr-seller-02", name="Kampus Salemba UI", latitude=-6.1952, longitude=106.8502, address="Jl. Salemba Raya No. 4", source_type="ACTIVE_POINT", is_active=True),
        Location(id="loc-03", seller_id=None, name="SCBD Lot 8 (Kandidat)", latitude=-6.2255, longitude=106.8095, address="Kawasan Niaga Terpadu Sudirman", source_type="CANDIDATE", is_active=True),
        Location(id="loc-04", seller_id=None, name="Taman Menteng (Kandidat)", latitude=-6.1963, longitude=106.8291, address="Jl. HOS. Cokroaminoto", source_type="CANDIDATE", is_active=True),
    ]
    db.add_all(locs)

    # 5. Inventory
    # Gudang Pusat (Central)
    invs = []
    for p in prods:
        invs.append(Inventory(id=f"inv-central-{p.id}", product_id=p.id, scope_type="WAREHOUSE", scope_id="central", quantity=500, reserved_quantity=0))
        # Seller 1 Stock
        invs.append(Inventory(id=f"inv-seller1-{p.id}", product_id=p.id, scope_type="SELLER", scope_id="usr-seller-01", quantity=45, reserved_quantity=0))
        # Seller 2 Stock
        invs.append(Inventory(id=f"inv-seller2-{p.id}", product_id=p.id, scope_type="SELLER", scope_id="usr-seller-02", quantity=35, reserved_quantity=0))
    db.add_all(invs)

    # 6. Sample Initial Stock Movements
    for p in prods:
        db.add(StockMovement(
            id=f"mov-init-{p.id}", product_id=p.id, from_scope="SUPPLIER", to_scope="central",
            quantity=500, movement_type="INBOUND", actor_id="usr-owner-01", notes="Inbound stok awal gudang"
        ))

    # 7. Sample External Observations (Label SIMULASI)
    obs = [
        ExternalObservation(id="obs-01", source="SIMULATED", location_id="loc-01", latitude=-6.2024, longitude=106.8227, metric="POI_COUNT", value="12", unit="places", data_label="SIMULASI"),
        ExternalObservation(id="obs-02", source="SIMULATED", location_id="loc-03", latitude=-6.2255, longitude=106.8095, metric="POI_COUNT", value="18", unit="places", data_label="SIMULASI"),
        ExternalObservation(id="obs-03", source="SIMULATED", location_id="loc-04", latitude=-6.1963, longitude=106.8291, metric="POI_COUNT", value="6", unit="places", data_label="SIMULASI"),
    ]
    db.add_all(obs)

    # 8. Sample Past Transactions for History & Forecast Baseline
    now = datetime.datetime.utcnow()
    for d in range(7, 0, -1):
        tx_date = now - datetime.timedelta(days=d)
        t = Transaction(
            id=f"tx-sample-d{d}", seller_id="usr-seller-01", location_id="loc-01",
            total_amount=36000, payment_method="CASH", payment_status="PAID",
            idempotency_key=f"seed-tx-{d}", created_at=tx_date
        )
        db.add(t)
        db.add(TransactionItem(id=f"txi-sample-d{d}", transaction_id=t.id, product_id="prd-01", quantity=2, unit_price=18000, subtotal=36000))

    db.commit()
    db.close()
    print("Seed Data selesai dimuat.")

if __name__ == "__main__":
    run_seed()
