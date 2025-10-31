from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from typing import List, Optional
from app.database import get_db
from app.models import LiveStream
from pydantic import BaseModel
from datetime import datetime


class LiveStreamResponse(BaseModel):
    id: int
    host_id: int
    title: str
    description: Optional[str] = None
    thumbnail: Optional[str] = None
    category: Optional[str] = None
    room_name: str
    status: str
    viewer_count: int
    scheduled_start: Optional[datetime] = None
    started_at: Optional[datetime] = None
    ended_at: Optional[datetime] = None
    created_at: datetime
    
    class Config:
        from_attributes = True


class LiveStreamCreate(BaseModel):
    title: str
    description: Optional[str] = None
    thumbnail: Optional[str] = None
    category: Optional[str] = None
    scheduled_start: Optional[datetime] = None


class LiveStreamJoin(BaseModel):
    identity: str  # User identifier
    name: str = "User"  # User display name
    email: Optional[str] = None  # User email (optional)


router = APIRouter()
from app.services.jitsi_service import JitsiService
jitsi_service = JitsiService()


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
    """Create a new live stream/meeting"""
    import uuid
    from sqlalchemy.exc import IntegrityError
    
    try:
        # Generate Jitsi-compatible room name (lowercase, alphanumeric, hyphens)
        base_room_name = stream.title.lower().replace(" ", "-") if stream.title else "meeting"
        # Sanitize and ensure uniqueness
        room_name = jitsi_service.sanitize_room_name(base_room_name)
        room_name = f"{room_name}-{uuid.uuid4().hex[:8]}"
        
        # Filter out None values from model_dump to avoid setting None on non-nullable fields
        stream_data = {k: v for k, v in stream.model_dump().items() if v is not None}
        
        db_stream = LiveStream(
            host_id=1,  # TODO: get from auth
            room_name=room_name,
            **stream_data
        )
        db.add(db_stream)
        await db.commit()
        await db.refresh(db_stream)
        return db_stream
    except IntegrityError as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=f"Room name conflict: {str(e)}")
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=500, detail=f"Failed to create stream: {str(e)}")


@router.post("/streams/{stream_id}/join")
async def join_stream(
    stream_id: int,
    join_request: LiveStreamJoin,
    db: AsyncSession = Depends(get_db),
    is_host: bool = False
):
    """Join a meeting/stream and get JWT token for Jitsi Meet"""
    from sqlalchemy import select
    
    # Get stream from database
    result = await db.execute(
        select(LiveStream).where(LiveStream.id == stream_id)
    )
    stream = result.scalar_one_or_none()
    
    if not stream:
        raise HTTPException(status_code=404, detail="Stream/Meeting not found")
    
    # Validate room name is Jitsi-compatible
    if not jitsi_service.validate_room_name(stream.room_name):
        # Sanitize if invalid
        stream.room_name = jitsi_service.sanitize_room_name(stream.room_name)
        db.add(stream)
        await db.commit()
    
    # Create JWT token for Jitsi Meet
    token = jitsi_service.create_jwt_token(
        room_name=stream.room_name,
        user_id=join_request.identity,
        user_name=join_request.name,
        user_email=join_request.email,
        is_moderator=is_host,
        audio_enabled=True,
        video_enabled=True,
    )
    
    return {
        "token": token,
        "url": jitsi_service.server_url,
        "room_name": stream.room_name
    }


@router.post("/streams/by-room/{room_name}/join")
async def join_stream_by_room(
    room_name: str,
    join_request: LiveStreamJoin,
    db: AsyncSession = Depends(get_db),
    is_host: bool = False,
):
    """Join a meeting/stream by room name and get JWT token for Jitsi Meet"""
    from sqlalchemy import select

    room = jitsi_service.sanitize_room_name(room_name)

    result = await db.execute(
        select(LiveStream).where(LiveStream.room_name == room)
    )
    stream = result.scalar_one_or_none()

    if not stream:
        raise HTTPException(status_code=404, detail="Stream/Meeting not found")

    token = jitsi_service.create_jwt_token(
        room_name=stream.room_name,
        user_id=join_request.identity,
        user_name=join_request.name,
        user_email=join_request.email,
        is_moderator=is_host,
        audio_enabled=True,
        video_enabled=True,
    )

    return {
        "token": token,
        "url": jitsi_service.server_url,
        "room_name": stream.room_name,
    }

