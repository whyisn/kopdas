from typing import List, Optional, Any
from pydantic import BaseModel, Field
import datetime

# --- Auth ---
class Token(BaseModel):
    access_token: str
    token_type: str
    role: str
    user_id: str
    name: str

class LoginRequest(BaseModel):
    username: str
    password: str

class UserResponse(BaseModel):
    id: str
    username: str
    name: str
    role: str
    is_active: bool

    class Config:
        from_attributes = True

# --- Products & Categories ---
class CategoryBase(BaseModel):
    name: str
    status: str = "ACTIVE"

class CategoryResponse(CategoryBase):
    id: str
    class Config:
        from_attributes = True

class ProductBase(BaseModel):
    category_id: str
    name: str
    description: Optional[str] = None
    price: int = Field(..., ge=0, description="Harga jual tidak boleh negatif")
    cost_price: int = Field(0, ge=0, description="HPP tidak boleh negatif")
    status: str = "ACTIVE"
    image_url: Optional[str] = None

class ProductResponse(ProductBase):
    id: str
    category_name: Optional[str] = None
    class Config:
        from_attributes = True

# --- Inventory & Movements ---
class InventoryResponse(BaseModel):
    id: str
    product_id: str
    product_name: Optional[str] = None
    scope_type: str
    scope_id: str
    quantity: int
    reserved_quantity: int
    available_quantity: int
    updated_at: datetime.datetime

    class Config:
        from_attributes = True

class DistributionItem(BaseModel):
    product_id: str
    quantity: int = Field(..., gt=0, description="Kuantitas distribusi harus positif")

class DistributionRequest(BaseModel):
    seller_id: str
    items: List[DistributionItem] = Field(..., min_length=1, description="Daftar item tidak boleh kosong")
    notes: Optional[str] = "Distribusi stok dari gudang pusat"

class StockMovementResponse(BaseModel):
    id: str
    product_id: str
    product_name: Optional[str] = None
    from_scope: str
    to_scope: str
    quantity: int
    movement_type: str
    reference_id: Optional[str] = None
    actor_id: Optional[str] = None
    created_at: datetime.datetime

    class Config:
        from_attributes = True

# --- Walk-in Transactions ---
class TransactionItemRequest(BaseModel):
    product_id: str
    quantity: int = Field(..., gt=0, description="Kuantitas transaksi harus positif")

class TransactionCreateRequest(BaseModel):
    seller_id: str
    location_id: str
    payment_method: str = Field("CASH", pattern="^(CASH|QRIS_STATIC)$", description="Hanya CASH atau QRIS_STATIC")
    idempotency_key: Optional[str] = None
    items: List[TransactionItemRequest] = Field(..., min_length=1, description="Daftar item transaksi tidak boleh kosong")

class TransactionItemResponse(BaseModel):
    id: str
    product_id: str
    product_name: str
    quantity: int
    unit_price: int
    subtotal: int

    class Config:
        from_attributes = True

class TransactionResponse(BaseModel):
    id: str
    seller_id: str
    location_id: str
    total_amount: int
    total: Optional[int] = None  # Alias kompatibilitas kontrak Flutter
    payment_method: str
    payment_status: str
    created_at: datetime.datetime
    items: List[TransactionItemResponse]

    class Config:
        from_attributes = True

# --- Pre-orders & QRIS Payments ---
class OrderItemRequest(BaseModel):
    product_id: str
    quantity: int = Field(..., gt=0, description="Kuantitas order harus positif")

class OrderCreateRequest(BaseModel):
    customer_id: Optional[str] = "guest-customer"
    seller_id: str
    location_id: str
    items: List[OrderItemRequest] = Field(..., min_length=1, description="Daftar item order tidak boleh kosong")

class OrderItemResponse(BaseModel):
    id: str
    product_id: str
    product_name: Optional[str] = None
    quantity: int
    unit_price: int
    subtotal: int

    class Config:
        from_attributes = True

class OrderResponse(BaseModel):
    id: str
    order_number: str
    customer_id: Optional[str]
    customer_name: Optional[str] = None  # Kompatibilitas UI Customer/Owner
    seller_id: str
    location_id: str
    total_amount: int
    total: Optional[int] = None  # Alias kompatibilitas kontrak Flutter
    order_status: str
    payment_method: str
    payment_status: str
    qris_asset_url: Optional[str]
    created_at: datetime.datetime
    expires_at: Optional[datetime.datetime]
    data_label: str = "REAL"
    items: Optional[List[OrderItemResponse]] = None

    class Config:
        from_attributes = True

class OrderStatusUpdateRequest(BaseModel):
    status: str = Field(..., description="Status baru pesanan: PREPARING, READY_FOR_PICKUP, COMPLETED, CANCELLED")

class QRISWebhookRequest(BaseModel):
    provider_tx_id: str
    merchant_id: str
    amount: int
    timestamp: str
    rrn: str
    signature: Optional[str] = None

# --- Locations ---
class LocationResponse(BaseModel):
    id: str
    seller_id: Optional[str] = None
    seller_name: Optional[str] = None  # Kompatibilitas UI Owner Dashboard
    name: str
    latitude: float
    longitude: float
    address: Optional[str] = None
    source_type: str
    is_active: bool
    score: Optional[float] = None
    factors: Optional[List[str]] = None
    confidence: Optional[float] = None
    data_label: str = "SIMULASI"

    class Config:
        from_attributes = True

# --- AI & Optimization ---
class AIForecastRequest(BaseModel):
    target_period_days: int = 7
    location_ids: Optional[List[str]] = None
    product_ids: Optional[List[str]] = None
    data_label: str = "SIMULASI"

class AIRecommendationItem(BaseModel):
    model_config = {"protected_namespaces": ()}
    period_start: str
    period_end: str
    location_id: str
    location_name: str
    product_id: str
    product_name: str
    predicted_demand: int
    recommended_stock: int
    recommended_quantity: Optional[int] = None  # Alias kompatibilitas kontrak Flutter
    confidence: float
    data_quality: str
    rationale: List[str]
    model_version: str
    solver_status: str
    data_label: str

class AIOptimizeResponse(BaseModel):
    recommendations: List[AIRecommendationItem]
    total_recommended_cups: int
    estimated_margin: int
    solver_status: str
    processing_time_ms: float
    data_label: str = "SIMULASI"
