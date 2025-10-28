# Pydantic schemas for request/response validation
from .podcast import PodcastCreate, PodcastResponse
from .music import MusicTrackCreate, MusicTrackResponse
from .playlist import PlaylistCreate, PlaylistResponse
from .user import UserResponse

__all__ = [
    "PodcastCreate",
    "PodcastResponse",
    "MusicTrackCreate",
    "MusicTrackResponse",
    "PlaylistCreate",
    "PlaylistResponse",
    "UserResponse",
]

