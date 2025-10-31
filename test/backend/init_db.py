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
    
    # Seed users (for community posts)
    async with engine.begin() as conn:
        await conn.execute(text("""
            INSERT OR IGNORE INTO users (id, name, email, is_admin) VALUES
            (1, 'Admin', 'admin@christtabernacle.com', 1),
            (2, 'Samuel', 'samuel@christtabernacle.com', 0),
            (3, 'Grace', 'grace@christtabernacle.com', 0),
            (4, 'Elise', 'elise@christtabernacle.com', 0),
            (5, 'John', 'john@christtabernacle.com', 0),
            (6, 'Sarah', 'sarah@christtabernacle.com', 0),
            (7, 'Michael', 'michael@christtabernacle.com', 0),
            (8, 'David', 'david@christtabernacle.com', 0);
        """))
        print("✅ Users seeded")
    
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
    
    # Seed community posts (Instagram-like posts)
    async with engine.begin() as conn:
        # Delete existing posts
        await conn.execute(text("DELETE FROM community_posts"))
        await conn.execute(text("DELETE FROM likes"))
        await conn.execute(text("DELETE FROM comments"))
        
        # Mock community posts with images
        # Using images from frontend/assets/images/ folder
        # Images will be accessed via /media/images/ path
        community_posts = [
            {
                'user_id': 2,  # Samuel
                'title': 'elise good times. great vibes.',
                'content': 'elise good times. great vibes.',
                'image_url': 'assets/images/thumbnail1.jpg',
                'category': 'general',
                'likes_count': 42,
                'comments_count': 5,
            },
            {
                'user_id': 3,  # Grace
                'title': 'Blessed Sunday Morning',
                'content': 'Blessed Sunday Morning',
                'image_url': 'assets/images/thumb2.jpg',
                'category': 'testimony',
                'likes_count': 67,
                'comments_count': 12,
            },
            {
                'user_id': 4,  # Elise
                'title': 'Beautiful Day',
                'content': 'Beautiful Day',
                'image_url': 'assets/images/thumb3.jpg',
                'category': 'general',
                'likes_count': 89,
                'comments_count': 8,
            },
            {
                'user_id': 5,  # John
                'title': 'Prayer Meeting',
                'content': 'Prayer Meeting',
                'image_url': 'assets/images/thumb4.jpg',
                'category': 'prayer_request',
                'likes_count': 53,
                'comments_count': 15,
            },
            {
                'user_id': 6,  # Sarah
                'title': 'Grateful for Today',
                'content': 'Grateful for Today',
                'image_url': 'assets/images/thumb5.jpg',
                'category': 'testimony',
                'likes_count': 74,
                'comments_count': 9,
            },
            {
                'user_id': 7,  # Michael
                'title': 'Faith Journey',
                'content': 'Faith Journey',
                'image_url': 'assets/images/thumb6.jpg',
                'category': 'testimony',
                'likes_count': 91,
                'comments_count': 22,
            },
            {
                'user_id': 8,  # David
                'title': 'Worship Night',
                'content': 'Worship Night',
                'image_url': 'assets/images/thumb7.jpg',
                'category': 'announcement',
                'likes_count': 108,
                'comments_count': 18,
            },
            {
                'user_id': 2,  # Samuel
                'title': 'God is Good',
                'content': 'God is Good',
                'image_url': 'assets/images/thumb8.jpg',
                'category': 'general',
                'likes_count': 126,
                'comments_count': 31,
            },
        ]
        
        # Insert community posts
        for post_data in community_posts:
            await conn.execute(
                text("""
                    INSERT INTO community_posts 
                    (user_id, title, content, image_url, category, likes_count, comments_count)
                    VALUES (:user_id, :title, :content, :image_url, :category, :likes_count, :comments_count)
                """),
                post_data
            )
            print(f"  ✓ Added community post: {post_data['title']}")
        
        # Get post IDs for likes
        post_result = await conn.execute(text("SELECT id, user_id FROM community_posts ORDER BY id"))
        posts = post_result.fetchall()
        
        # Add mock likes (users liking various posts)
        # User 1 (Admin) likes some posts
        # User 2 (Samuel) likes posts from others
        # User 3 (Grace) likes posts
        # etc.
        like_combinations = [
            (1, 1), (2, 1), (3, 1),  # Post 1 liked by users 1, 2, 3
            (1, 2), (3, 2), (4, 2), (5, 2),  # Post 2 liked by users 1, 3, 4, 5
            (1, 3), (2, 3), (6, 3), (7, 3),  # Post 3 liked by users 1, 2, 6, 7
            (2, 4), (3, 4), (5, 4),  # Post 4 liked by users 2, 3, 5
            (1, 5), (3, 5), (4, 5), (7, 5),  # Post 5 liked by users 1, 3, 4, 7
            (1, 6), (2, 6), (3, 6), (5, 6), (8, 6),  # Post 6 liked by users 1, 2, 3, 5, 8
            (1, 7), (2, 7), (3, 7), (4, 7), (5, 7), (6, 7),  # Post 7 liked by users 1-6
            (1, 8), (3, 8), (4, 8), (5, 8), (6, 8), (7, 8),  # Post 8 liked by users 1, 3-7
        ]
        
        # Only add likes where user_id != post owner (can't like own post)
        for user_id, post_id in like_combinations:
            # Check if user owns the post
            post_owner = next((p[1] for p in posts if p[0] == post_id), None)
            if post_owner != user_id:
                await conn.execute(
                    text("""
                        INSERT INTO likes (post_id, user_id)
                        VALUES (:post_id, :user_id)
                    """),
                    {'post_id': post_id, 'user_id': user_id}
                )
        
        print(f"  ✓ Added {len(like_combinations)} likes to community posts")
        
        # Add some mock comments
        comments_data = [
            (1, 1, 'Beautiful! 🙏'),
            (2, 1, 'Amazing!'),
            (3, 2, 'God bless!'),
            (4, 2, 'Praying for you!'),
            (5, 3, 'Love this! ❤️'),
            (6, 4, 'Amen!'),
            (7, 5, 'So inspiring!'),
            (8, 6, 'Thank you for sharing!'),
        ]
        
        for user_id, post_id, content in comments_data:
            await conn.execute(
                text("""
                    INSERT INTO comments (post_id, user_id, content)
                    VALUES (:post_id, :user_id, :content)
                """),
                {'post_id': post_id, 'user_id': user_id, 'content': content}
            )
        
        print(f"  ✓ Added {len(comments_data)} comments to community posts")
    
    print(f"\n✅ Community posts seeded with {len(community_posts)} posts")

if __name__ == "__main__":
    asyncio.run(init_db())

