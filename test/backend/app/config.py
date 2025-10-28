from pydantic_settings import BaseSettings
from typing import Optional


class Settings(BaseSettings):
    # Database - Using SQLite for development (no credentials needed)
    DATABASE_URL: str = "sqlite+aiosqlite:///./cnt_db.sqlite"
    
    # LiveKit
    LIVEKIT_API_KEY: str = ""
    LIVEKIT_API_SECRET: str = ""
    LIVEKIT_URL: str = "ws://localhost:7880"
    
    # OpenAI
    OPENAI_API_KEY: str = ""
    
    # Deepgram
    DEEPGRAM_API_KEY: str = ""
    
    # Media Storage
    MEDIA_STORAGE_PATH: str = "./media"
    
    # Security
    SECRET_KEY: str = "your-secret-key-change-in-production"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    
    # API Settings
    API_V1_PREFIX: str = "/api/v1"
    
    class Config:
        env_file = ".env"
        case_sensitive = True


settings = Settings()

