import os
import ffmpeg
from pathlib import Path
from typing import Optional
from fastapi import UploadFile
from app.config import settings


class MediaService:
    """Service for handling media file operations"""
    
    def __init__(self):
        self.media_dir = Path(settings.MEDIA_STORAGE_PATH)
        self.audio_dir = self.media_dir / "audio"
        self.video_dir = self.media_dir / "video"
        self.images_dir = self.media_dir / "images"
        
        # Create directories if they don't exist
        self.audio_dir.mkdir(parents=True, exist_ok=True)
        self.video_dir.mkdir(parents=True, exist_ok=True)
        self.images_dir.mkdir(parents=True, exist_ok=True)
    
    async def save_audio_file(self, file: UploadFile, filename: str) -> str:
        """Save audio file and return the relative path"""
        file_path = self.audio_dir / filename
        
        # Save file
        with open(file_path, "wb") as f:
            content = await file.read()
            f.write(content)
        
        return f"/media/audio/{filename}"
    
    async def save_video_file(self, file: UploadFile, filename: str) -> str:
        """Save video file and return the relative path"""
        file_path = self.video_dir / filename
        
        # Save file
        with open(file_path, "wb") as f:
            content = await file.read()
            f.write(content)
        
        return f"/media/video/{filename}"
    
    async def save_image_file(self, file: UploadFile, filename: str) -> str:
        """Save image file and return the relative path"""
        file_path = self.images_dir / filename
        
        # Save file
        with open(file_path, "wb") as f:
            content = await file.read()
            f.write(content)
        
        return f"/media/images/{filename}"
    
    def get_duration(self, file_path: Path) -> Optional[int]:
        """Get media file duration in seconds using FFprobe"""
        try:
            probe = ffmpeg.probe(str(file_path))
            duration = float(probe['streams'][0]['duration'])
            return int(duration)
        except Exception as e:
            print(f"Error getting duration: {e}")
            return None
    
    def generate_thumbnail(self, video_path: Path, output_path: Path) -> bool:
        """Generate thumbnail from video file using FFmpeg"""
        try:
            (
                ffmpeg
                .input(str(video_path), ss='00:00:01')
                .output(str(output_path), vframes=1)
                .overwrite_output()
                .run(quiet=True)
            )
            return True
        except Exception as e:
            print(f"Error generating thumbnail: {e}")
            return False

