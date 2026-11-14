import datetime
import uuid
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.models import Inventory, StockMovement, Product
from app.schemas import InventoryResponse, DistributionRequest, StockMovementResponse

router = APIRouter(prefix="/inventory", tags=["Inventory & Distribution"])

@router.get("", response_model=List[InventoryResponse])
def get_inventory(
    scope_type: Optional[str] = Query(None, description="WAREHOUSE atau SELLER"),
    scope_id: Optional[str] = Query(None, description="central atau seller user_id"),
    db: Session = Depends(get_db)
):
    query = db.query(Inventory)
    if scope_type:
        query = query.filter(Inventory.scope_type == scope_type)
    if scope_id:
        query = query.filter(Inventory.scope_id == scope_id)

    invs = query.all()
    results = []
    for inv in invs:
        results.append(InventoryResponse(
            id=inv.id,
            product_id=inv.product_id,
            product_name=inv.product.name if inv.product else None,
            scope_type=inv.scope_type,
            scope_id=inv.scope_id,
            quantity=inv.quantity,
            reserved_quantity=inv.reserved_quantity,
            available_quantity=max(0, inv.quantity - inv.reserved_quantity),
            updated_at=inv.updated_at
        ))
    return results

@router.post("/distributions")
def distribute_stock(req: DistributionRequest, actor_id: str = "usr-owner-01", db: Session = Depends(get_db)):
    """
    Distribusi stok: stok gudang pusat berkurang dan stok seller bertambah
    dalam SATU transaksi database atomik.
    """
    if not req.items:
        raise HTTPException(status_code=400, detail="Item distribusi tidak boleh kosong")

    # Jalankan dalam DB transaction atomik
    try:
        movements = []
        for item in req.items:
            if item.quantity <= 0:
                continue

            # 1. Cek stok gudang pusat
            central_inv = db.query(Inventory).filter(
                Inventory.scope_type == "WAREHOUSE",
                Inventory.scope_id == "central",
                Inventory.product_id == item.product_id
            ).first()

            if not central_inv or central_inv.quantity < item.quantity:
                raise HTTPException(
                    status_code=400,
                    detail=f"Stok gudang pusat tidak mencukupi untuk produk {item.product_id}. Tersedia: {central_inv.quantity if central_inv else 0}"
                )

            # 2. Kurangi stok pusat
            central_inv.quantity -= item.quantity

            # 3. Tambah stok seller (buat jika belum ada)
            seller_inv = db.query(Inventory).filter(
                Inventory.scope_type == "SELLER",
                Inventory.scope_id == req.seller_id,
                Inventory.product_id == item.product_id
            ).first()

            if not seller_inv:
                seller_inv = Inventory(
                    id=f"inv-{req.seller_id}-{item.product_id}",
                    product_id=item.product_id,
                    scope_type="SELLER",
                    scope_id=req.seller_id,
                    quantity=item.quantity,
                    reserved_quantity=0
                )
                db.add(seller_inv)
            else:
                seller_inv.quantity += item.quantity

            # 4. Catat riwayat mutasi stok
            mov = StockMovement(
                id=f"mov-{uuid.uuid4().hex[:10]}",
                product_id=item.product_id,
                from_scope="central",
                to_scope=req.seller_id,
                quantity=item.quantity,
                movement_type="DISTRIBUTION",
                actor_id=actor_id,
                notes=req.notes
            )
            movements.append(mov)

        db.add_all(movements)
        db.commit()
        return {"status": "SUCCESS", "message": f"Berhasil mendistribusikan {len(req.items)} produk ke seller {req.seller_id}"}

    except HTTPException:
        db.rollback()
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Gagal melakukan distribusi: {str(e)}")

@router.get("/movements", response_model=List[StockMovementResponse])
def get_stock_movements(db: Session = Depends(get_db)):
    movs = db.query(StockMovement).order_by(StockMovement.created_at.desc()).limit(100).all()
    results = []
    for m in movs:
        results.append(StockMovementResponse(
            id=m.id,
            product_id=m.product_id,
            product_name=m.product.name if m.product else None,
            from_scope=m.from_scope,
            to_scope=m.to_scope,
            quantity=m.quantity,
            movement_type=m.movement_type,
            reference_id=m.reference_id,
            actor_id=m.actor_id,
            created_at=m.created_at
        ))
    return results
