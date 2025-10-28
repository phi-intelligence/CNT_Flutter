from fastapi import APIRouter, UploadFile, File, HTTPException
from pathlib import Path
import uuid
from app.services.media_service import MediaService

router = APIRouter()
media_service = MediaService()


@router.post("/audio")
async def upload_audio(
    file: UploadFile = File(...)
):
    """Upload audio file"""
    # Validate file type
    if not file.content_type.startswith('audio/'):
        raise HTTPException(status_code=400, detail="File must be an audio file")
    
    # Generate unique filename
    file_extension = Path(file.filename).suffix
    filename = f"{uuid.uuid4()}{file_extension}"
    
    # Save file
    relative_path = await media_service.save_audio_file(file, filename)
    
    return {
        "filename": filename,
        "url": relative_path,
        "content_type": file.content_type
    }


@router.post("/video")
async def upload_video(
    file: UploadFile = File(...)
):
    """Upload video file"""
    # Validate file type
    if not file.content_type.startswith('video/'):
        raise HTTPException(status_code=400, detail="File must be a video file")
    
    # Generate unique filename
    file_extension = Path(file.filename).suffix
    filename = f"{uuid.uuid4()}{file_extension}"
    
    # Save file
    relative_path = await media_service.save_video_file(file, filename)
    
    return {
        "filename": filename,
        "url": relative_path,
        "content_type": file.content_type
    }


@router.post("/image")
async def upload_image(
    file: UploadFile = File(...)
):
    """Upload image file"""
    # Validate file type
    if not file.content_type.startswith('image/'):
        raise HTTPException(status_code=400, detail="File must be an image file")
    
    # Generate unique filename
    file_extension = Path(file.filename).suffix
    filename = f"{uuid.uuid4()}{file_extension}"
    
    # Save file
    relative_path = await media_service.save_image_file(file, filename)
    
    return {
        "filename": filename,
        "url": relative_path,
        "content_type": file.content_type
    }

