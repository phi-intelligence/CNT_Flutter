from livekit import api
from app.config import settings


class LiveKitService:
    """Service for managing LiveKit rooms and access tokens"""
    
    def __init__(self):
        self.api_key = settings.LIVEKIT_API_KEY
        self.api_secret = settings.LIVEKIT_API_SECRET
        self.url = settings.LIVEKIT_URL
    
    def create_access_token(self, room_name: str, identity: str, is_host: bool = False) -> str:
        """Create an access token for joining a LiveKit room"""
        grant = api.VideoGrant(
            room_join=True,
            room=room_name,
            can_publish=is_host,
            can_subscribe=True,
        )
        
        token = api.AccessToken(self.api_key, self.api_secret) \
            .with_identity(identity) \
            .with_grants(grant) \
            .to_jwt()
        
        return token
    
    def create_room(self, room_name: str) -> dict:
        """Create a new LiveKit room"""
        # LiveKit rooms are created dynamically when first participant joins
        # Return room configuration
        return {
            "room_name": room_name,
            "url": self.url,
        }

