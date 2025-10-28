from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from typing import List
from app.database import get_db
from app.models import MusicTrack
from app.schemas.music import MusicTrackCreate, MusicTrackResponse

router = APIRouter()


@router.get("/tracks", response_model=List[MusicTrackResponse])
async def list_music_tracks(
    skip: int = 0,
    limit: int = 100,
    genre: str = None,
    artist: str = None,
    db: AsyncSession = Depends(get_db)
):
    """List all music tracks with optional filtering"""
    from sqlalchemy import select
    query = select(MusicTrack)
    
    if genre:
        query = query.where(MusicTrack.genre == genre)
    if artist:
        query = query.where(MusicTrack.artist == artist)
    
    query = query.offset(skip).limit(limit)
    result = await db.execute(query)
    tracks = result.scalars().all()
    return tracks


@router.get("/tracks/{track_id}", response_model=MusicTrackResponse)
async def get_music_track(track_id: int, db: AsyncSession = Depends(get_db)):
    """Get a specific music track"""
    from sqlalchemy import select
    result = await db.execute(select(MusicTrack).where(MusicTrack.id == track_id))
    track = result.scalar_one_or_none()
    if not track:
        raise HTTPException(status_code=404, detail="Music track not found")
    return track


@router.post("/tracks", response_model=MusicTrackResponse)
async def create_music_track(
    track: MusicTrackCreate,
    db: AsyncSession = Depends(get_db)
):
    """Create a new music track"""
    db_track = MusicTrack(**track.model_dump())
    db.add(db_track)
    await db.commit()
    await db.refresh(db_track)
    return db_track

