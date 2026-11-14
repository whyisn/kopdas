from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.models import User
from app.schemas import LoginRequest, Token, UserResponse
from app.core.security import verify_password, create_access_token

router = APIRouter(prefix="/auth", tags=["Authentication"])

@router.post("/login", response_model=Token)
def login(req: LoginRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.username == req.username).first()
    if not user or not verify_password(req.password, user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Username atau password salah"
        )
    if not user.is_active:
        raise HTTPException(status_code=400, detail="Akun dinonaktifkan")

    token = create_access_token(data={"sub": user.id, "role": user.role, "name": user.name})
    return Token(
        access_token=token,
        token_type="bearer",
        role=user.role,
        user_id=user.id,
        name=user.name
    )

@router.get("/me", response_model=UserResponse)
def get_current_user_info(user_id: str, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User tidak ditemukan")
    return user
