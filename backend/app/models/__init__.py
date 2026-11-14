import datetime
from sqlalchemy import Column, String, Integer, Float, Boolean, DateTime, ForeignKey, Text, Enum
from sqlalchemy.orm import relationship
import enum

from app.core.database import Base

class UserRole(str, enum.Enum):
    OWNER = "OWNER"
    SELLER = "SELLER"
    CUSTOMER = "CUSTOMER"

class User(Base):
    __tablename__ = "users"

    id = Column(String(50), primary_key=True, index=True)
    username = Column(String(50), unique=True, index=True, nullable=False)
    name = Column(String(100), nullable=False)
    password_hash = Column(String(255), nullable=False)
    role = Column(String(20), default=UserRole.SELLER.value, nullable=False)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)

    locations = relationship("Location", back_populates="seller")
    transactions = relationship("Transaction", back_populates="seller")
    orders = relationship("Order", back_populates="seller", foreign_keys="[Order.seller_id]")

class Category(Base):
    __tablename__ = "categories"

    id = Column(String(50), primary_key=True, index=True)
    name = Column(String(100), nullable=False)
    status = Column(String(20), default="ACTIVE")

    products = relationship("Product", back_populates="category")

class Product(Base):
    __tablename__ = "products"

    id = Column(String(50), primary_key=True, index=True)
    category_id = Column(String(50), ForeignKey("categories.id"), nullable=False)
    name = Column(String(100), nullable=False)
    description = Column(Text, nullable=True)
    price = Column(Integer, nullable=False)        # Selling price in IDR
    cost_price = Column(Integer, default=0)        # Cost/modal for margin in IDR
    status = Column(String(20), default="ACTIVE")
    image_url = Column(String(255), nullable=True)

    category = relationship("Category", back_populates="products")
    inventories = relationship("Inventory", back_populates="product")
    stock_movements = relationship("StockMovement", back_populates="product")

class Location(Base):
    __tablename__ = "locations"

    id = Column(String(50), primary_key=True, index=True)
    seller_id = Column(String(50), ForeignKey("users.id"), nullable=True)
    name = Column(String(100), nullable=False)
    latitude = Column(Float, nullable=False)
    longitude = Column(Float, nullable=False)
    address = Column(String(255), nullable=True)
    source_type = Column(String(30), default="ACTIVE_POINT")  # ACTIVE_POINT or CANDIDATE
    is_active = Column(Boolean, default=True)

    seller = relationship("User", back_populates="locations")

class Inventory(Base):
    __tablename__ = "inventory"

    id = Column(String(50), primary_key=True, index=True)
    product_id = Column(String(50), ForeignKey("products.id"), nullable=False)
    scope_type = Column(String(20), nullable=False)  # WAREHOUSE or SELLER
    scope_id = Column(String(50), nullable=False)    # 'central' or seller user_id
    quantity = Column(Integer, default=0, nullable=False)
    reserved_quantity = Column(Integer, default=0, nullable=False)
    updated_at = Column(DateTime, default=datetime.datetime.utcnow, onupdate=datetime.datetime.utcnow)

    product = relationship("Product", back_populates="inventories")

class StockMovement(Base):
    __tablename__ = "stock_movements"

    id = Column(String(50), primary_key=True, index=True)
    product_id = Column(String(50), ForeignKey("products.id"), nullable=False)
    from_scope = Column(String(50), nullable=False)
    to_scope = Column(String(50), nullable=False)
    quantity = Column(Integer, nullable=False)
    movement_type = Column(String(30), nullable=False)  # INBOUND, DISTRIBUTION, SALE, ADJUSTMENT, RELEASE_RESERVATION
    reference_id = Column(String(50), nullable=True)    # transaction_id or order_id
    actor_id = Column(String(50), nullable=True)
    notes = Column(String(255), nullable=True)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)

    product = relationship("Product", back_populates="stock_movements")

class Transaction(Base):
    __tablename__ = "transactions"

    id = Column(String(50), primary_key=True, index=True)
    seller_id = Column(String(50), ForeignKey("users.id"), nullable=False)
    location_id = Column(String(50), ForeignKey("locations.id"), nullable=False)
    total_amount = Column(Integer, nullable=False)
    payment_method = Column(String(20), nullable=False)  # CASH or QRIS_STATIC
    payment_status = Column(String(20), default="PAID", nullable=False)
    idempotency_key = Column(String(100), unique=True, index=True, nullable=True)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)

    seller = relationship("User", back_populates="transactions")
    items = relationship("TransactionItem", back_populates="transaction", cascade="all, delete-orphan")

class TransactionItem(Base):
    __tablename__ = "transaction_items"

    id = Column(String(50), primary_key=True, index=True)
    transaction_id = Column(String(50), ForeignKey("transactions.id"), nullable=False)
    product_id = Column(String(50), ForeignKey("products.id"), nullable=False)
    quantity = Column(Integer, nullable=False)
    unit_price = Column(Integer, nullable=False)
    subtotal = Column(Integer, nullable=False)

    transaction = relationship("Transaction", back_populates="items")
    product = relationship("Product")

class Order(Base):
    __tablename__ = "orders"

    id = Column(String(50), primary_key=True, index=True)
    order_number = Column(String(50), unique=True, index=True, nullable=False)
    customer_id = Column(String(50), nullable=True)
    seller_id = Column(String(50), ForeignKey("users.id"), nullable=False)
    location_id = Column(String(50), ForeignKey("locations.id"), nullable=False)
    total_amount = Column(Integer, nullable=False)
    order_status = Column(String(30), default="PENDING_PAYMENT", nullable=False)
    # PENDING_PAYMENT, CONFIRMED, PREPARING, READY_FOR_PICKUP, COMPLETED, CANCELLED, EXPIRED
    payment_method = Column(String(20), default="QRIS_STATIC", nullable=False)
    payment_status = Column(String(20), default="PENDING", nullable=False)
    # PENDING, PAID, REJECTED, EXPIRED
    qris_asset_url = Column(String(255), nullable=True)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)
    expires_at = Column(DateTime, nullable=True)

    seller = relationship("User", foreign_keys=[seller_id])
    items = relationship("OrderItem", back_populates="order", cascade="all, delete-orphan")
    payment_events = relationship("PaymentEvent", back_populates="order")

class OrderItem(Base):
    __tablename__ = "order_items"

    id = Column(String(50), primary_key=True, index=True)
    order_id = Column(String(50), ForeignKey("orders.id"), nullable=False)
    product_id = Column(String(50), ForeignKey("products.id"), nullable=False)
    quantity = Column(Integer, nullable=False)
    unit_price = Column(Integer, nullable=False)
    subtotal = Column(Integer, nullable=False)

    order = relationship("Order", back_populates="items")
    product = relationship("Product")

class PaymentEvent(Base):
    __tablename__ = "payment_events"

    id = Column(String(50), primary_key=True, index=True)
    order_id = Column(String(50), ForeignKey("orders.id"), nullable=False)
    provider_reference = Column(String(100), nullable=True)  # RRN / Settlement ID
    amount = Column(Integer, nullable=False)
    event_type = Column(String(50), nullable=False)  # WEBHOOK_RECEIVED, AUTO_MATCHED, AMBIGUOUS
    raw_payload = Column(Text, nullable=True)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)

    order = relationship("Order", back_populates="payment_events")

class AIForecast(Base):
    __tablename__ = "ai_forecasts"

    id = Column(String(50), primary_key=True, index=True)
    period_start = Column(String(20), nullable=False)
    period_end = Column(String(20), nullable=False)
    location_id = Column(String(50), nullable=False)
    product_id = Column(String(50), nullable=False)
    predicted_demand = Column(Integer, nullable=False)
    recommended_stock = Column(Integer, nullable=False)
    confidence = Column(Float, nullable=False)
    data_quality = Column(String(20), default="LIMITED")  # HIGH, MEDIUM, LIMITED
    rationale = Column(Text, nullable=True)               # JSON string of reason items
    model_version = Column(String(30), default="baseline-v1")
    solver_status = Column(String(30), default="OPTIMAL") # OPTIMAL, RULE_BASED_FALLBACK
    data_label = Column(String(20), default="SIMULASI")   # REAL or SIMULASI
    created_at = Column(DateTime, default=datetime.datetime.utcnow)

class ExternalObservation(Base):
    __tablename__ = "external_observations"

    id = Column(String(50), primary_key=True, index=True)
    source = Column(String(50), nullable=False)   # GOOGLE_MAPS, OPEN_METEO, SIMULATED
    location_id = Column(String(50), nullable=True)
    latitude = Column(Float, nullable=False)
    longitude = Column(Float, nullable=False)
    metric = Column(String(50), nullable=False)   # POI_COUNT, FOOTFALL_ESTIMATE, WEATHER
    value = Column(String(100), nullable=False)
    unit = Column(String(30), nullable=True)
    data_label = Column(String(20), default="SIMULASI")
    observed_at = Column(DateTime, default=datetime.datetime.utcnow)
