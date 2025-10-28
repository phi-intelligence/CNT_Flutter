from fastapi import APIRouter

# Create main router
api_router = APIRouter()

# Import and include sub-routers
from .podcasts import router as podcasts_router
from .music import router as music_router
from .playlists import router as playlists_router
from .bible_stories import router as bible_stories_router
from .community import router as community_router
from .live_stream import router as live_stream_router
from .categories import router as categories_router
from .upload import router as upload_router
from .voice_chat import router as voice_chat_router

api_router.include_router(podcasts_router, prefix="/podcasts", tags=["podcasts"])
api_router.include_router(music_router, prefix="/music", tags=["music"])
api_router.include_router(playlists_router, prefix="/playlists", tags=["playlists"])
api_router.include_router(bible_stories_router, prefix="/bible-stories", tags=["bible-stories"])
api_router.include_router(community_router, prefix="/community", tags=["community"])
api_router.include_router(live_stream_router, prefix="/live", tags=["live-stream"])
api_router.include_router(categories_router, prefix="/categories", tags=["categories"])
api_router.include_router(upload_router, prefix="/upload", tags=["upload"])
api_router.include_router(voice_chat_router, prefix="/voice", tags=["voice-chat"])

