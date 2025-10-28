from sqlalchemy import Column, Integer, String, Text, DateTime, Boolean
from sqlalchemy.sql import func
from app.database import Base


class MusicTrack(Base):
    __tablename__ = "music_tracks"
    
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, nullable=False)
    artist = Column(String, nullable=False)
    album = Column(String, nullable=True)
    genre = Column(String, nullable=True)
    audio_url = Column(String, nullable=False)
    cover_image = Column(String, nullable=True)
    duration = Column(Integer, nullable=True)
    lyrics = Column(Text, nullable=True)
    is_featured = Column(Boolean, default=False)
    is_published = Column(Boolean, default=True)
    plays_count = Column(Integer, default=0)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

