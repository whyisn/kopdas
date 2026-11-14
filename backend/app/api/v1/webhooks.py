import datetime
import uuid
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.core.config import settings
from app.models import Order, PaymentEvent, Inventory, StockMovement
from app.schemas import QRISWebhookRequest

router = APIRouter(prefix="/webhooks/payments", tags=["Payment Integration (PJP Webhook)"])

@router.post("/provider-simulator")
def handle_qris_webhook(req: QRISWebhookRequest, db: Session = Depends(get_db)):
    """
    Simulasi Webhook resmi PJP/Acquirer QRIS Statis:
    - Menerima notifikasi pembayaran transaksi.
    - Validasi idempotency RRN (mencegah replay attack).
    - Mencocokkan merchant_id, nominal tepat, dan status order PENDING.
    - Jika cocok unik: ubah payment_status -> PAID dan order_status -> CONFIRMED secara otomatis.
    - Jika ada nominal kembar ambigu / tidak cocok: tandai AMBIGUOUS (TIDAK auto-confirm).
    """
    # 0. Cek Idempotency: Cegah Replay Attack pada webhook PJP
    existing_event = db.query(PaymentEvent).filter(
        PaymentEvent.provider_reference == req.rrn
    ).first()

    if existing_event:
        return {
            "status": "DUPLICATE_EVENT",
            "message": f"Webhook dengan RRN '{req.rrn}' sudah pernah diproses sebelumnya (Idempotent).",
            "order_id": existing_event.order_id,
            "payment_status": "PAID" if existing_event.event_type == "AUTO_MATCHED" else "ALREADY_PROCESSED",
            "data_label": "SIMULASI"
        }

    # 1. Validasi merchant NMID
    if req.merchant_id and req.merchant_id != settings.QRIS_NMID:
        return {
            "status": "UNMATCHED",
            "message": f"Merchant ID '{req.merchant_id}' tidak valid atau tidak terdaftar.",
            "data_label": "SIMULASI"
        }
    # 2. Cari order yang masih PENDING dengan nominal yang sama persis (abaikan order yang expired)
    from app.api.v1.orders import _check_and_expire_order

    candidate_orders = db.query(Order).filter(
        Order.payment_status == "PENDING",
        Order.total_amount == req.amount
    ).all()

    pending_orders = []
    for ord_item in candidate_orders:
        if not _check_and_expire_order(ord_item, db):
            pending_orders.append(ord_item)

    if not pending_orders:
        return {
            "status": "UNMATCHED",
            "message": f"Tidak ditemukan order pending (aktif) dengan nominal Rp {req.amount}",
            "data_label": "SIMULASI"
        }

    # Jika ada lebih dari satu order pending dengan nominal sama persis -> AMBIGU
    if len(pending_orders) > 1:
        # Catat event ambigu untuk rekonsiliasi sistem
        event = PaymentEvent(
            id=f"pe-{uuid.uuid4().hex[:10]}",
            order_id=pending_orders[0].id,
            provider_reference=req.rrn,
            amount=req.amount,
            event_type="AMBIGUOUS",
            raw_payload=f"Ditemukan {len(pending_orders)} order dengan nominal {req.amount}. Butuh rekonsiliasi.",
            created_at=datetime.datetime.utcnow()
        )
        db.add(event)
        db.commit()
        return {
            "status": "AMBIGUOUS",
            "message": "Ditemukan beberapa order dengan nominal identik. Transaksi ditahan untuk rekonsiliasi.",
            "data_label": "SIMULASI"
        }

    # Order cocok secara unik (MATCHED)
    matched_order = pending_orders[0]
    matched_order.payment_status = "PAID"
    matched_order.order_status = "CONFIRMED"

    # Mutasi stok: lepaskan reservasi dan kurangi stok fisik seller
    for it in matched_order.items:
        seller_inv = db.query(Inventory).filter(
            Inventory.scope_type == "SELLER",
            Inventory.scope_id == matched_order.seller_id,
            Inventory.product_id == it.product_id
        ).first()

        if seller_inv:
            seller_inv.reserved_quantity = max(0, seller_inv.reserved_quantity - it.quantity)
            seller_inv.quantity = max(0, seller_inv.quantity - it.quantity)

            # Catat mutasi penjualan
            db.add(StockMovement(
                id=f"mov-{uuid.uuid4().hex[:10]}",
                product_id=it.product_id,
                from_scope=matched_order.seller_id,
                to_scope="CUSTOMER",
                quantity=it.quantity,
                movement_type="SALE",
                reference_id=matched_order.id,
                actor_id="PJP_ACQUIRER_AUTO",
                notes=f"Auto-confirm QRIS Statis RRN: {req.rrn}"
            ))

    # Catat audit log event pembayaran
    event = PaymentEvent(
        id=f"pe-{uuid.uuid4().hex[:10]}",
        order_id=matched_order.id,
        provider_reference=req.rrn,
        amount=req.amount,
        event_type="AUTO_MATCHED",
        raw_payload=f"Auto-matched via webhook simulator provider_tx_id={req.provider_tx_id}",
        created_at=datetime.datetime.utcnow()
    )
    db.add(event)
    db.commit()

    return {
        "status": "MATCHED",
        "order_id": matched_order.id,
        "order_number": matched_order.order_number,
        "payment_status": "PAID",
        "order_status": "CONFIRMED",
        "message": "Pembayaran berhasil dikonfirmasi secara otomatis melalui PJP",
        "data_label": "SIMULASI"
    }
