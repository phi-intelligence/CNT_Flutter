from pydantic_settings import BaseSettings
from typing import Optional


class Settings(BaseSettings):
    # Database - Using SQLite for development (no credentials needed)
    DATABASE_URL: str = "sqlite+aiosqlite:///./cnt_db.sqlite"
    
    # Jitsi Meet
    JITSI_APP_ID: str = "my-app-id"
    JITSI_APP_SECRET: str = "043aee60310956355bf636e0e1a84318f76b52d7d61b06650f08713ea835598c"
    JITSI_SERVER_URL: str = "http://localhost:8000"
    JITSI_JWT_EXPIRATION: int = 7200  # 2 hours in seconds
    
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

