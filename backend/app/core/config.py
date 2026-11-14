import os
from pathlib import Path
from typing import List, Any
from pydantic import field_validator
from pydantic_settings import BaseSettings

BASE_DIR = Path(__file__).resolve().parent.parent.parent
DEFAULT_DB_PATH = (BASE_DIR / "kopicerdas.db").resolve().as_posix()

class Settings(BaseSettings):
    PROJECT_NAME: str = "KopiCerdas AI API"
    VERSION: str = "1.0.0"
    ENVIRONMENT: str = "development"
    DEBUG: bool = True
    API_V1_STR: str = "/api/v1"

    @field_validator("DEBUG", mode="before")
    @classmethod
    def parse_debug(cls, v: Any) -> bool:
        if isinstance(v, bool):
            return v
        if isinstance(v, str):
            val = v.strip().lower()
            if val in ("true", "1", "yes", "y", "debug"):
                return True
            if val in ("false", "0", "no", "n", "release", "prod", "production"):
                return False
        return True
    
    CORS_ORIGINS: List[str] = [
        "http://localhost:3000",
        "http://localhost:8080",
        "http://127.0.0.1:8080",
        "http://localhost:5000",
        "*"
    ]
    
    DATABASE_URL: str = f"sqlite:///{DEFAULT_DB_PATH}"
    
    SECRET_KEY: str = "kopicerdas-hackathon-24h-insecure-dev-secret-key"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24  # 24 jam
    
    QRIS_MERCHANT_NAME: str = "KopiCerdas Keliling"
    QRIS_NMID: str = "ID1020000000001"
    QRIS_IMAGE_URL: str = "/assets/qris/merchant_static.png"
    QRIS_SIMULATOR_SECRET: str = "qris-dev-sim-secret-key"

    # --- Midtrans Payment Gateway ---
    MIDTRANS_CLIENT_KEY: str = "Mid-client-xVYN5mUwjQwAH_-o"
    MIDTRANS_SERVER_KEY: str = "Mid-server-525AC7MsYcVbzShFiO7gLtY3"
    MIDTRANS_KEY_NAME: str = "G701621745-DEFAULT-PAYMENT-CLIENT"
    MIDTRANS_IS_PRODUCTION: bool = False
    MIDTRANS_NOTIFICATION_URL: str = "http://127.0.0.1:8000/api/v1/payments/midtrans/notification"
    
    GOOGLE_MAPS_API_KEY: str = ""
    WEATHER_API_KEY: str = ""
    DATA_DEFAULT_LABEL: str = "SIMULASI"

    class Config:
        case_sensitive = True
        env_file = ".env"
        extra = "ignore"

settings = Settings()
