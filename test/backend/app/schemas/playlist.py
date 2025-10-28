from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime


class PlaylistCreate(BaseModel):
    name: str
    description: Optional[str] = None
    cover_image: Optional[str] = None


class PlaylistItemCreate(BaseModel):
    content_type: str  # podcast, music
    content_id: int
    position: int


class PlaylistResponse(BaseModel):
    id: int
    user_id: int
    name: str
    description: Optional[str]
    cover_image: Optional[str]
    created_at: datetime
    
    class Config:
        from_attributes = True

