import ffmpeg
import os
import uuid
from pathlib import Path
from typing import Optional, Dict
from app.config import settings


class VideoEditingService:
    """Service for video editing operations using FFmpeg"""
    
    def __init__(self):
        self.media_dir = Path(settings.MEDIA_STORAGE_PATH)
        self.video_dir = self.media_dir / "video"
        self.video_dir.mkdir(parents=True, exist_ok=True)
    
    def trim_video(self, input_path: str, start_time: float, end_time: float) -> Optional[str]:
        """
        Trim video from start_time to end_time
        
        Args:
            input_path: Path to input video file
            start_time: Start time in seconds
            end_time: End time in seconds
            
        Returns:
            Path to output video file or None on error
        """
        try:
            duration = end_time - start_time
            if duration <= 0:
                return None
            
            # Generate output filename
            filename = f"trimmed_{uuid.uuid4().hex[:8]}.mp4"
            output_path = self.video_dir / filename
            
            # FFmpeg command: -ss START -i INPUT -t DURATION -c copy OUTPUT
            # Using copy codec for fast trimming without re-encoding
            (
                ffmpeg
                .input(str(input_path), ss=start_time)
                .output(
                    str(output_path),
                    t=duration,
                    vcodec='copy',
                    acodec='copy',
                    **{'c:v': 'copy', 'c:a': 'copy'}
                )
                .overwrite_output()
                .run(quiet=True, capture_stdout=True, capture_stderr=True)
            )
            
            if output_path.exists():
                return f"/media/video/{filename}"
            return None
        except Exception as e:
            print(f"Error trimming video: {e}")
            return None
    
    def remove_audio_track(self, input_path: str) -> Optional[str]:
        """
        Remove audio track from video
        
        Args:
            input_path: Path to input video file
            
        Returns:
            Path to output video file or None on error
        """
        try:
            filename = f"no_audio_{uuid.uuid4().hex[:8]}.mp4"
            output_path = self.video_dir / filename
            
            # FFmpeg command: -i INPUT -c:v copy -an OUTPUT
            (
                ffmpeg
                .input(str(input_path))
                .output(
                    str(output_path),
                    vcodec='copy',
                    an=None  # Remove audio
                )
                .overwrite_output()
                .run(quiet=True, capture_stdout=True, capture_stderr=True)
            )
            
            if output_path.exists():
                return f"/media/video/{filename}"
            return None
        except Exception as e:
            print(f"Error removing audio: {e}")
            return None
    
    def add_audio_track(self, video_path: str, audio_path: str) -> Optional[str]:
        """
        Add audio track to video
        
        Args:
            video_path: Path to input video file
            audio_path: Path to input audio file
            
        Returns:
            Path to output video file or None on error
        """
        try:
            filename = f"with_audio_{uuid.uuid4().hex[:8]}.mp4"
            output_path = self.video_dir / filename
            
            # FFmpeg command: -i VIDEO -i AUDIO -c:v copy -c:a aac -shortest OUTPUT
            video_input = ffmpeg.input(str(video_path))
            audio_input = ffmpeg.input(str(audio_path))
            
            (
                ffmpeg
                .concat(
                    video_input,
                    audio_input,
                    v=1,
                    a=1
                )
                .output(
                    str(output_path),
                    vcodec='copy',
                    acodec='aac',
                    shortest=None
                )
                .overwrite_output()
                .run(quiet=True, capture_stdout=True, capture_stderr=True)
            )
            
            if output_path.exists():
                return f"/media/video/{filename}"
            return None
        except Exception as e:
            print(f"Error adding audio: {e}")
            # Try alternative method
            try:
                video_input = ffmpeg.input(str(video_path))
                audio_input = ffmpeg.input(str(audio_path))
                
                (
                    ffmpeg
                    .output(
                        video_input,
                        audio_input,
                        str(output_path),
                        vcodec='copy',
                        acodec='aac',
                        shortest=None
                    )
                    .overwrite_output()
                    .run(quiet=True, capture_stdout=True, capture_stderr=True)
                )
                
                if output_path.exists():
                    return f"/media/video/{filename}"
            except Exception as e2:
                print(f"Error adding audio (alternative method): {e2}")
            return None
    
    def replace_audio_track(self, video_path: str, audio_path: str) -> Optional[str]:
        """
        Replace audio track in video
        
        Args:
            video_path: Path to input video file
            audio_path: Path to input audio file
            
        Returns:
            Path to output video file or None on error
        """
        try:
            filename = f"replaced_audio_{uuid.uuid4().hex[:8]}.mp4"
            output_path = self.video_dir / filename
            
            # FFmpeg command: -i VIDEO -i AUDIO -c:v copy -c:a aac -map 0:v:0 -map 1:a:0 -shortest OUTPUT
            video_input = ffmpeg.input(str(video_path))
            audio_input = ffmpeg.input(str(audio_path))
            
            (
                ffmpeg
                .output(
                    video_input,
                    audio_input,
                    str(output_path),
                    vcodec='copy',
                    acodec='aac',
                    map=['0:v:0', '1:a:0'],
                    shortest=None
                )
                .overwrite_output()
                .run(quiet=True, capture_stdout=True, capture_stderr=True)
            )
            
            if output_path.exists():
                return f"/media/video/{filename}"
            return None
        except Exception as e:
            print(f"Error replacing audio: {e}")
            return None
    
    def apply_filters(
        self,
        input_path: str,
        filters: Dict[str, float]
    ) -> Optional[str]:
        """
        Apply filters to video
        
        Args:
            input_path: Path to input video file
            filters: Dictionary with filter values (brightness, contrast, saturation)
            
        Returns:
            Path to output video file or None on error
        """
        try:
            filename = f"filtered_{uuid.uuid4().hex[:8]}.mp4"
            output_path = self.video_dir / filename
            
            # Build filter string
            filter_parts = []
            
            if 'brightness' in filters:
                brightness = filters['brightness']
                filter_parts.append(f"eq=brightness={brightness:.2f}")
            
            if 'contrast' in filters:
                contrast = filters['contrast']
                filter_parts.append(f"eq=contrast={contrast:.2f}")
            
            if 'saturation' in filters:
                saturation = filters['saturation']
                filter_parts.append(f"eq=saturation={saturation:.2f}")
            
            if not filter_parts:
                return None  # No filters to apply
            
            filter_string = ':'.join(filter_parts)
            
            # FFmpeg command: -i INPUT -vf "FILTERS" -c:a copy OUTPUT
            (
                ffmpeg
                .input(str(input_path))
                .output(
                    str(output_path),
                    vf=filter_string,
                    acodec='copy'
                )
                .overwrite_output()
                .run(quiet=True, capture_stdout=True, capture_stderr=True)
            )
            
            if output_path.exists():
                return f"/media/video/{filename}"
            return None
        except Exception as e:
            print(f"Error applying filters: {e}")
            return None

