import jwt
import time
from datetime import datetime, timedelta
from typing import Optional
from app.config import settings


class JitsiService:
    """Service for managing Jitsi Meet rooms and JWT tokens"""
    
    def __init__(self):
        self.app_id = settings.JITSI_APP_ID
        self.app_secret = settings.JITSI_APP_SECRET
        self.server_url = settings.JITSI_SERVER_URL
        self.jwt_expiration = settings.JITSI_JWT_EXPIRATION
    
    def create_jwt_token(
        self,
        room_name: str,
        user_id: str,
        user_name: Optional[str] = None,
        user_email: Optional[str] = None,
        is_moderator: bool = False,
        audio_enabled: bool = True,
        video_enabled: bool = True,
    ) -> str:
        """
        Create a JWT token for joining a Jitsi Meet room
        
        Args:
            room_name: Name of the Jitsi room
            user_id: Unique identifier for the user
            user_name: Display name for the user
            user_email: Email address of the user (optional)
            is_moderator: Whether the user has moderator permissions
            audio_enabled: Whether audio is enabled by default
            video_enabled: Whether video is enabled by default
            
        Returns:
            JWT token string
        """
        # Get server domain from URL (remove protocol)
        server_domain = self.server_url.replace("https://", "").replace("http://", "")
        
        # Calculate expiration time
        exp = int(time.time()) + self.jwt_expiration
        
        # Build JWT payload according to Jitsi JWT format
        payload = {
            "iss": self.app_id,  # Issuer (app ID)
            "aud": self.app_id,  # Audience (app ID)
            "sub": server_domain,  # Subject (Jitsi server domain)
            "room": room_name,  # Room name
            "exp": exp,  # Expiration time
            "moderator": is_moderator,  # Moderator permissions
            "audio": audio_enabled,  # Audio enabled
            "video": video_enabled,  # Video enabled
        }
        
        # Add user information if provided
        if user_name:
            payload["name"] = user_name
        if user_email:
            payload["email"] = user_email
        
        # Generate JWT token using HS256 algorithm
        token = jwt.encode(
            payload,
            self.app_secret,
            algorithm="HS256"
        )
        
        return token
    
    def create_room_config(self, room_name: str) -> dict:
        """
        Create room configuration dictionary
        
        Args:
            room_name: Name of the Jitsi room
            
        Returns:
            Dictionary with room configuration
        """
        return {
            "room_name": room_name,
            "url": self.server_url,
        }
    
    def validate_room_name(self, room_name: str) -> bool:
        """
        Validate that room name is Jitsi-compatible
        Jitsi room names should be lowercase, alphanumeric, with hyphens allowed
        
        Args:
            room_name: Room name to validate
            
        Returns:
            True if valid, False otherwise
        """
        import re
        # Allow lowercase letters, numbers, and hyphens
        pattern = r'^[a-z0-9-]+$'
        return bool(re.match(pattern, room_name))
    
    def sanitize_room_name(self, room_name: str) -> str:
        """
        Sanitize room name to be Jitsi-compatible
        
        Args:
            room_name: Room name to sanitize
            
        Returns:
            Sanitized room name
        """
        import re
        # Convert to lowercase, replace spaces/special chars with hyphens
        sanitized = re.sub(r'[^a-z0-9-]', '-', room_name.lower())
        # Remove consecutive hyphens
        sanitized = re.sub(r'-+', '-', sanitized)
        # Remove leading/trailing hyphens
        sanitized = sanitized.strip('-')
        return sanitized or 'room'

