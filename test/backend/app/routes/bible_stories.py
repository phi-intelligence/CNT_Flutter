from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from typing import List
from app.database import get_db
from app.models import BibleStory
from pydantic import BaseModel
from datetime import datetime


class BibleStoryResponse(BaseModel):
    id: int
    title: str
    scripture_reference: str
    content: str
    audio_url: str = None
    cover_image: str = None
    created_at: datetime
    
    class Config:
        from_attributes = True


router = APIRouter()


@router.get("/", response_model=List[BibleStoryResponse])
async def list_bible_stories(
    skip: int = 0,
    limit: int = 100,
    db: AsyncSession = Depends(get_db)
):
    """List all bible stories"""
    from sqlalchemy import select
    result = await db.execute(select(BibleStory).offset(skip).limit(limit))
    stories = result.scalars().all()
    return stories


@router.get("/{story_id}", response_model=BibleStoryResponse)
async def get_bible_story(story_id: int, db: AsyncSession = Depends(get_db)):
    """Get a specific bible story"""
    from sqlalchemy import select
    result = await db.execute(select(BibleStory).where(BibleStory.id == story_id))
    story = result.scalar_one_or_none()
    if not story:
        raise HTTPException(status_code=404, detail="Bible story not found")
    return story

