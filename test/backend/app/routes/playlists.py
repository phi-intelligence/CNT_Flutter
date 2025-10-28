from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from typing import List
from app.database import get_db
from app.models import Playlist, PlaylistItem
from app.schemas.playlist import PlaylistCreate, PlaylistResponse

router = APIRouter()


@router.get("/", response_model=List[PlaylistResponse])
async def list_playlists(
    skip: int = 0,
    limit: int = 100,
    db: AsyncSession = Depends(get_db)
):
    """List all playlists"""
    from sqlalchemy import select
    result = await db.execute(select(Playlist).offset(skip).limit(limit))
    playlists = result.scalars().all()
    return playlists


@router.get("/{playlist_id}", response_model=PlaylistResponse)
async def get_playlist(playlist_id: int, db: AsyncSession = Depends(get_db)):
    """Get a specific playlist"""
    from sqlalchemy import select
    result = await db.execute(select(Playlist).where(Playlist.id == playlist_id))
    playlist = result.scalar_one_or_none()
    if not playlist:
        raise HTTPException(status_code=404, detail="Playlist not found")
    return playlist


@router.post("/", response_model=PlaylistResponse)
async def create_playlist(
    playlist: PlaylistCreate,
    db: AsyncSession = Depends(get_db)
):
    """Create a new playlist"""
    db_playlist = Playlist(user_id=1, **playlist.model_dump())  # TODO: get from auth
    db.add(db_playlist)
    await db.commit()
    await db.refresh(db_playlist)
    return db_playlist

