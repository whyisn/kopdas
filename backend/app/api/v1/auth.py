import uuid
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.models import User
from app.schemas import LoginRequest, Token, UserResponse, UserCreateRequest
from app.core.security import verify_password, create_access_token, get_password_hash
from app.api.deps import get_current_user

router = APIRouter(prefix="/auth", tags=["Authentication"])

@router.post("/register", response_model=Token, status_code=status.HTTP_201_CREATED)
def register(req: UserCreateRequest, db: Session = Depends(get_db)):
    """
    Registrasi mandiri pengguna baru (default role: CUSTOMER).
    Langsung mengembalikan token JWT untuk autentikasi instan.
    """
    username_clean = req.username.strip().lower()
    if not username_clean:
        raise HTTPException(status_code=400, detail="Username wajib diisi")
    if len(req.password) < 6:
        raise HTTPException(status_code=400, detail="Password minimal 6 karakter")

    existing = db.query(User).filter(User.username == username_clean).first()
    if existing:
        raise HTTPException(status_code=400, detail="Username sudah terdaftar, silakan pilih username lain")

    role = req.role if req.role in ["CUSTOMER", "SELLER", "OWNER"] else "CUSTOMER"
    user_id = f"usr-cust-{uuid.uuid4().hex[:6]}" if role == "CUSTOMER" else f"usr-{uuid.uuid4().hex[:8]}"

    new_user = User(
        id=user_id,
        username=username_clean,
        name=req.name.strip(),
        password_hash=get_password_hash(req.password),
        role=role,
        is_active=True
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)

    token = create_access_token(data={"sub": new_user.id, "role": new_user.role, "name": new_user.name})
    return Token(
        access_token=token,
        token_type="bearer",
        role=new_user.role,
        user_id=new_user.id,
        name=new_user.name
    )

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
def get_current_user_info(current_user: User = Depends(get_current_user)):
    """
    Mengambil informasi profil pengguna yang sedang login berdasarkan JWT Bearer token.
    """
    return current_user
