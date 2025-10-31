"""Initialize database with tables and seed data"""
import asyncio
from sqlalchemy import text
from app.database import engine, Base
from app.models.podcast import Podcast
from app.models.category import Category
from app.models.user import User
from app.models.music import MusicTrack
from app.services.media_service import MediaService
import json
from pathlib import Path
import random

async def init_db():
    """Create tables and seed initial data"""
    
    # Create all tables
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
        print("✅ Tables created")
    
    # Seed categories
    async with engine.begin() as conn:
        # Insert categories
        await conn.execute(text("""
            INSERT OR IGNORE INTO categories (id, name, type) VALUES
            (1, 'Sermons', 'podcast'),
            (2, 'Bible Study', 'podcast'),
            (3, 'Devotionals', 'podcast'),
            (4, 'Prayer', 'podcast'),
            (5, 'Worship', 'music'),
            (6, 'Gospel', 'music');
        """))
        print("✅ Categories seeded")
    
    # Seed a default user
    async with engine.begin() as conn:
        await conn.execute(text("""
            INSERT OR IGNORE INTO users (id, name, email, is_admin) VALUES
            (1, 'Admin', 'admin@christtabernacle.com', 1);
        """))
        print("✅ Default user created")
    
    # Get list of audio files
    audio_dir = Path(__file__).parent / "media" / "audio"
    audio_files = list(audio_dir.glob("*.mp3"))
    
    if not audio_files:
        print("⚠️  No audio files found in media/audio/")
        return
    
    print(f"📦 Found {len(audio_files)} audio files")
    
    # Get list of video files
    video_dir = Path(__file__).parent / "media" / "video"
    video_files = list(video_dir.glob("*.mp4")) + list(video_dir.glob("*.mov")) + list(video_dir.glob("*.avi"))
    
    print(f"🎬 Found {len(video_files)} video files")
    
    # Initialize MediaService for getting video duration
    media_service = MediaService()
    
    # Seed podcasts from audio files
    async with engine.begin() as conn:
        # Delete existing podcasts
        await conn.execute(text("DELETE FROM podcasts"))
        
        podcasts_data = []
        categories = [1, 2, 3, 4]  # sermon, bible-study, devotionals, prayer
        
        # Seed audio podcasts
        for idx, audio_file in enumerate(audio_files[:30]):  # Limit to 30
            # Parse filename: BeyondBelief-YYYYMMDD-Title.mp3
            filename = audio_file.stem
            parts = filename.split('-', 2) if '-' in filename else [filename]
            
            title = parts[-1].replace('_', ' ') if len(parts) > 1 else filename
            date_part = parts[1] if len(parts) > 1 else ''
            
            podcast_data = {
                'title': title,
                'description': f'A podcast episode about {title.lower()}',
                'audio_url': f'audio/{audio_file.name}',
                'video_url': None,
                'cover_image': None,
                'creator_id': 1,
                'category_id': random.choice(categories),
                'duration': random.randint(1800, 3600),  # 30-60 minutes
                'status': 'approved',
                'plays_count': random.randint(0, 5000),
            }
            
            await conn.execute(
                text("""
                    INSERT INTO podcasts 
                    (title, description, audio_url, video_url, cover_image, creator_id, category_id, duration, status, plays_count)
                    VALUES (:title, :description, :audio_url, :video_url, :cover_image, :creator_id, :category_id, :duration, :status, :plays_count)
                """),
                podcast_data
            )
            print(f"  ✓ Added audio podcast: {title}")
        
        # Seed video podcasts
        for video_file in video_files:
            # Parse filename - remove extension and format title
            filename = video_file.stem
            # Clean up title - remove resolution info, etc.
            title = filename.split('(')[0].strip() if '(' in filename else filename
            title = title.replace(' - Bible Chronicles Animation', '').strip()
            
            # Get video duration using MediaService
            duration = media_service.get_duration(video_file)
            if duration is None:
                duration = random.randint(600, 3600)  # 10-60 minutes fallback
            
            podcast_data = {
                'title': title,
                'description': f'Animated Bible story: {title.lower()}',
                'audio_url': None,
                'video_url': f'video/{video_file.name}',
                'cover_image': None,
                'creator_id': 1,
                'category_id': random.choice(categories),
                'duration': duration,
                'status': 'approved',
                'plays_count': random.randint(0, 5000),
            }
            
            await conn.execute(
                text("""
                    INSERT INTO podcasts 
                    (title, description, audio_url, video_url, cover_image, creator_id, category_id, duration, status, plays_count)
                    VALUES (:title, :description, :audio_url, :video_url, :cover_image, :creator_id, :category_id, :duration, :status, :plays_count)
                """),
                podcast_data
            )
            print(f"  ✓ Added video podcast: {title}")
    
    print(f"\n✅ Database initialized with {len(audio_files)} audio podcasts and {len(video_files)} video podcasts")

if __name__ == "__main__":
    asyncio.run(init_db())

