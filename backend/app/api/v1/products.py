from typing import List
import datetime
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.models import Product, Category
from app.schemas import ProductResponse, CategoryResponse, ProductBase

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
def create_product(req: ProductBase, db: Session = Depends(get_db)):
    prod_id = f"prd-{int(datetime.datetime.utcnow().timestamp())}"
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
    return new_prod
