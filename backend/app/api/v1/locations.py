import uuid
import datetime
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.models import Location, Transaction, ExternalObservation, User
from app.schemas import (
    LocationResponse, LocationCreateRequest, LocationUpdateRequest, LocationTelemetryRequest
)
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
    poi_count = int(obs.value) if obs and obs.value.isdigit() else 12

    # Hitung skor lokasi menggunakan AI Scorer
    score_res = location_scorer.score_location(
        {"id": l.id, "name": l.name},
        historical_sales_count=tx_count,
        poi_count=poi_count,
        data_label="REAL"
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
        confidence=score_res.get("confidence", 0.85),
        data_label="REAL"
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

@router.post("", response_model=LocationResponse, status_code=status.HTTP_201_CREATED)
def create_location(req: LocationCreateRequest, db: Session = Depends(get_db)):
    """
    Mendaftarkan titik mangkal gerobak baru oleh Owner.
    """
    loc_id = f"loc-{uuid.uuid4().hex[:6]}"
    if req.seller_id:
        seller = db.query(User).filter(User.id == req.seller_id).first()
        if not seller:
            raise HTTPException(status_code=404, detail=f"Seller {req.seller_id} tidak ditemukan")

    new_loc = Location(
        id=loc_id,
        seller_id=req.seller_id,
        name=req.name,
        latitude=req.latitude,
        longitude=req.longitude,
        address=req.address,
        source_type=req.source_type,
        is_active=req.is_active
    )
    db.add(new_loc)
    db.commit()
    db.refresh(new_loc)
    return _format_location(new_loc, db)

@router.patch("/{location_id}", response_model=LocationResponse)
def update_location(location_id: str, req: LocationUpdateRequest, db: Session = Depends(get_db)):
    """
    Memperbarui data titik lokasi atau menugaskan seller baru ke lokasi tersebut.
    """
    loc = db.query(Location).filter(Location.id == location_id).first()
    if not loc:
        raise HTTPException(status_code=404, detail="Lokasi tidak ditemukan")

    if req.name is not None:
        loc.name = req.name
    if req.latitude is not None:
        loc.latitude = req.latitude
    if req.longitude is not None:
        loc.longitude = req.longitude
    if req.address is not None:
        loc.address = req.address
    if req.source_type is not None:
        loc.source_type = req.source_type
    if req.is_active is not None:
        loc.is_active = req.is_active
    if req.seller_id is not None:
        if req.seller_id != "":
            seller = db.query(User).filter(User.id == req.seller_id).first()
            if not seller:
                raise HTTPException(status_code=404, detail=f"Seller {req.seller_id} tidak ditemukan")
            loc.seller_id = req.seller_id
        else:
            loc.seller_id = None

    db.commit()
    db.refresh(loc)
    return _format_location(loc, db)

@router.post("/{location_id}/telemetry")
def update_location_telemetry(
    location_id: str,
    req: LocationTelemetryRequest,
    db: Session = Depends(get_db)
):
    """
    Menerima pembaruan koordinat GPS live dan telemetri perangkat dari seller.
    """
    loc = db.query(Location).filter(Location.id == location_id).first()
    if not loc:
        raise HTTPException(status_code=404, detail="Lokasi tidak ditemukan")

    loc.latitude = req.latitude
    loc.longitude = req.longitude

    # Catat ke external observations untuk audit trail jejak gerobak
    obs_id = f"telemetry-{uuid.uuid4().hex[:8]}"
    db.add(ExternalObservation(
        id=obs_id,
        source="GPS_TELEMETRY",
        location_id=loc.id,
        latitude=req.latitude,
        longitude=req.longitude,
        metric="GPS_UPDATE",
        value=f"status={req.status};battery={req.battery_pct}%;acc={req.accuracy_m}m",
        unit="coords",
        data_label="REAL",
        observed_at=datetime.datetime.utcnow()
    ))
    db.commit()

    return {
        "status": "SUCCESS",
        "location_id": loc.id,
        "latitude": loc.latitude,
        "longitude": loc.longitude,
        "updated_at": datetime.datetime.utcnow().isoformat()
    }
