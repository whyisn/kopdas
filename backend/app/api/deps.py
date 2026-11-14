from typing import Optional, List
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from jose import JWTError, jwt
from sqlalchemy.orm import Session

from app.core.config import settings
from app.core.database import get_db
from app.models import User

# HTTPBearer dengan auto_error=False agar kita bisa mengontrol pesan error kustom
http_bearer = HTTPBearer(auto_error=False)

def get_current_user(
    credentials: Optional[HTTPAuthorizationCredentials] = Depends(http_bearer),
    db: Session = Depends(get_db)
) -> User:
    """
    Ekstrak dan validasi token JWT Bearer dari header Authorization.
    Wajib autentikasi - menolak jika token tidak ada, salah, atau kedaluwarsa.
    """
    if not credentials or not credentials.credentials:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Header Authorization Bearer diperlukan untuk mengakses endpoint ini",
            headers={"WWW-Authenticate": "Bearer"}
        )

    token = credentials.credentials
    try:
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
        user_id: Optional[str] = payload.get("sub")
        if not user_id:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Payload token tidak valid (sub claim hilang)",
                headers={"WWW-Authenticate": "Bearer"}
            )
    except JWTError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token tidak valid atau telah kedaluwarsa",
            headers={"WWW-Authenticate": "Bearer"}
        )

    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User pemilik token tidak ditemukan di sistem",
            headers={"WWW-Authenticate": "Bearer"}
        )
    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Akun dinonaktifkan"
        )
    return user

def get_optional_current_user(
    credentials: Optional[HTTPAuthorizationCredentials] = Depends(http_bearer),
    db: Session = Depends(get_db)
) -> Optional[User]:
    """
    Ekstrak token jika tersedia. Jika ada token tapi tidak valid/palsu, tolak dengan 401.
    Jika tidak ada header Authorization, return None.
    """
    if not credentials or not credentials.credentials:
        return None
    return get_current_user(credentials=credentials, db=db)

def require_role(allowed_roles: List[str]):
    """
    Dependency factory untuk otorisasi berbasis Role (RBAC).
    """
    def role_checker(current_user: User = Depends(get_current_user)) -> User:
        if current_user.role not in allowed_roles:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Akses ditolak: role '{current_user.role}' tidak memiliki izin. Diperlukan role: {allowed_roles}"
            )
        return current_user
    return role_checker

require_owner = require_role(["OWNER"])
require_seller_or_owner = require_role(["SELLER", "OWNER"])
