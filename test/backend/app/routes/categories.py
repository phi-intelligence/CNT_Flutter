from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from typing import List
from app.database import get_db
from app.models import Category
from pydantic import BaseModel


class CategoryResponse(BaseModel):
    id: int
    name: str
    type: str
    
    class Config:
        from_attributes = True


router = APIRouter()


@router.get("/", response_model=List[CategoryResponse])
async def list_categories(db: AsyncSession = Depends(get_db)):
    """List all categories"""
    from sqlalchemy import select
    result = await db.execute(select(Category))
    categories = result.scalars().all()
    return categories

