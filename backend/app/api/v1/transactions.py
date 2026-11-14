import datetime
import uuid
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.models import Transaction, TransactionItem, Inventory, StockMovement, Product, User
from app.schemas import TransactionCreateRequest, TransactionResponse, TransactionItemResponse
from app.api.deps import get_optional_current_user

router = APIRouter(prefix="/transactions", tags=["Transactions (Walk-in)"])

@router.post("", response_model=TransactionResponse)
def create_transaction(
    req: TransactionCreateRequest,
    current_user: Optional[User] = Depends(get_optional_current_user),
    db: Session = Depends(get_db)
):
    """
    Mencatat transaksi walk-in kasir seller.
    1. Cek otorisasi seller jika login.
    2. Cek idempotency key untuk cegah double submit.
    3. Validasi ketersediaan stok seller (quantity - reserved_quantity).
    4. Simpan transaksi dan kurangi stok tepat 1x dalam satu transaksi atomik.
    """
    # Enforce ownership: Seller hanya boleh mencatat transaksi untuk dirinya sendiri
    if current_user and current_user.role == "SELLER":
        if req.seller_id != current_user.id:
            raise HTTPException(
                status_code=403,
                detail=f"Akses ditolak: Seller '{current_user.id}' tidak berwenang mencatat transaksi untuk seller '{req.seller_id}'"
            )

    if req.idempotency_key:
        existing = db.query(Transaction).filter(Transaction.idempotency_key == req.idempotency_key).first()
        if existing:
            # Kembalikan transaksi yang sudah dicatat tanpa mengurangi stok lagi
            return _format_tx(existing)

    if not req.items:
        raise HTTPException(status_code=400, detail="Transaksi harus memuat minimal 1 item")

    try:
        total_amount = 0
        tx_items = []
        stock_movements = []

        tx_id = f"tx-{uuid.uuid4().hex[:12]}"

        for item in req.items:
            # Validasi produk & harga aktual dari database (tidak percaya frontend)
            prod = db.query(Product).filter(Product.id == item.product_id, Product.status == "ACTIVE").first()
            if not prod:
                raise HTTPException(status_code=404, detail=f"Produk {item.product_id} tidak ditemukan atau non-aktif")

            # Cek stok seller (harus memperhitungkan stok fisik dikurangi reservasi pre-order)
            seller_inv = db.query(Inventory).filter(
                Inventory.scope_type == "SELLER",
                Inventory.scope_id == req.seller_id,
                Inventory.product_id == item.product_id
            ).first()

            available_qty = (seller_inv.quantity - seller_inv.reserved_quantity) if seller_inv else 0
            if not seller_inv or available_qty < item.quantity:
                raise HTTPException(
                    status_code=400,
                    detail=f"Stok tidak mencukupi untuk '{prod.name}'. Tersedia untuk walk-in: {available_qty} cup (Fisik: {seller_inv.quantity if seller_inv else 0}, Direservasi: {seller_inv.reserved_quantity if seller_inv else 0}), Diminta: {item.quantity}"
                )

            # Kurangi stok fisik tepat 1x
            seller_inv.quantity -= item.quantity

            # Subtotal dihitung backend
            subtotal = prod.price * item.quantity
            total_amount += subtotal

            # Item transaksi
            txi = TransactionItem(
                id=f"txi-{uuid.uuid4().hex[:10]}",
                transaction_id=tx_id,
                product_id=prod.id,
                quantity=item.quantity,
                unit_price=prod.price,
                subtotal=subtotal
            )
            txi.product = prod
            tx_items.append(txi)

            # Catat mutasi stok
            stock_movements.append(StockMovement(
                id=f"mov-{uuid.uuid4().hex[:10]}",
                product_id=prod.id,
                from_scope=req.seller_id,
                to_scope="CUSTOMER",
                quantity=item.quantity,
                movement_type="SALE",
                reference_id=tx_id,
                actor_id=req.seller_id,
                notes=f"Penjualan walk-in ({req.payment_method})"
            ))

        new_tx = Transaction(
            id=tx_id,
            seller_id=req.seller_id,
            location_id=req.location_id,
            total_amount=total_amount,
            payment_method=req.payment_method,
            payment_status="PAID",
            idempotency_key=req.idempotency_key,
            created_at=datetime.datetime.utcnow()
        )
        new_tx.items = tx_items

        db.add(new_tx)
        db.add_all(stock_movements)
        db.commit()
        db.refresh(new_tx)

        return _format_tx(new_tx)

    except HTTPException:
        db.rollback()
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Gagal mencatat transaksi: {str(e)}")

@router.get("", response_model=List[TransactionResponse])
def get_transactions(
    seller_id: str = None,
    limit: int = 50,
    current_user: Optional[User] = Depends(get_optional_current_user),
    db: Session = Depends(get_db)
):
    query = db.query(Transaction)
    if current_user and current_user.role == "SELLER":
        if seller_id and seller_id != current_user.id:
            raise HTTPException(
                status_code=403,
                detail="Akses ditolak: Seller hanya dapat melihat transaksinya sendiri"
            )
        seller_id = current_user.id

    if seller_id:
        query = query.filter(Transaction.seller_id == seller_id)
    txs = query.order_by(Transaction.created_at.desc()).limit(limit).all()
    return [_format_tx(t) for t in txs]

def _format_tx(tx: Transaction) -> TransactionResponse:
    items = []
    for it in tx.items:
        items.append(TransactionItemResponse(
            id=it.id,
            product_id=it.product_id,
            product_name=it.product.name if it.product else it.product_id,
            quantity=it.quantity,
            unit_price=it.unit_price,
            subtotal=it.subtotal
        ))
    return TransactionResponse(
        id=tx.id,
        seller_id=tx.seller_id,
        location_id=tx.location_id,
        total_amount=tx.total_amount,
        total=tx.total_amount,
        payment_method=tx.payment_method,
        payment_status=tx.payment_status,
        created_at=tx.created_at,
        items=items
    )
