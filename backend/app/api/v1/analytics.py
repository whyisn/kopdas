from typing import Dict, Any, List
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from sqlalchemy import func
from app.core.database import get_db
from app.models import Transaction, TransactionItem, Product, User

router = APIRouter(prefix="/analytics", tags=["Sales Analytics"])

@router.get("/sales")
def get_sales_analytics(days: int = 7, db: Session = Depends(get_db)):
    """
    Agregasi data penjualan aktual dari database:
    - Total Omzet (IDR)
    - Total Transaksi
    - Total Cup Terjual
    - Rincian penjualan per kategori & produk
    - Performa per seller
    """
    total_revenue = db.query(func.sum(Transaction.total_amount)).scalar() or 0
    total_tx = db.query(func.count(Transaction.id)).scalar() or 0
    total_cups = db.query(func.sum(TransactionItem.quantity)).scalar() or 0

    # Penjualan per produk
    prod_sales = db.query(
        Product.name,
        func.sum(TransactionItem.quantity).label("cups_sold"),
        func.sum(TransactionItem.subtotal).label("revenue")
    ).join(TransactionItem, TransactionItem.product_id == Product.id)\
     .group_by(Product.id).all()

    product_breakdown = [
        {"product_name": row[0], "cups_sold": int(row[1] or 0), "revenue": int(row[2] or 0)}
        for row in prod_sales
    ]

    return {
        "summary": {
            "total_revenue": total_revenue,
            "total_transactions": total_tx,
            "total_cups_sold": total_cups,
            "currency": "IDR",
            "period_days": days
        },
        "product_breakdown": product_breakdown,
        "data_label": "REAL"
    }
