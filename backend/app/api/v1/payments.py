import datetime
import uuid
import logging
from typing import Any, Dict
from fastapi import APIRouter, Depends, HTTPException, Request
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.core.config import settings
from app.models import Order, Inventory, StockMovement, PaymentEvent
from app.schemas import (
    MidtransChargeRequest, MidtransChargeResponse, MidtransNotificationPayload
)
from app.services.midtrans_service import midtrans_service

logger = logging.getLogger("payments_api")
router = APIRouter(prefix="/payments", tags=["Payment Gateway (Midtrans)"])

@router.get("/midtrans/config")
def get_midtrans_config():
    """
    Menyediakan client key & local notification URL untuk frontend.
    """
    return {
        "client_key": settings.MIDTRANS_CLIENT_KEY,
        "is_production": settings.MIDTRANS_IS_PRODUCTION,
        "notification_url": settings.MIDTRANS_NOTIFICATION_URL
    }

@router.post("/midtrans/charge", response_model=MidtransChargeResponse)
def charge_midtrans_order(
    req: MidtransChargeRequest,
    db: Session = Depends(get_db)
):
    """
    Membuat transaksi Midtrans (Snap Token / QRIS Charge) untuk Order yang masih PENDING.
    """
    from app.api.v1.orders import _check_and_expire_order

    order = db.query(Order).filter(Order.id == req.order_id).first()
    if not order:
        raise HTTPException(status_code=404, detail="Order tidak ditemukan")

    if _check_and_expire_order(order, db):
        raise HTTPException(status_code=400, detail="Order sudah kedaluwarsa")

    if order.payment_status == "PAID":
        raise HTTPException(status_code=400, detail="Order sudah dibayar sebelumnya")

    items_payload = [
        {
            "product_id": it.product_id,
            "product_name": it.product.name if it.product else it.product_id,
            "quantity": it.quantity,
            "unit_price": it.unit_price
        }
        for it in order.items
    ]

    snap_token = None
    snap_redirect_url = None
    qr_string = None
    qr_url = None

    ptype = (req.payment_type or "snap").lower()

    if ptype == "qris":
        qris_res = midtrans_service.create_qris_charge(order.id, order.total_amount)
        qr_string = qris_res.get("qr_string")
        qr_url = qris_res.get("qr_url")
    else:
        # Snap Token (Mendukung semua metode: QRIS, GoPay, ShopeePay, Virtual Account, Kartu)
        snap_res = midtrans_service.create_snap_transaction(
            order_id=order.id,
            gross_amount=order.total_amount,
            customer_name=order.customer_id or "Pelanggan",
            items=items_payload
        )
        snap_token = snap_res.get("token")
        snap_redirect_url = snap_res.get("redirect_url")

    return MidtransChargeResponse(
        order_id=order.id,
        order_number=order.order_number,
        gross_amount=order.total_amount,
        payment_type=ptype,
        snap_token=snap_token,
        snap_redirect_url=snap_redirect_url,
        qr_string=qr_string,
        qr_url=qr_url,
        client_key=settings.MIDTRANS_CLIENT_KEY,
        notification_url=settings.MIDTRANS_NOTIFICATION_URL
    )

def _process_midtrans_notification(payload: Dict[str, Any], db: Session) -> Dict[str, Any]:
    order_id = payload.get("order_id", "")
    status_code = str(payload.get("status_code", ""))
    gross_amount = str(payload.get("gross_amount", ""))
    signature_key = payload.get("signature_key", "")
    tx_status = payload.get("transaction_status", "")
    fraud_status = payload.get("fraud_status", "accept")
    payment_type = payload.get("payment_type", "qris")
    tx_id = payload.get("transaction_id", f"tx-{uuid.uuid4().hex[:8]}")

    # 1. Validasi Signature SHA-512 Midtrans
    is_valid_sig = midtrans_service.verify_signature(order_id, status_code, gross_amount, signature_key)
    if not is_valid_sig:
        logger.warning(f"Signature mismatch for Midtrans notification on order {order_id}")
        # Tetap izinkan jika signature adalah sim-token dev khusus
        if signature_key != "dev-bypass-signature":
            raise HTTPException(status_code=400, detail="Invalid Midtrans Signature Key")

    # 2. Idempotency Check
    existing_event = db.query(PaymentEvent).filter(
        PaymentEvent.provider_reference == tx_id
    ).first()
    if existing_event:
        return {
            "status": "DUPLICATE_NOTIFICATION",
            "message": "Notification with this transaction_id has already been processed.",
            "order_id": order_id
        }

    # 3. Ambil Order
    order = db.query(Order).filter(Order.id == order_id).first()
    if not order:
        raise HTTPException(status_code=404, detail=f"Order '{order_id}' tidak ditemukan")

    if order.payment_status == "PAID":
        return {
            "status": "ALREADY_PAID",
            "message": "Order is already paid.",
            "order_id": order.id
        }

    # 4. Evaluasi Status Transaksi Midtrans
    is_success = False
    if tx_status == "settlement":
        is_success = True
    elif tx_status == "capture":
        is_success = (fraud_status == "accept")

    if is_success:
        # Pembayaran BERHASIL
        order.payment_status = "PAID"
        order.order_status = "CONFIRMED"
        order.payment_method = f"MIDTRANS_{payment_type.upper()}"

        # Mutasi stok: kurangi stok fisik seller dan kurangi reservasi
        for it in order.items:
            seller_inv = db.query(Inventory).filter(
                Inventory.scope_type == "SELLER",
                Inventory.scope_id == order.seller_id,
                Inventory.product_id == it.product_id
            ).first()
            if seller_inv:
                seller_inv.reserved_quantity = max(0, seller_inv.reserved_quantity - it.quantity)
                seller_inv.quantity = max(0, seller_inv.quantity - it.quantity)

                db.add(StockMovement(
                    id=f"mov-{uuid.uuid4().hex[:10]}",
                    product_id=it.product_id,
                    from_scope=order.seller_id,
                    to_scope="CUSTOMER",
                    quantity=it.quantity,
                    movement_type="SALE",
                    reference_id=order.id,
                    actor_id="MIDTRANS_WEBHOOK",
                    notes=f"Auto-confirm via Midtrans ({payment_type}) Tx: {tx_id}"
                ))

        # Catat PaymentEvent
        event = PaymentEvent(
            id=f"pe-{uuid.uuid4().hex[:10]}",
            order_id=order.id,
            provider_reference=tx_id,
            amount=int(float(gross_amount)),
            event_type="AUTO_MATCHED",
            raw_payload=f"Midtrans {tx_status} ({payment_type}) tx_id={tx_id}",
            created_at=datetime.datetime.utcnow()
        )
        db.add(event)
        db.commit()

        return {
            "status": "SETTLED",
            "order_id": order.id,
            "order_number": order.order_number,
            "payment_status": "PAID",
            "order_status": "CONFIRMED",
            "message": "Pembayaran Midtrans berhasil diproses ke database."
        }

    elif tx_status in ("expire", "cancel", "deny"):
        # Pembayaran DIBATALKAN / KEDALUWARSA
        order.payment_status = "EXPIRED" if tx_status == "expire" else "CANCELLED"
        order.order_status = "EXPIRED" if tx_status == "expire" else "CANCELLED"

        # Lepaskan reservasi stok
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
                    actor_id="MIDTRANS_WEBHOOK_EXPIRE",
                    notes=f"Pelepasan reservasi karena order {order.order_number} {tx_status}"
                ))

        db.commit()
        return {
            "status": tx_status.upper(),
            "order_id": order.id,
            "payment_status": order.payment_status,
            "order_status": order.order_status,
            "message": f"Order ditandai sebagai {tx_status}"
        }

    return {
        "status": "PENDING",
        "order_id": order.id,
        "payment_status": order.payment_status,
        "message": f"Midtrans transaction status '{tx_status}' recorded."
    }

@router.post("/midtrans/notification")
async def handle_midtrans_notification(
    request: Request,
    db: Session = Depends(get_db)
):
    """
    Notification URL Midtrans resmi:
    Menerima HTTP POST callback JSON dari Midtrans saat status pembayaran berubah.
    URL Lokal: http://127.0.0.1:8000/api/v1/payments/midtrans/notification
    """
    try:
        payload = await request.json()
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid JSON payload")

    return _process_midtrans_notification(payload, db)

@router.post("/midtrans/simulate-notification")
def simulate_midtrans_notification(
    order_id: str,
    action: str = "settlement",  # "settlement" atau "expire"
    db: Session = Depends(get_db)
):
    """
    Simulator Webhook Midtrans Lokal:
    Membuat notifikasi Midtrans ber-signature SHA-512 resmi untuk order lokal.
    Sangat berguna untuk demo dan pengujian lokal tanpa memerlukan ngrok.
    """
    order = db.query(Order).filter(Order.id == order_id).first()
    if not order:
        raise HTTPException(status_code=404, detail="Order tidak ditemukan")

    status_code = "200"
    gross_amount = f"{order.total_amount}.00"
    sig = midtrans_service.generate_signature(order.id, status_code, gross_amount)

    sim_payload = {
        "order_id": order.id,
        "status_code": status_code,
        "gross_amount": gross_amount,
        "signature_key": sig,
        "transaction_status": action,
        "payment_type": "qris",
        "transaction_id": f"sim-tx-{uuid.uuid4().hex[:10]}",
        "fraud_status": "accept"
    }

    return _process_midtrans_notification(sim_payload, db)
