import datetime
import uuid
from typing import List
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.models import Order, OrderItem, Inventory, Product
from app.schemas import OrderCreateRequest, OrderResponse, OrderItemRequest
from app.core.config import settings

router = APIRouter(prefix="/customer/orders", tags=["Pre-Orders (Customer)"])

@router.post("", response_model=OrderResponse)
def create_order(req: OrderCreateRequest, db: Session = Depends(get_db)):
    """
    Customer membuat pre-order dengan pembayaran QRIS Statis.
    Status order: PENDING_PAYMENT, Status payment: PENDING.
    """
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

            # Cek ketersediaan stok seller
            seller_inv = db.query(Inventory).filter(
                Inventory.scope_type == "SELLER",
                Inventory.scope_id == req.seller_id,
                Inventory.product_id == item.product_id
            ).first()

            available = (seller_inv.quantity - seller_inv.reserved_quantity) if seller_inv else 0
            if available < item.quantity:
                raise HTTPException(
                    status_code=400,
                    detail=f"Stok produk '{prod.name}' tidak mencukupi untuk pre-order. Tersedia: {available}"
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

        return OrderResponse(
            id=new_order.id,
            order_number=new_order.order_number,
            customer_id=new_order.customer_id,
            seller_id=new_order.seller_id,
            location_id=new_order.location_id,
            total_amount=new_order.total_amount,
            order_status=new_order.order_status,
            payment_method=new_order.payment_method,
            payment_status=new_order.payment_status,
            qris_asset_url=new_order.qris_asset_url,
            created_at=new_order.created_at,
            expires_at=new_order.expires_at,
            data_label="REAL"
        )

    except HTTPException:
        db.rollback()
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Gagal membuat pesanan: {str(e)}")

@router.get("/{order_id}", response_model=OrderResponse)
def get_order_status(order_id: str, db: Session = Depends(get_db)):
    order = db.query(Order).filter(Order.id == order_id).first()
    if not order:
        raise HTTPException(status_code=404, detail="Order tidak ditemukan")

    return OrderResponse(
        id=order.id,
        order_number=order.order_number,
        customer_id=order.customer_id,
        seller_id=order.seller_id,
        location_id=order.location_id,
        total_amount=order.total_amount,
        order_status=order.order_status,
        payment_method=order.payment_method,
        payment_status=order.payment_status,
        qris_asset_url=order.qris_asset_url,
        created_at=order.created_at,
        expires_at=order.expires_at,
        data_label="REAL"
    )
