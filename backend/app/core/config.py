import os
from typing import List
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    PROJECT_NAME: str = "KopiCerdas AI API"
    VERSION: str = "1.0.0"
    ENVIRONMENT: str = "development"
    DEBUG: bool = True
    API_V1_STR: str = "/api/v1"
    
    CORS_ORIGINS: List[str] = [
        "http://localhost:3000",
        "http://localhost:8080",
        "http://127.0.0.1:8080",
        "http://localhost:5000",
        "*"
    ]
    
    DATABASE_URL: str = "sqlite:///./kopicerdas.db"
    
    SECRET_KEY: str = "kopicerdas-hackathon-24h-insecure-dev-secret-key"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24  # 24 jam
    
    QRIS_MERCHANT_NAME: str = "KopiCerdas Keliling"
    QRIS_NMID: str = "ID1020000000001"
    QRIS_IMAGE_URL: str = "/assets/qris/merchant_static.png"
    QRIS_SIMULATOR_SECRET: str = "qris-dev-sim-secret-key"
    
    GOOGLE_MAPS_API_KEY: str = ""
    WEATHER_API_KEY: str = ""
    DATA_DEFAULT_LABEL: str = "SIMULASI"

    class Config:
        case_sensitive = True
        env_file = ".env"

settings = Settings()
