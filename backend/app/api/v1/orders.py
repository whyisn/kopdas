import datetime
import uuid
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.models import Order, OrderItem, Inventory, StockMovement, Product, User
from app.schemas import (
    OrderCreateRequest, OrderResponse, OrderItemResponse, OrderStatusUpdateRequest
)
from app.core.config import settings
from app.api.deps import get_optional_current_user

router = APIRouter(tags=["Pre-Orders & Orders"])

def _format_order(order: Order) -> OrderResponse:
    items = []
    for it in order.items:
        items.append(OrderItemResponse(
            id=it.id,
            product_id=it.product_id,
            product_name=it.product.name if it.product else it.product_id,
            quantity=it.quantity,
            unit_price=it.unit_price,
            subtotal=it.subtotal
        ))
    return OrderResponse(
        id=order.id,
        order_number=order.order_number,
        customer_id=order.customer_id,
        customer_name=order.customer_id or "Pelanggan",
        seller_id=order.seller_id,
        location_id=order.location_id,
        total_amount=order.total_amount,
        total=order.total_amount,
        order_status=order.order_status,
        payment_method=order.payment_method,
        payment_status=order.payment_status,
        qris_asset_url=order.qris_asset_url,
        created_at=order.created_at,
        expires_at=order.expires_at,
        data_label="REAL",
        items=items
    )

def _check_and_expire_order(order: Order, db: Session) -> bool:
    """
    Jika order masih PENDING dan telah melewati batas expires_at,
    ubah status menjadi EXPIRED dan lepaskan reservasi stok seller.
    """
    now = datetime.datetime.utcnow()
    if order.payment_status == "PENDING" and order.expires_at and order.expires_at < now:
        order.payment_status = "EXPIRED"
        order.order_status = "EXPIRED"

        for it in order.items:
            seller_inv = db.query(Inventory).filter(
                Inventory.scope_type == "SELLER",
                Inventory.scope_id == order.seller_id,
                Inventory.product_id == it.product_id
            ).first()
            if seller_inv:
                seller_inv.reserved_quantity = max(0, seller_inv.reserved_quantity - it.quantity)
                db.add(StockMovement(
                    id=f"mov-{uuid.uuid4().hex[:10]}",
                    product_id=it.product_id,
                    from_scope="RESERVATION",
                    to_scope=order.seller_id,
                    quantity=it.quantity,
                    movement_type="RESERVATION_RELEASE",
                    reference_id=order.id,
                    actor_id="SYSTEM_AUTO_EXPIRE",
                    notes=f"Pelepasan reservasi stok karena order {order.order_number} expired"
                ))
        db.commit()
        db.refresh(order)
        return True
    return False

def _process_order_creation(req: OrderCreateRequest, db: Session) -> OrderResponse:
    if not req.items:
        raise HTTPException(status_code=400, detail="Order minimal memuat 1 item")

    try:
        total_amount = 0
        order_items = []
        order_id = f"ord-{uuid.uuid4().hex[:10]}"
        order_num = f"KC-{datetime.datetime.utcnow().strftime('%y%m%d')}-{uuid.uuid4().hex[:4].upper()}"

        for item in req.items:
            prod = db.query(Product).filter(Product.id == item.product_id, Product.status == "ACTIVE").first()
            if not prod:
                raise HTTPException(status_code=404, detail=f"Produk {item.product_id} tidak valid")

            # Cek ketersediaan stok seller (quantity - reserved_quantity)
            seller_inv = db.query(Inventory).filter(
                Inventory.scope_type == "SELLER",
                Inventory.scope_id == req.seller_id,
                Inventory.product_id == item.product_id
            ).first()

            available = (seller_inv.quantity - seller_inv.reserved_quantity) if seller_inv else 0
            if available < item.quantity:
                raise HTTPException(
                    status_code=400,
                    detail=f"Stok produk '{prod.name}' tidak mencukupi untuk pre-order. Tersedia: {available} cup"
                )

            # Reservasi stok atomik jika tersedia
            if seller_inv:
                seller_inv.reserved_quantity += item.quantity

            subtotal = prod.price * item.quantity
            total_amount += subtotal

            order_items.append(OrderItem(
                id=f"oi-{uuid.uuid4().hex[:10]}",
                order_id=order_id,
                product_id=prod.id,
                quantity=item.quantity,
                unit_price=prod.price,
                subtotal=subtotal
            ))

        new_order = Order(
            id=order_id,
            order_number=order_num,
            customer_id=req.customer_id,
            seller_id=req.seller_id,
            location_id=req.location_id,
            total_amount=total_amount,
            order_status="PENDING_PAYMENT",
            payment_method="QRIS_STATIC",
            payment_status="PENDING",
            qris_asset_url=settings.QRIS_IMAGE_URL,
            expires_at=datetime.datetime.utcnow() + datetime.timedelta(minutes=30)
        )
        new_order.items = order_items

        db.add(new_order)
        db.commit()
        db.refresh(new_order)

        return _format_order(new_order)

    except HTTPException:
        db.rollback()
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Gagal membuat pesanan: {str(e)}")

# --- POST Endpoints (Customer Pre-Order Creation) ---
@router.post("/customer/orders", response_model=OrderResponse)
def create_customer_order(req: OrderCreateRequest, db: Session = Depends(get_db)):
    return _process_order_creation(req, db)

@router.post("/orders", response_model=OrderResponse)
def create_order_alias(req: OrderCreateRequest, db: Session = Depends(get_db)):
    return _process_order_creation(req, db)

# --- GET Endpoints (List Orders for Owner & Seller) ---
def _list_orders(
    seller_id: Optional[str],
    order_status: Optional[str],
    limit: int,
    current_user: Optional[User],
    db: Session
) -> List[OrderResponse]:
    query = db.query(Order)
    if current_user and current_user.role == "SELLER":
        if seller_id and seller_id != current_user.id:
            raise HTTPException(status_code=403, detail="Akses ditolak: Seller hanya dapat melihat order miliknya")
        seller_id = current_user.id

    if seller_id:
        query = query.filter(Order.seller_id == seller_id)
    if order_status:
        query = query.filter(Order.order_status == order_status)

    orders = query.order_by(Order.created_at.desc()).limit(limit).all()
    # Check expiry for each order
    for o in orders:
        _check_and_expire_order(o, db)

    return [_format_order(o) for o in orders]

@router.get("/customer/orders", response_model=List[OrderResponse])
def get_customer_orders(
    seller_id: Optional[str] = None,
    order_status: Optional[str] = None,
    limit: int = 50,
    current_user: Optional[User] = Depends(get_optional_current_user),
    db: Session = Depends(get_db)
):
    return _list_orders(seller_id, order_status, limit, current_user, db)

@router.get("/orders", response_model=List[OrderResponse])
def get_orders(
    seller_id: Optional[str] = None,
    order_status: Optional[str] = None,
    limit: int = 50,
    current_user: Optional[User] = Depends(get_optional_current_user),
    db: Session = Depends(get_db)
):
    return _list_orders(seller_id, order_status, limit, current_user, db)

# --- GET Single Order Status ---
def _get_single_order(order_id: str, db: Session) -> OrderResponse:
    order = db.query(Order).filter(Order.id == order_id).first()
    if not order:
        raise HTTPException(status_code=404, detail="Order tidak ditemukan")

    _check_and_expire_order(order, db)
    return _format_order(order)

@router.get("/customer/orders/{order_id}", response_model=OrderResponse)
def get_customer_order_status(order_id: str, db: Session = Depends(get_db)):
    return _get_single_order(order_id, db)

@router.get("/orders/{order_id}", response_model=OrderResponse)
def get_order_status(order_id: str, db: Session = Depends(get_db)):
    return _get_single_order(order_id, db)

# --- PATCH Order Status (Seller Lifecycle: PREPARING -> READY_FOR_PICKUP -> COMPLETED) ---
VALID_TRANSITIONS = {
    "CONFIRMED": ["PREPARING", "CANCELLED"],
    "PREPARING": ["READY_FOR_PICKUP", "CANCELLED"],
    "READY_FOR_PICKUP": ["COMPLETED", "CANCELLED"],
    "PENDING_PAYMENT": ["CANCELLED"]
}

def _update_order_status(
    order_id: str,
    req: OrderStatusUpdateRequest,
    current_user: Optional[User],
    db: Session
) -> OrderResponse:
    order = db.query(Order).filter(Order.id == order_id).first()
    if not order:
        raise HTTPException(status_code=404, detail="Order tidak ditemukan")

    if current_user and current_user.role == "SELLER" and order.seller_id != current_user.id:
        raise HTTPException(status_code=403, detail="Akses ditolak: Seller hanya dapat memproses order miliknya")

    _check_and_expire_order(order, db)
    if order.order_status in ["EXPIRED", "COMPLETED", "CANCELLED"]:
        raise HTTPException(
            status_code=400,
            detail=f"Order dengan status '{order.order_status}' sudah final dan tidak dapat diubah lagi."
        )

    allowed = VALID_TRANSITIONS.get(order.order_status, [])
    if req.status not in allowed:
        raise HTTPException(
            status_code=400,
            detail=f"Transisi status dari '{order.order_status}' ke '{req.status}' tidak diizinkan. Pilihan yang sah: {allowed}"
        )

    try:
        if req.status == "CANCELLED":
            # Jika belum dibayar: lepas reservasi stok
            if order.payment_status == "PENDING":
                order.payment_status = "REJECTED"
                order.order_status = "CANCELLED"
                for it in order.items:
                    seller_inv = db.query(Inventory).filter(
                        Inventory.scope_type == "SELLER",
                        Inventory.scope_id == order.seller_id,
                        Inventory.product_id == it.product_id
                    ).first()
                    if seller_inv:
                        seller_inv.reserved_quantity = max(0, seller_inv.reserved_quantity - it.quantity)
                        db.add(StockMovement(
                            id=f"mov-{uuid.uuid4().hex[:10]}",
                            product_id=it.product_id,
                            from_scope="RESERVATION",
                            to_scope=order.seller_id,
                            quantity=it.quantity,
                            movement_type="RESERVATION_RELEASE",
                            reference_id=order.id,
                            actor_id=current_user.id if current_user else "ORDER_CANCEL",
                            notes=f"Pelepasan reservasi karena order {order.order_number} dibatalkan sebelum dibayar"
                        ))
            elif order.payment_status == "PAID":
                # Jika sudah dibayar: kembalikan stok fisik seller dan refund
                order.payment_status = "REFUNDED"
                order.order_status = "CANCELLED"
                for it in order.items:
                    seller_inv = db.query(Inventory).filter(
                        Inventory.scope_type == "SELLER",
                        Inventory.scope_id == order.seller_id,
                        Inventory.product_id == it.product_id
                    ).first()
                    if seller_inv:
                        seller_inv.quantity += it.quantity
                        db.add(StockMovement(
                            id=f"mov-{uuid.uuid4().hex[:10]}",
                            product_id=it.product_id,
                            from_scope="CUSTOMER",
                            to_scope=order.seller_id,
                            quantity=it.quantity,
                            movement_type="RETURN",
                            reference_id=order.id,
                            actor_id=current_user.id if current_user else "ORDER_CANCEL",
                            notes=f"Pengembalian stok fisik karena order {order.order_number} dibatalkan setelah dibayar"
                        ))
        else:
            order.order_status = req.status

        db.commit()
        db.refresh(order)
        return _format_order(order)

    except HTTPException:
        db.rollback()
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Gagal memperbarui status order: {str(e)}")

@router.patch("/customer/orders/{order_id}/status", response_model=OrderResponse)
def update_customer_order_status(
    order_id: str,
    req: OrderStatusUpdateRequest,
    current_user: Optional[User] = Depends(get_optional_current_user),
    db: Session = Depends(get_db)
):
    return _update_order_status(order_id, req, current_user, db)

@router.patch("/orders/{order_id}/status", response_model=OrderResponse)
def update_order_status(
    order_id: str,
    req: OrderStatusUpdateRequest,
    current_user: Optional[User] = Depends(get_optional_current_user),
    db: Session = Depends(get_db)
):
    return _update_order_status(order_id, req, current_user, db)

# --- POST Order Cancel ---
@router.post("/customer/orders/{order_id}/cancel", response_model=OrderResponse)
def cancel_customer_order(
    order_id: str,
    current_user: Optional[User] = Depends(get_optional_current_user),
    db: Session = Depends(get_db)
):
    return _update_order_status(order_id, OrderStatusUpdateRequest(status="CANCELLED"), current_user, db)

@router.post("/orders/{order_id}/cancel", response_model=OrderResponse)
def cancel_order(
    order_id: str,
    current_user: Optional[User] = Depends(get_optional_current_user),
    db: Session = Depends(get_db)
):
    return _update_order_status(order_id, OrderStatusUpdateRequest(status="CANCELLED"), current_user, db)
