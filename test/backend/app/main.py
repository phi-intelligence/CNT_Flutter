from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from socketio import ASGIApp, AsyncServer
from app.routes import api_router
from app.config import settings
from app.websocket.socket_io_handler import SocketIOHandler
import os

# Create FastAPI app
app = FastAPI(
    title="CNT Media Platform API",
    description="Backend API for Christ New Tabernacle media platform",
    version="1.0.0"
)

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify exact origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Mount static files for media
if os.path.exists(settings.MEDIA_STORAGE_PATH):
    app.mount("/media", StaticFiles(directory=settings.MEDIA_STORAGE_PATH), name="media")

# Include API routes
app.include_router(api_router, prefix=settings.API_V1_PREFIX)


@app.get("/")
async def root():
    return {"message": "CNT Media Platform API", "version": "1.0.0"}


@app.get("/health")
async def health_check():
    return {"status": "healthy"}

# Setup Socket.io
sio = AsyncServer(cors_allowed_origins="*", async_mode='asgi')
socketio_app = ASGIApp(sio, app)

# Setup Socket.io handlers
SocketIOHandler(sio)

# Wrap app with Socket.io
app = socketio_app

