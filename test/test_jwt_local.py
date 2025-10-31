#!/usr/bin/env python3
"""
JWT Token Generator for Jitsi Meet Local Testing
This script generates JWT tokens for testing Jitsi Meet authentication
"""

import jwt
import time
import sys

# Configuration - Update these to match your .env file
APP_ID = "my-app-id"
APP_SECRET = "043aee60310956355bf636e0e1a84318f76b52d7d61b06650f08713ea835598c"  # From jitsi-meet-local/.env
SERVER_DOMAIN = "meet.jitsi"  # Your XMPP_DOMAIN from .env
SERVER_URL = "http://localhost:8000"  # Your PUBLIC_URL

def generate_jwt_token(
    room_name="test-room",
    user_name="Test User",
    user_email=None,
    is_moderator=True,
    audio_enabled=True,
    video_enabled=True,
    expiration_hours=2
):
    """
    Generate a JWT token for Jitsi Meet
    
    Args:
        room_name: Name of the Jitsi room
        user_name: Display name of the user
        user_email: Email of the user (optional)
        is_moderator: Whether user is a moderator
        audio_enabled: Whether audio is enabled
        video_enabled: Whether video is enabled
        expiration_hours: Token expiration in hours
    
    Returns:
        JWT token string
    """
    # Calculate expiration time
    exp = int(time.time()) + (expiration_hours * 3600)
    
    # Build JWT payload
    payload = {
        "iss": APP_ID,
        "aud": APP_ID,
        "sub": SERVER_DOMAIN,
        "room": room_name,
        "exp": exp,
        "moderator": is_moderator,
        "audio": audio_enabled,
        "video": video_enabled,
        "name": user_name,
    }
    
    # Add email if provided
    if user_email:
        payload["email"] = user_email
    
    # Generate JWT token
    try:
        token = jwt.encode(payload, APP_SECRET, algorithm="HS256")
        return token
    except Exception as e:
        print(f"❌ Error generating token: {e}")
        sys.exit(1)

def main():
    """Main function"""
    import argparse
    
    parser = argparse.ArgumentParser(description="Generate JWT token for Jitsi Meet")
    parser.add_argument("--room", "-r", default="test-room", help="Room name (default: test-room)")
    parser.add_argument("--name", "-n", default="Test User", help="User name (default: Test User)")
    parser.add_argument("--email", "-e", default=None, help="User email (optional)")
    parser.add_argument("--moderator", "-m", action="store_true", help="User is moderator")
    parser.add_argument("--no-audio", action="store_true", help="Disable audio")
    parser.add_argument("--no-video", action="store_true", help="Disable video")
    parser.add_argument("--exp", type=int, default=2, help="Expiration in hours (default: 2)")
    
    args = parser.parse_args()
    
    # Generate token
    token = generate_jwt_token(
        room_name=args.room,
        user_name=args.name,
        user_email=args.email,
        is_moderator=args.moderator,
        audio_enabled=not args.no_audio,
        video_enabled=not args.no_video,
        expiration_hours=args.exp
    )
    
    # Print results
    print("=" * 60)
    print("JWT Token Generated Successfully")
    print("=" * 60)
    print()
    print(f"Room Name: {args.room}")
    print(f"User Name: {args.name}")
    print(f"Moderator: {args.moderator}")
    print(f"Audio: {not args.no_audio}")
    print(f"Video: {not args.no_video}")
    print(f"Expiration: {args.exp} hours")
    print()
    print("Token:")
    print(token)
    print()
    print("Test URLs:")
    print(f"  Browser: {SERVER_URL}/{args.room}?jwt={token}")
    print()
    print("=" * 60)

if __name__ == "__main__":
    # Check if PyJWT is installed
    try:
        import jwt
    except ImportError:
        print("❌ PyJWT is not installed")
        print("Install it with: pip install PyJWT")
        sys.exit(1)
    
    # Run main
    main()

