from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from typing import List
from app.database import get_db
from app.models import Podcast
from app.schemas.podcast import PodcastCreate, PodcastResponse

router = APIRouter()


@router.get("/", response_model=List[PodcastResponse])
async def list_podcasts(
    skip: int = 0,
    limit: int = 100,
    db: AsyncSession = Depends(get_db)
):
    """List all podcasts"""
    from sqlalchemy import select
    result = await db.execute(select(Podcast).offset(skip).limit(limit))
    podcasts = result.scalars().all()
    return podcasts


@router.get("/{podcast_id}", response_model=PodcastResponse)
async def get_podcast(podcast_id: int, db: AsyncSession = Depends(get_db)):
    """Get a specific podcast"""
    from sqlalchemy import select
    result = await db.execute(select(Podcast).where(Podcast.id == podcast_id))
    podcast = result.scalar_one_or_none()
    if not podcast:
        raise HTTPException(status_code=404, detail="Podcast not found")
    return podcast


@router.post("/", response_model=PodcastResponse)
async def create_podcast(
    podcast: PodcastCreate,
    db: AsyncSession = Depends(get_db)
):
    """Create a new podcast"""
    db_podcast = Podcast(**podcast.model_dump())
    db.add(db_podcast)
    await db.commit()
    await db.refresh(db_podcast)
    return db_podcast


@router.delete("/{podcast_id}")
async def delete_podcast(podcast_id: int, db: AsyncSession = Depends(get_db)):
    """Delete a podcast"""
    from sqlalchemy import select
    result = await db.execute(select(Podcast).where(Podcast.id == podcast_id))
    podcast = result.scalar_one_or_none()
    if not podcast:
        raise HTTPException(status_code=404, detail="Podcast not found")
    await db.delete(podcast)
    await db.commit()
    return {"message": "Podcast deleted"}

