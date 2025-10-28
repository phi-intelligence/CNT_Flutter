from pydantic import BaseModel
from typing import Optional
from datetime import datetime


class PodcastCreate(BaseModel):
    title: str
    description: Optional[str] = None
    category_id: Optional[int] = None


class PodcastResponse(BaseModel):
    id: int
    title: str
    description: Optional[str]
    audio_url: Optional[str]
    video_url: Optional[str]
    cover_image: Optional[str]
    creator_id: Optional[int]
    category_id: Optional[int]
    duration: Optional[int]
    status: str
    plays_count: int
    created_at: datetime
    
    class Config:
        from_attributes = True

