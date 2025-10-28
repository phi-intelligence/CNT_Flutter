"""Initialize database with tables and seed data"""
import asyncio
from sqlalchemy import text
from app.database import engine, Base
from app.models.podcast import Podcast
from app.models.category import Category
from app.models.user import User
from app.models.music import MusicTrack
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
    
    # Seed podcasts from audio files
    async with engine.begin() as conn:
        # Delete existing podcasts
        await conn.execute(text("DELETE FROM podcasts"))
        
        podcasts_data = []
        categories = [1, 2, 3, 4]  # sermon, bible-study, devotionals, prayer
        
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
                    (title, description, audio_url, cover_image, creator_id, category_id, duration, status, plays_count)
                    VALUES (:title, :description, :audio_url, :cover_image, :creator_id, :category_id, :duration, :status, :plays_count)
                """),
                podcast_data
            )
            print(f"  ✓ Added: {title}")
    
    print(f"\n✅ Database initialized with {len(audio_files)} podcasts")

if __name__ == "__main__":
    asyncio.run(init_db())

