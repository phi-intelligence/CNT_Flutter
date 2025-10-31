from fastapi import APIRouter, UploadFile, File, Form, HTTPException
from fastapi.responses import FileResponse
from typing import Optional, List
import tempfile
import os
from pathlib import Path
from app.services.video_editing_service import VideoEditingService
from app.config import settings

router = APIRouter()
video_editing_service = VideoEditingService()

@router.post("/trim")
async def trim_video(
    video_file: UploadFile = File(...),
    start_time: float = Form(...),
    end_time: float = Form(...),
):
    """Trim video from start_time to end_time"""
    try:
        # Save uploaded file temporarily
        media_dir = Path(settings.MEDIA_STORAGE_PATH) / "video"
        media_dir.mkdir(parents=True, exist_ok=True)
        
        temp_input = media_dir / f"temp_{os.urandom(8).hex()}.mp4"
        with open(temp_input, "wb") as f:
            content = await video_file.read()
            f.write(content)
        
        try:
            output_path = video_editing_service.trim_video(
                str(temp_input),
                start_time,
                end_time
            )
            
            if not output_path:
                raise HTTPException(status_code=500, detail="Failed to trim video")
            
            # Return full path to file
            full_path = Path(settings.MEDIA_STORAGE_PATH) / output_path.lstrip("/media/")
            
            return {
                "url": output_path,
                "filename": full_path.name,
                "path": output_path
            }
        finally:
            # Clean up temp file
            if temp_input.exists():
                temp_input.unlink()
                
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/remove-audio")
async def remove_audio(
    video_file: UploadFile = File(...),
):
    """Remove audio track from video"""
    try:
        media_dir = Path(settings.MEDIA_STORAGE_PATH) / "video"
        media_dir.mkdir(parents=True, exist_ok=True)
        
        temp_input = media_dir / f"temp_{os.urandom(8).hex()}.mp4"
        with open(temp_input, "wb") as f:
            content = await video_file.read()
            f.write(content)
        
        try:
            output_path = video_editing_service.remove_audio_track(str(temp_input))
            
            if not output_path:
                raise HTTPException(status_code=500, detail="Failed to remove audio")
            
            full_path = Path(settings.MEDIA_STORAGE_PATH) / output_path.lstrip("/media/")
            
            return {
                "url": output_path,
                "filename": full_path.name,
                "path": output_path
            }
        finally:
            if temp_input.exists():
                temp_input.unlink()
                
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/add-audio")
async def add_audio(
    video_file: UploadFile = File(...),
    audio_file: UploadFile = File(...),
):
    """Add audio track to video"""
    try:
        media_dir = Path(settings.MEDIA_STORAGE_PATH) / "video"
        audio_dir = Path(settings.MEDIA_STORAGE_PATH) / "audio"
        media_dir.mkdir(parents=True, exist_ok=True)
        audio_dir.mkdir(parents=True, exist_ok=True)
        
        temp_video = media_dir / f"temp_video_{os.urandom(8).hex()}.mp4"
        temp_audio = audio_dir / f"temp_audio_{os.urandom(8).hex()}.mp3"
        
        with open(temp_video, "wb") as f:
            content = await video_file.read()
            f.write(content)
        
        with open(temp_audio, "wb") as f:
            content = await audio_file.read()
            f.write(content)
        
        try:
            output_path = video_editing_service.add_audio_track(
                str(temp_video),
                str(temp_audio)
            )
            
            if not output_path:
                raise HTTPException(status_code=500, detail="Failed to add audio")
            
            full_path = Path(settings.MEDIA_STORAGE_PATH) / output_path.lstrip("/media/")
            
            return {
                "url": output_path,
                "filename": full_path.name,
                "path": output_path
            }
        finally:
            if temp_video.exists():
                temp_video.unlink()
            if temp_audio.exists():
                temp_audio.unlink()
                
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/replace-audio")
async def replace_audio(
    video_file: UploadFile = File(...),
    audio_file: UploadFile = File(...),
):
    """Replace audio track in video"""
    try:
        media_dir = Path(settings.MEDIA_STORAGE_PATH) / "video"
        audio_dir = Path(settings.MEDIA_STORAGE_PATH) / "audio"
        media_dir.mkdir(parents=True, exist_ok=True)
        audio_dir.mkdir(parents=True, exist_ok=True)
        
        temp_video = media_dir / f"temp_video_{os.urandom(8).hex()}.mp4"
        temp_audio = audio_dir / f"temp_audio_{os.urandom(8).hex()}.mp3"
        
        with open(temp_video, "wb") as f:
            content = await video_file.read()
            f.write(content)
        
        with open(temp_audio, "wb") as f:
            content = await audio_file.read()
            f.write(content)
        
        try:
            output_path = video_editing_service.replace_audio_track(
                str(temp_video),
                str(temp_audio)
            )
            
            if not output_path:
                raise HTTPException(status_code=500, detail="Failed to replace audio")
            
            full_path = Path(settings.MEDIA_STORAGE_PATH) / output_path.lstrip("/media/")
            
            return {
                "url": output_path,
                "filename": full_path.name,
                "path": output_path
            }
        finally:
            if temp_video.exists():
                temp_video.unlink()
            if temp_audio.exists():
                temp_audio.unlink()
                
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/apply-filters")
async def apply_filters(
    video_file: UploadFile = File(...),
    brightness: Optional[float] = Form(None),
    contrast: Optional[float] = Form(None),
    saturation: Optional[float] = Form(None),
):
    """Apply filters to video"""
    try:
        media_dir = Path(settings.MEDIA_STORAGE_PATH) / "video"
        media_dir.mkdir(parents=True, exist_ok=True)
        
        temp_input = media_dir / f"temp_{os.urandom(8).hex()}.mp4"
        with open(temp_input, "wb") as f:
            content = await video_file.read()
            f.write(content)
        
        try:
            filters = {}
            if brightness is not None:
                filters['brightness'] = brightness
            if contrast is not None:
                filters['contrast'] = contrast
            if saturation is not None:
                filters['saturation'] = saturation
            
            if not filters:
                raise HTTPException(status_code=400, detail="No filters provided")
            
            output_path = video_editing_service.apply_filters(str(temp_input), filters)
            
            if not output_path:
                raise HTTPException(status_code=500, detail="Failed to apply filters")
            
            full_path = Path(settings.MEDIA_STORAGE_PATH) / output_path.lstrip("/media/")
            
            return {
                "url": output_path,
                "filename": full_path.name,
                "path": output_path
            }
        finally:
            if temp_input.exists():
                temp_input.unlink()
                
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

