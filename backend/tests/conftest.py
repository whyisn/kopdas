import pytest
from app.core.database import SessionLocal
from app.models import Order

@pytest.fixture(autouse=True)
def clean_pending_orders():
    """
    Sebelum tiap fungsi tes dijalankan, tandai pending order sebelumnya sebagai EXPIRED
    agar isolasi pencocokan nominal QRIS antar tes terjaga bersih.
    """
    db = SessionLocal()
    try:
        for ord in db.query(Order).filter(Order.payment_status == "PENDING").all():
            ord.payment_status = "EXPIRED"
            ord.order_status = "EXPIRED"
        db.commit()
    finally:
        db.close()
    yield
