# Christ New Tabernacle Media Platform

A comprehensive Christian media platform with audio/video podcasts, music streaming, live streaming with WebRTC, AI voice assistant, and community features.

## Architecture

- **Backend**: FastAPI (Python) with PostgreSQL, LiveKit, OpenAI, Deepgram
- **Frontend**: Flutter (Dart) for web and mobile
- **Real-time**: Socket.io for live updates
- **Media**: FFmpeg for transcoding

## Project Structure

```
/
├── backend/          # FastAPI backend
│   ├── app/
│   │   ├── models/   # SQLAlchemy models
│   │   ├── routes/   # API endpoints
│   │   ├── services/ # Business logic
│   │   └── main.py   # FastAPI app
│   ├── migrations/    # Alembic migrations
│   └── requirements.txt
│
└── frontend/         # Flutter app
    ├── lib/
    │   ├── screens/  # Page screens
    │   ├── widgets/  # Reusable widgets
    │   ├── providers/# State management
    │   └── services/ # API services
    └── pubspec.yaml
```

## Getting Started

### Backend Setup

1. Navigate to backend directory:
```bash
cd backend
```

2. Create virtual environment:
```bash
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
```

3. Install dependencies:
```bash
pip install -r requirements.txt
```

4. Create `.env` file (copy from `env.example`)

5. Setup database:
```bash
createdb cnt_db
alembic revision --autogenerate -m "Initial migration"
alembic upgrade head
```

6. Start server:
```bash
uvicorn app.main:app --reload
```

Backend runs at http://localhost:8000

### Frontend Setup

1. Navigate to frontend directory:
```bash
cd frontend
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run -d chrome  # Web
# or
flutter run             # Mobile
```

## Features

- 🎙️ Audio/Video Podcasts
- 🎵 Music Streaming
- 📹 Live Streaming (WebRTC/LiveKit)
- 🤖 AI Voice Assistant
- 👥 Community Posts
- 📖 Bible Stories
- 📑 Playlists
- 📱 Mobile & Web Support

## Tech Stack

**Backend:**
- FastAPI
- PostgreSQL
- LiveKit
- OpenAI (GPT + TTS)
- Deepgram (STT)
- Socket.io
- FFmpeg

**Frontend:**
- Flutter
- Provider/Riverpod
- Audio/Video Players
- LiveKit SDK

## License

Private - Christ New Tabernacle

