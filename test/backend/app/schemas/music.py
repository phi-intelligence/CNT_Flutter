from pydantic import BaseModel
from typing import Optional
from datetime import datetime


class MusicTrackCreate(BaseModel):
    title: str
    artist: str
    album: Optional[str] = None
    genre: Optional[str] = None
    lyrics: Optional[str] = None


class MusicTrackResponse(BaseModel):
    id: int
    title: str
    artist: str
    album: Optional[str]
    genre: Optional[str]
    audio_url: Optional[str]
    cover_image: Optional[str]
    duration: Optional[int]
    lyrics: Optional[str]
    is_featured: bool
    is_published: bool
    plays_count: int
    created_at: datetime
    
    class Config:
        from_attributes = True

