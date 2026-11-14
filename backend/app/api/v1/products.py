import uuid
from typing import List, Optional
import datetime
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.models import Product, Category, User
from app.schemas import ProductResponse, CategoryResponse, ProductBase
from app.api.deps import get_optional_current_user

router = APIRouter(prefix="", tags=["Products & Categories"])

@router.get("/categories", response_model=List[CategoryResponse])
def get_categories(db: Session = Depends(get_db)):
    return db.query(Category).filter(Category.status == "ACTIVE").all()

@router.get("/products", response_model=List[ProductResponse])
def get_products(category_id: str = None, db: Session = Depends(get_db)):
    query = db.query(Product).filter(Product.status == "ACTIVE")
    if category_id:
        query = query.filter(Product.category_id == category_id)
    products = query.all()

    results = []
    for p in products:
        results.append(ProductResponse(
            id=p.id,
            category_id=p.category_id,
            name=p.name,
            description=p.description,
            price=p.price,
            cost_price=p.cost_price,
            status=p.status,
            image_url=p.image_url,
            category_name=p.category.name if p.category else None
        ))
    return results

@router.post("/products", response_model=ProductResponse)
def create_product(
    req: ProductBase,
    current_user: Optional[User] = Depends(get_optional_current_user),
    db: Session = Depends(get_db)
):
    if current_user and current_user.role != "OWNER":
        raise HTTPException(status_code=403, detail="Hanya OWNER yang dapat menambahkan produk baru")

    # Validasi keberadaan kategori
    cat = db.query(Category).filter(Category.id == req.category_id).first()
    if not cat:
        raise HTTPException(status_code=400, detail=f"Kategori '{req.category_id}' tidak valid atau tidak ditemukan")

    if req.price < 0 or req.cost_price < 0:
        raise HTTPException(status_code=400, detail="Harga jual dan HPP tidak boleh negatif")

    prod_id = f"prd-{uuid.uuid4().hex[:8]}"
    new_prod = Product(
        id=prod_id,
        category_id=req.category_id,
        name=req.name,
        description=req.description,
        price=req.price,
        cost_price=req.cost_price,
        status=req.status,
        image_url=req.image_url
    )
    db.add(new_prod)
    db.commit()
    db.refresh(new_prod)
    return ProductResponse(
        id=new_prod.id,
        category_id=new_prod.category_id,
        name=new_prod.name,
        description=new_prod.description,
        price=new_prod.price,
        cost_price=new_prod.cost_price,
        status=new_prod.status,
        image_url=new_prod.image_url,
        category_name=cat.name
    )
