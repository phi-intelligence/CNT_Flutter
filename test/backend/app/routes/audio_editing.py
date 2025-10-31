from fastapi import APIRouter, UploadFile, File, Form, HTTPException, Request
from typing import Optional
import os
from pathlib import Path
from app.services.audio_editing_service import AudioEditingService
from app.config import settings

router = APIRouter()
audio_editing_service = AudioEditingService()

@router.post("/trim")
async def trim_audio(
    audio_file: UploadFile = File(...),
    start_time: float = Form(...),
    end_time: float = Form(...),
):
    """Trim audio from start_time to end_time"""
    try:
        audio_dir = Path(settings.MEDIA_STORAGE_PATH) / "audio"
        audio_dir.mkdir(parents=True, exist_ok=True)
        
        temp_input = audio_dir / f"temp_{os.urandom(8).hex()}.mp3"
        with open(temp_input, "wb") as f:
            content = await audio_file.read()
            f.write(content)
        
        try:
            output_path = audio_editing_service.trim_audio(
                str(temp_input),
                start_time,
                end_time
            )
            
            if not output_path:
                raise HTTPException(status_code=500, detail="Failed to trim audio")
            
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

@router.post("/merge")
async def merge_audio(
    request: Request,
):
    """Merge multiple audio files into one"""
    try:
        form = await request.form()
        audio_files = form.getlist("audio_files")  # Get list of files with field name "audio_files"
        
        if not audio_files or len(audio_files) < 2:
            raise HTTPException(status_code=400, detail="At least 2 audio files required")
        
        audio_dir = Path(settings.MEDIA_STORAGE_PATH) / "audio"
        audio_dir.mkdir(parents=True, exist_ok=True)
        
        temp_inputs = []
        try:
            for audio_file in audio_files:
                if isinstance(audio_file, UploadFile):
                    temp_input = audio_dir / f"temp_{os.urandom(8).hex()}.mp3"
                    with open(temp_input, "wb") as f:
                        content = await audio_file.read()
                        f.write(content)
                    temp_inputs.append(str(temp_input))
            
            if len(temp_inputs) < 2:
                raise HTTPException(status_code=400, detail="At least 2 audio files required")
            
            output_path = audio_editing_service.merge_audio_files(temp_inputs)
            
            if not output_path:
                raise HTTPException(status_code=500, detail="Failed to merge audio")
            
            full_path = Path(settings.MEDIA_STORAGE_PATH) / output_path.lstrip("/media/")
            
            return {
                "url": output_path,
                "filename": full_path.name,
                "path": output_path
            }
        finally:
            for temp_input in temp_inputs:
                if os.path.exists(temp_input):
                    os.unlink(temp_input)
                
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/fade-in")
async def fade_in_audio(
    audio_file: UploadFile = File(...),
    fade_duration: float = Form(...),
):
    """Apply fade in effect to audio"""
    try:
        audio_dir = Path(settings.MEDIA_STORAGE_PATH) / "audio"
        audio_dir.mkdir(parents=True, exist_ok=True)
        
        temp_input = audio_dir / f"temp_{os.urandom(8).hex()}.mp3"
        with open(temp_input, "wb") as f:
            content = await audio_file.read()
            f.write(content)
        
        try:
            output_path = audio_editing_service.apply_fade_in(str(temp_input), fade_duration)
            
            if not output_path:
                raise HTTPException(status_code=500, detail="Failed to apply fade in")
            
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

@router.post("/fade-out")
async def fade_out_audio(
    audio_file: UploadFile = File(...),
    fade_duration: float = Form(...),
    audio_duration: Optional[float] = Form(None),
):
    """Apply fade out effect to audio"""
    try:
        audio_dir = Path(settings.MEDIA_STORAGE_PATH) / "audio"
        audio_dir.mkdir(parents=True, exist_ok=True)
        
        temp_input = audio_dir / f"temp_{os.urandom(8).hex()}.mp3"
        with open(temp_input, "wb") as f:
            content = await audio_file.read()
            f.write(content)
        
        try:
            output_path = audio_editing_service.apply_fade_out(
                str(temp_input),
                fade_duration,
                audio_duration
            )
            
            if not output_path:
                raise HTTPException(status_code=500, detail="Failed to apply fade out")
            
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

@router.post("/fade-in-out")
async def fade_in_out_audio(
    audio_file: UploadFile = File(...),
    fade_in_duration: float = Form(...),
    fade_out_duration: float = Form(...),
    audio_duration: Optional[float] = Form(None),
):
    """Apply fade in and fade out effects to audio"""
    try:
        audio_dir = Path(settings.MEDIA_STORAGE_PATH) / "audio"
        audio_dir.mkdir(parents=True, exist_ok=True)
        
        temp_input = audio_dir / f"temp_{os.urandom(8).hex()}.mp3"
        with open(temp_input, "wb") as f:
            content = await audio_file.read()
            f.write(content)
        
        try:
            output_path = audio_editing_service.apply_fade_in_out(
                str(temp_input),
                fade_in_duration,
                fade_out_duration,
                audio_duration
            )
            
            if not output_path:
                raise HTTPException(status_code=500, detail="Failed to apply fade in/out")
            
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

