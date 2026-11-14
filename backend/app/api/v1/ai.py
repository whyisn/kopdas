from typing import List, Dict, Any
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.models import Product, Location, Inventory, Transaction, TransactionItem
from app.schemas import AIForecastRequest, AIOptimizeResponse, AIRecommendationItem
from app.ai_engine.forecasting import forecaster
from app.ai_engine.optimizer import optimizer

router = APIRouter(prefix="/ai", tags=["AI & Intelligence"])

@router.post("/forecast")
def generate_forecast(req: AIForecastRequest, db: Session = Depends(get_db)):
    """
    Menghasilkan prediksi demand penjualan produk per lokasi
    menggunakan model time-series baseline / WMA.
    """
    # Ambil histori transaksi
    tx_items = db.query(
        Transaction.location_id,
        TransactionItem.product_id,
        TransactionItem.quantity,
        Transaction.created_at
    ).join(TransactionItem, TransactionItem.transaction_id == Transaction.id).all()

    sales_history = [
        {
            "location_id": row[0],
            "product_id": row[1],
            "quantity": row[2],
            "stockout_flag": False
        }
        for row in tx_items
    ]

    # Jika histori masih sedikit, gabungkan dengan baseline seed
    if len(sales_history) < 5:
        prods = db.query(Product).all()
        locs = db.query(Location).filter(Location.source_type == "ACTIVE_POINT").all()
        for l in locs:
            for p in prods:
                sales_history.append({
                    "location_id": l.id,
                    "product_id": p.id,
                    "quantity": 12,
                    "stockout_flag": False
                })

    forecast_results = forecaster.forecast_sales(
        sales_history,
        target_days=req.target_period_days,
        data_label=req.data_label
    )

    return {
        "target_days": req.target_period_days,
        "forecasts": forecast_results,
        "data_label": req.data_label
    }

@router.post("/optimize", response_model=AIOptimizeResponse)
def optimize_stock_allocation(db: Session = Depends(get_db)):
    """
    Menghitung rekomendasi alokasi stok per gerobak seller
    menggunakan solver MILP (dengan batasan kapasitas gerobak & stok gudang)
    atau Rule-Based Fallback.
    """
    # 1. Stok gudang pusat
    central_invs = db.query(Inventory).filter(
        Inventory.scope_type == "WAREHOUSE",
        Inventory.scope_id == "central"
    ).all()
    central_dict = {inv.product_id: inv.quantity for inv in central_invs}

    # 2. Seller and capacities
    sellers = db.query(Location).filter(Location.source_type == "ACTIVE_POINT").all()
    capacities = {s.id: 120 for s in sellers} # Rata-rata kapasitas gerobak 120 cup

    # 3. Product margins
    products = db.query(Product).all()
    margins = {p.id: (p.price - p.cost_price) for p in products}
    prod_names = {p.id: p.name for p in products}
    loc_names = {s.id: s.name for s in sellers}

    # 4. Generate forecasts first
    fc_req = AIForecastRequest(target_period_days=7)
    fc_data = generate_forecast(fc_req, db)["forecasts"]

    # Enrich forecast with names
    for fc in fc_data:
        fc["product_name"] = prod_names.get(fc["product_id"], fc["product_id"])
        fc["location_name"] = loc_names.get(fc["location_id"], fc["location_id"])

    # 5. Eksekusi optimasi MILP
    opt_result = optimizer.optimize_allocation(
        central_inventory=central_dict,
        seller_capacities=capacities,
        forecasts=fc_data,
        product_margins=margins,
        data_label="SIMULASI"
    )

    return AIOptimizeResponse(
        recommendations=opt_result["recommendations"],
        total_recommended_cups=opt_result["total_recommended_cups"],
        estimated_margin=opt_result["estimated_margin"],
        solver_status=opt_result["solver_status"],
        processing_time_ms=opt_result["processing_time_ms"],
        data_label="SIMULASI"
    )

@router.get("/recommendations")
def get_latest_recommendations(db: Session = Depends(get_db)):
    return optimize_stock_allocation(db=db)
