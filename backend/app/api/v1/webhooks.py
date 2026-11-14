import datetime
import uuid
from typing import Optional
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.core.config import settings
from app.models import Order, PaymentEvent, Inventory, StockMovement
from app.schemas import QRISWebhookRequest

router = APIRouter(tags=["Payment Integration (PJP Webhook)"])

def _process_qris_payment(req: QRISWebhookRequest, db: Session):
    effective_amount = req.amount if req.amount is not None else (req.gross_amount or 0)
    effective_rrn = req.rrn or f"RRN-{uuid.uuid4().hex[:10].upper()}"
    effective_merchant_id = req.merchant_id or settings.QRIS_NMID
    effective_ptx = req.provider_tx_id or f"ptx-{uuid.uuid4().hex[:8]}"

    # 0. Cek Idempotency: Cegah Replay Attack pada webhook PJP
    existing_event = db.query(PaymentEvent).filter(
        PaymentEvent.provider_reference == effective_rrn
    ).first()

    if existing_event:
        return {
            "status": "DUPLICATE_EVENT",
            "message": f"Webhook dengan RRN '{effective_rrn}' sudah pernah diproses sebelumnya (Idempotent).",
            "order_id": existing_event.order_id,
            "payment_status": "PAID" if existing_event.event_type == "AUTO_MATCHED" else "ALREADY_PROCESSED",
            "data_label": "REAL"
        }

    # 1. Validasi merchant NMID jika dikirimkan spesifik
    if effective_merchant_id and effective_merchant_id != settings.QRIS_NMID:
        return {
            "status": "UNMATCHED",
            "message": f"Merchant ID '{effective_merchant_id}' tidak valid atau tidak terdaftar.",
            "data_label": "REAL"
        }

    from app.api.v1.orders import _check_and_expire_order

    matched_order: Optional[Order] = None

    # Jika order_id diberikan langsung oleh client/gateway
    if req.order_id:
        ord_direct = db.query(Order).filter(Order.id == req.order_id).first()
        if ord_direct and not _check_and_expire_order(ord_direct, db):
            matched_order = ord_direct

    # Jika tidak matched by ID, cari order pending berdasarkan nominal
    if not matched_order:
        candidate_orders = db.query(Order).filter(
            Order.payment_status == "PENDING",
            Order.total_amount == effective_amount
        ).all()

        pending_orders = []
        for ord_item in candidate_orders:
            if not _check_and_expire_order(ord_item, db):
                pending_orders.append(ord_item)

        if not pending_orders:
            return {
                "status": "UNMATCHED",
                "message": f"Tidak ditemukan order pending (aktif) dengan nominal Rp {effective_amount}",
                "data_label": "REAL"
            }

        if len(pending_orders) > 1:
            event = PaymentEvent(
                id=f"pe-{uuid.uuid4().hex[:10]}",
                order_id=pending_orders[0].id,
                provider_reference=effective_rrn,
                amount=effective_amount,
                event_type="AMBIGUOUS",
                raw_payload=f"Ditemukan {len(pending_orders)} order dengan nominal {effective_amount}. Butuh rekonsiliasi.",
                created_at=datetime.datetime.utcnow()
            )
            db.add(event)
            db.commit()
            return {
                "status": "AMBIGUOUS",
                "message": "Ditemukan beberapa order dengan nominal identik. Transaksi ditahan untuk rekonsiliasi.",
                "data_label": "REAL"
            }

        matched_order = pending_orders[0]

    # Order cocok secara unik (MATCHED)
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
                notes=f"Auto-confirm QRIS Statis RRN: {effective_rrn}"
            ))

    # Catat audit log event pembayaran
    event = PaymentEvent(
        id=f"pe-{uuid.uuid4().hex[:10]}",
        order_id=matched_order.id,
        provider_reference=effective_rrn,
        amount=effective_amount,
        event_type="AUTO_MATCHED",
        raw_payload=f"Auto-matched via webhook simulator provider_tx_id={effective_ptx}",
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
        "data_label": "REAL"
    }

@router.post("/webhooks/payments/provider-simulator")
@router.post("/webhooks/qris")
def handle_qris_webhook(req: QRISWebhookRequest, db: Session = Depends(get_db)):
    """
    Webhook resmi PJP/Acquirer QRIS:
    Mendukung auto-confirm QRIS statis & dinamis secara realtime.
    """
    return _process_qris_payment(req, db)
