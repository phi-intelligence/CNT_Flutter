import ffmpeg
import os
import uuid
from pathlib import Path
from typing import Optional, List
from app.config import settings


class AudioEditingService:
    """Service for audio editing operations using FFmpeg"""
    
    def __init__(self):
        self.media_dir = Path(settings.MEDIA_STORAGE_PATH)
        self.audio_dir = self.media_dir / "audio"
        self.audio_dir.mkdir(parents=True, exist_ok=True)
    
    def trim_audio(self, input_path: str, start_time: float, end_time: float) -> Optional[str]:
        """
        Trim audio from start_time to end_time
        
        Args:
            input_path: Path to input audio file
            start_time: Start time in seconds
            end_time: End time in seconds
            
        Returns:
            Path to output audio file or None on error
        """
        try:
            duration = end_time - start_time
            if duration <= 0:
                return None
            
            filename = f"trimmed_{uuid.uuid4().hex[:8]}.mp3"
            output_path = self.audio_dir / filename
            
            # FFmpeg command: -ss START -i INPUT -t DURATION -c:a libmp3lame OUTPUT
            (
                ffmpeg
                .input(str(input_path), ss=start_time)
                .output(
                    str(output_path),
                    t=duration,
                    acodec='libmp3lame'
                )
                .overwrite_output()
                .run(quiet=True, capture_stdout=True, capture_stderr=True)
            )
            
            if output_path.exists():
                return f"/media/audio/{filename}"
            return None
        except Exception as e:
            print(f"Error trimming audio: {e}")
            return None
    
    def merge_audio_files(self, input_paths: List[str]) -> Optional[str]:
        """
        Merge multiple audio files into one
        
        Args:
            input_paths: List of paths to input audio files
            
        Returns:
            Path to output audio file or None on error
        """
        try:
            if not input_paths or len(input_paths) == 1:
                return input_paths[0] if input_paths else None
            
            filename = f"merged_{uuid.uuid4().hex[:8]}.mp3"
            output_path = self.audio_dir / filename
            
            # Create file list for concat filter
            concat_file = self.audio_dir / f"concat_{uuid.uuid4().hex[:8]}.txt"
            with open(concat_file, 'w') as f:
                for path in input_paths:
                    f.write(f"file '{os.path.abspath(path)}'\n")
            
            try:
                # FFmpeg command: -f concat -safe 0 -i LIST_FILE -c:a copy OUTPUT
                (
                    ffmpeg
                    .input(str(concat_file), format='concat', safe=0)
                    .output(
                        str(output_path),
                        acodec='libmp3lame'
                    )
                    .overwrite_output()
                    .run(quiet=True, capture_stdout=True, capture_stderr=True)
                )
            finally:
                # Clean up concat file
                if concat_file.exists():
                    concat_file.unlink()
            
            if output_path.exists():
                return f"/media/audio/{filename}"
            return None
        except Exception as e:
            print(f"Error merging audio: {e}")
            return None
    
    def apply_fade_in(self, input_path: str, fade_duration: float) -> Optional[str]:
        """
        Apply fade in effect to audio
        
        Args:
            input_path: Path to input audio file
            fade_duration: Fade duration in seconds
            
        Returns:
            Path to output audio file or None on error
        """
        try:
            filename = f"fadein_{uuid.uuid4().hex[:8]}.mp3"
            output_path = self.audio_dir / filename
            
            # FFmpeg command: -i INPUT -af "afade=t=in:ss=0:d=DURATION" OUTPUT
            (
                ffmpeg
                .input(str(input_path))
                .output(
                    str(output_path),
                    af=f"afade=t=in:ss=0:d={fade_duration}",
                    acodec='libmp3lame'
                )
                .overwrite_output()
                .run(quiet=True, capture_stdout=True, capture_stderr=True)
            )
            
            if output_path.exists():
                return f"/media/audio/{filename}"
            return None
        except Exception as e:
            print(f"Error applying fade in: {e}")
            return None
    
    def apply_fade_out(
        self,
        input_path: str,
        fade_duration: float,
        audio_duration: Optional[float] = None
    ) -> Optional[str]:
        """
        Apply fade out effect to audio
        
        Args:
            input_path: Path to input audio file
            fade_duration: Fade duration in seconds
            audio_duration: Total audio duration (if None, will be detected)
            
        Returns:
            Path to output audio file or None on error
        """
        try:
            # Get audio duration if not provided
            if audio_duration is None:
                probe = ffmpeg.probe(str(input_path))
                audio_duration = float(probe['format']['duration'])
            
            fade_start = audio_duration - fade_duration
            if fade_start < 0:
                fade_start = 0
            
            filename = f"fadeout_{uuid.uuid4().hex[:8]}.mp3"
            output_path = self.audio_dir / filename
            
            # FFmpeg command: -i INPUT -af "afade=t=out:st=START:d=DURATION" OUTPUT
            (
                ffmpeg
                .input(str(input_path))
                .output(
                    str(output_path),
                    af=f"afade=t=out:st={fade_start}:d={fade_duration}",
                    acodec='libmp3lame'
                )
                .overwrite_output()
                .run(quiet=True, capture_stdout=True, capture_stderr=True)
            )
            
            if output_path.exists():
                return f"/media/audio/{filename}"
            return None
        except Exception as e:
            print(f"Error applying fade out: {e}")
            return None
    
    def apply_fade_in_out(
        self,
        input_path: str,
        fade_in_duration: float,
        fade_out_duration: float,
        audio_duration: Optional[float] = None
    ) -> Optional[str]:
        """
        Apply fade in and fade out effects to audio
        
        Args:
            input_path: Path to input audio file
            fade_in_duration: Fade in duration in seconds
            fade_out_duration: Fade out duration in seconds
            audio_duration: Total audio duration (if None, will be detected)
            
        Returns:
            Path to output audio file or None on error
        """
        try:
            # Get audio duration if not provided
            if audio_duration is None:
                probe = ffmpeg.probe(str(input_path))
                audio_duration = float(probe['format']['duration'])
            
            fade_out_start = audio_duration - fade_out_duration
            if fade_out_start < 0:
                fade_out_start = 0
            
            filename = f"fadeinout_{uuid.uuid4().hex[:8]}.mp3"
            output_path = self.audio_dir / filename
            
            # Build combined fade filter
            fade_filter = f"afade=t=in:ss=0:d={fade_in_duration},afade=t=out:st={fade_out_start}:d={fade_out_duration}"
            
            # FFmpeg command: -i INPUT -af "FADE_FILTER" OUTPUT
            (
                ffmpeg
                .input(str(input_path))
                .output(
                    str(output_path),
                    af=fade_filter,
                    acodec='libmp3lame'
                )
                .overwrite_output()
                .run(quiet=True, capture_stdout=True, capture_stderr=True)
            )
            
            if output_path.exists():
                return f"/media/audio/{filename}"
            return None
        except Exception as e:
            print(f"Error applying fade in/out: {e}")
            return None

