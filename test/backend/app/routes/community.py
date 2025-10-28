from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from typing import List
from app.database import get_db
from app.models import CommunityPost
from pydantic import BaseModel
from datetime import datetime


class CommunityPostResponse(BaseModel):
    id: int
    user_id: int
    title: str
    content: str
    category: str
    likes_count: int
    comments_count: int
    created_at: datetime
    
    class Config:
        from_attributes = True


class CommunityPostCreate(BaseModel):
    title: str
    content: str
    category: str


router = APIRouter()


@router.get("/posts", response_model=List[CommunityPostResponse])
async def list_posts(
    skip: int = 0,
    limit: int = 100,
    category: str = None,
    db: AsyncSession = Depends(get_db)
):
    """List all community posts"""
    from sqlalchemy import select
    query = select(CommunityPost)
    
    if category:
        query = query.where(CommunityPost.category == category)
    
    query = query.offset(skip).limit(limit)
    result = await db.execute(query)
    posts = result.scalars().all()
    return posts


@router.post("/posts", response_model=CommunityPostResponse)
async def create_post(
    post: CommunityPostCreate,
    db: AsyncSession = Depends(get_db)
):
    """Create a new community post"""
    db_post = CommunityPost(user_id=1, **post.model_dump())  # TODO: get from auth
    db.add(db_post)
    await db.commit()
    await db.refresh(db_post)
    return db_post

