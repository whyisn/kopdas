from typing import List, Optional
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.models import Location, Transaction, ExternalObservation, User
from app.schemas import LocationResponse
from app.ai_engine.location_scoring import location_scorer

router = APIRouter(prefix="/locations", tags=["Locations & Maps"])

def _format_location(l: Location, db: Session) -> LocationResponse:
    # Hitung jumlah transaksi historis di lokasi ini
    tx_count = db.query(Transaction).filter(Transaction.location_id == l.id).count()

    # Cek POI observation
    obs = db.query(ExternalObservation).filter(
        ExternalObservation.location_id == l.id,
        ExternalObservation.metric == "POI_COUNT"
    ).first()
    poi_count = int(obs.value) if obs and obs.value.isdigit() else 4

    # Hitung skor lokasi menggunakan AI Scorer
    score_res = location_scorer.score_location(
        {"id": l.id, "name": l.name},
        historical_sales_count=tx_count,
        poi_count=poi_count,
        data_label="SIMULASI"
    )

    seller_name = l.seller.name if l.seller else ("Belum Ditugaskan" if l.source_type == "CANDIDATE" else None)

    return LocationResponse(
        id=l.id,
        seller_id=l.seller_id,
        seller_name=seller_name,
        name=l.name,
        latitude=l.latitude,
        longitude=l.longitude,
        address=l.address,
        source_type=l.source_type,
        is_active=l.is_active,
        score=score_res["score"],
        factors=score_res.get("factors", []),
        confidence=score_res.get("confidence", 0.8),
        data_label="SIMULASI"
    )

@router.get("", response_model=List[LocationResponse])
def get_locations(include_candidates: bool = True, db: Session = Depends(get_db)):
    query = db.query(Location)
    if not include_candidates:
        query = query.filter(Location.source_type == "ACTIVE_POINT", Location.is_active == True)
    locs = query.all()
    return [_format_location(l, db) for l in locs]

@router.get("/candidates", response_model=List[LocationResponse])
def get_candidate_locations(db: Session = Depends(get_db)):
    """
    Mengembalikan daftar kandidat ekspansi lokasi (bukan titik operasional aktif).
    """
    locs = db.query(Location).filter(Location.source_type == "CANDIDATE").all()
    return [_format_location(l, db) for l in locs]
