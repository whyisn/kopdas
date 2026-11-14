import uuid
import datetime
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.models import User, Location, Inventory, Transaction
from app.schemas import UserResponse, UserCreateRequest, UserUpdateRequest
from app.core.security import get_password_hash
from app.api.deps import get_current_user, get_optional_current_user

router = APIRouter(prefix="/users", tags=["Field Staff & User Management"])

@router.get("", response_model=List[UserResponse])
def get_users(
    role: Optional[str] = Query(None, description="Filter berdasarkan role: SELLER, OWNER, CUSTOMER"),
    is_active: Optional[bool] = Query(None, description="Filter status aktif"),
    db: Session = Depends(get_db)
):
    """
    Mengambil daftar seluruh pengguna / staf lapangan.
    """
    query = db.query(User)
    if role:
        query = query.filter(User.role == role)
    if is_active is not None:
        query = query.filter(User.is_active == is_active)
    return query.order_by(User.created_at.desc()).all()

@router.post("", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
def create_user(
    req: UserCreateRequest,
    db: Session = Depends(get_db)
):
    """
    Mendaftarkan pengguna / staf penjual gerobak baru.
    """
    existing = db.query(User).filter(User.username == req.username).first()
    if existing:
        raise HTTPException(
            status_code=400,
            detail=f"Username '{req.username}' sudah terdaftar"
        )

    user_id = f"usr-{req.role.lower()}-{uuid.uuid4().hex[:6]}"
    new_user = User(
        id=user_id,
        username=req.username,
        name=req.name,
        password_hash=get_password_hash(req.password),
        role=req.role.upper(),
        is_active=True,
        created_at=datetime.datetime.utcnow()
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    return new_user

@router.get("/{user_id}", response_model=UserResponse)
def get_user_detail(user_id: str, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="Pengguna tidak ditemukan")
    return user

@router.patch("/{user_id}", response_model=UserResponse)
def update_user(
    user_id: str,
    req: UserUpdateRequest,
    db: Session = Depends(get_db)
):
    """
    Memperbarui profil, peran, status aktif, atau reset password staf.
    """
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="Pengguna tidak ditemukan")

    if req.name is not None:
        user.name = req.name
    if req.role is not None:
        user.role = req.role.upper()
    if req.is_active is not None:
        user.is_active = req.is_active
    if req.password is not None and req.password.strip():
        user.password_hash = get_password_hash(req.password.strip())

    db.commit()
    db.refresh(user)
    return user

@router.delete("/{user_id}")
def delete_user(user_id: str, db: Session = Depends(get_db)):
    """
    Menonaktifkan pengguna (soft deactivate).
    """
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="Pengguna tidak ditemukan")

    user.is_active = False
    db.commit()
    return {"status": "SUCCESS", "message": f"Pengguna '{user.name}' ({user.id}) berhasil dinonaktifkan"}
