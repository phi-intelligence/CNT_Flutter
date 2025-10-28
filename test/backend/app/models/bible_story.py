from sqlalchemy import Column, Integer, String, Text, DateTime
from sqlalchemy.sql import func
from app.database import Base


class BibleStory(Base):
    __tablename__ = "bible_stories"
    
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, nullable=False)
    scripture_reference = Column(String, nullable=False)  # e.g., "John 3:16"
    content = Column(Text, nullable=False)
    audio_url = Column(String, nullable=True)
    cover_image = Column(String, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

