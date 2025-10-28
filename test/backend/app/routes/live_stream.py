from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from typing import List
from app.database import get_db
from app.models import LiveStream
from pydantic import BaseModel
from datetime import datetime


class LiveStreamResponse(BaseModel):
    id: int
    host_id: int
    title: str
    description: str = None
    thumbnail: str = None
    category: str = None
    room_name: str
    status: str
    viewer_count: int
    scheduled_start: datetime = None
    started_at: datetime = None
    ended_at: datetime = None
    created_at: datetime
    
    class Config:
        from_attributes = True


class LiveStreamCreate(BaseModel):
    title: str
    description: str = None
    thumbnail: str = None
    category: str = None
    scheduled_start: datetime = None


class LiveStreamJoin(BaseModel):
    identity: str  # User identifier


router = APIRouter()
from app.services.livekit_service import LiveKitService
livekit_service = LiveKitService()


@router.get("/streams", response_model=List[LiveStreamResponse])
async def list_streams(
    status: str = None,
    db: AsyncSession = Depends(get_db)
):
    """List all live streams"""
    from sqlalchemy import select
    query = select(LiveStream)
    
    if status:
        query = query.where(LiveStream.status == status)
    
    result = await db.execute(query)
    streams = result.scalars().all()
    return streams


@router.post("/streams", response_model=LiveStreamResponse)
async def create_stream(
    stream: LiveStreamCreate,
    db: AsyncSession = Depends(get_db)
):
    """Create a new live stream"""
    import uuid
    room_name = f"room_{uuid.uuid4().hex[:12]}"
    
    db_stream = LiveStream(
        host_id=1,  # TODO: get from auth
        room_name=room_name,
        **stream.model_dump()
    )
    db.add(db_stream)
    await db.commit()
    await db.refresh(db_stream)
    return db_stream


@router.post("/streams/{stream_id}/join")
async def join_stream(
    stream_id: int,
    join_request: LiveStreamJoin,
    db: AsyncSession = Depends(get_db),
    is_host: bool = False
):
    """Join a live stream and get access token"""
    from sqlalchemy import select
    
    # Get stream from database
    result = await db.execute(
        select(LiveStream).where(LiveStream.id == stream_id)
    )
    stream = result.scalar_one_or_none()
    
    if not stream:
        raise HTTPException(status_code=404, detail="Stream not found")
    
    # Create access token
    token = livekit_service.create_access_token(
        room_name=stream.room_name,
        identity=join_request.identity,
        is_host=is_host
    )
    
    return {
        "token": token,
        "url": livekit_service.url,
        "room_name": stream.room_name
    }

