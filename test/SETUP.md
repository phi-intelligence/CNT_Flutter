# CNT Media Platform - Setup Guide

This guide will help you get the CNT Media Platform up and running on your local machine.

## Prerequisites

### Backend Requirements
- Python 3.10+
- PostgreSQL 14+
- FFmpeg (for media processing)
- Virtual environment (venv)

### Frontend Requirements
- Flutter 3.0+
- Dart 3.0+
- Android Studio / Xcode (for mobile development)
- Chrome (for web development)

## Backend Setup

### 1. Install PostgreSQL

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install postgresql postgresql-contrib
sudo systemctl start postgresql
```

**macOS:**
```bash
brew install postgresql
brew services start postgresql
```

**Windows:**
Download and install from https://www.postgresql.org/download/windows/

### 2. Create Database

```bash
# Connect to PostgreSQL
sudo -u postgres psql

# Create database and user
CREATE DATABASE cnt_db;
CREATE USER cnt_user WITH PASSWORD 'your_password';
GRANT ALL PRIVILEGES ON DATABASE cnt_db TO cnt_user;

# Exit psql
\q
```

### 3. Install FFmpeg

**Ubuntu/Debian:**
```bash
sudo apt install ffmpeg
```

**macOS:**
```bash
brew install ffmpeg
```

**Windows:**
Download from https://ffmpeg.org/download.html

### 4. Setup Python Environment

```bash
# Navigate to backend directory
cd backend

# Create virtual environment
python -m venv venv

# Activate virtual environment
# On Linux/macOS:
source venv/bin/activate
# On Windows:
venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt
```

### 5. Configure Environment

Create a `.env` file in the `backend/` directory:

```bash
cp env.example .env
```

Edit `.env` with your settings:

```env
DATABASE_URL=postgresql+psycopg2://cnt_user:your_password@localhost:5432/cnt_db

LIVEKIT_API_KEY=your_livekit_key
LIVEKIT_API_SECRET=your_livekit_secret
LIVEKIT_URL=ws://localhost:7880

OPENAI_API_KEY=your_openai_key
DEEPGRAM_API_KEY=your_deepgram_key

MEDIA_STORAGE_PATH=./media

SECRET_KEY=your_secret_key_change_this
```

### 6. Run Database Migrations

```bash
# Create migration
alembic revision --autogenerate -m "Initial migration"

# Apply migration
alembic upgrade head
```

### 7. Start Backend Server

```bash
uvicorn app.main:app --reload
```

Backend will be available at http://localhost:8000
API Documentation at http://localhost:8000/docs

## Frontend Setup

### 1. Install Flutter

**Ubuntu/Debian:**
```bash
# Install dependencies
sudo apt-get update
sudo apt-get install -y git curl unzip libfuse-dev libc6-dev-i386

# Clone Flutter
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

# Run Flutter doctor
flutter doctor
```

**macOS:**
```bash
# Install via Homebrew
brew install --cask flutter
```

**Windows:**
Download from https://flutter.dev/docs/get-started/install/windows

### 2. Verify Flutter Installation

```bash
flutter doctor
```

Install any missing dependencies as prompted.

### 3. Setup Flutter Project

```bash
# Navigate to frontend directory
cd frontend

# Get dependencies
flutter pub get

# Check for connected devices
flutter devices
```

### 4. Run Flutter App

**Web (Chrome):**
```bash
flutter run -d chrome
```

**Mobile:**
```bash
# For Android (requires connected device or emulator)
flutter run

# For iOS (requires macOS and Xcode)
flutter run -d ios
```

## Project Structure

```
cnt-media-platform/
├── backend/
│   ├── app/
│   │   ├── models/          # Database models
│   │   ├── routes/          # API endpoints
│   │   ├── services/        # Business logic
│   │   ├── schemas/         # Pydantic schemas
│   │   └── main.py          # FastAPI app
│   ├── migrations/          # Alembic migrations
│   ├── media/               # Uploaded media files
│   ├── requirements.txt
│   └── README.md
│
├── frontend/
│   ├── lib/
│   │   ├── screens/         # Page screens
│   │   ├── widgets/         # UI components
│   │   ├── providers/       # State management
│   │   └── theme/           # Theme config
│   ├── pubspec.yaml
│   └── README.md
│
└── README.md
```

## Running the Application

### Terminal 1 - Backend
```bash
cd backend
source venv/bin/activate  # Activate venv
uvicorn app.main:app --reload
```

### Terminal 2 - Frontend
```bash
cd frontend
flutter run -d chrome  # or flutter run for mobile
```

## Development Workflow

1. **Backend Changes**: FastAPI auto-reloads on file changes
2. **Frontend Changes**: Hot reload is enabled by default
3. **Database Changes**: Create migration with `alembic revision --autogenerate`
4. **Add Dependencies**:
   - Backend: `pip install package_name` then add to requirements.txt
   - Frontend: `flutter pub add package_name`

## Troubleshooting

### Backend Issues

**Database Connection Error:**
- Ensure PostgreSQL is running
- Check DATABASE_URL in .env file
- Verify database exists: `psql -l`

**Import Errors:**
- Activate venv: `source venv/bin/activate`
- Reinstall dependencies: `pip install -r requirements.txt`

**FFmpeg Not Found:**
- Install FFmpeg: `sudo apt install ffmpeg` or `brew install ffmpeg`
- Add to PATH if needed

### Frontend Issues

**Package Errors:**
- Clean pub cache: `flutter pub cache repair`
- Get dependencies: `flutter pub get`
- Delete `pubspec.lock` and run `flutter pub get`

**Build Errors:**
- Clean build: `flutter clean`
- Get dependencies: `flutter pub get`
- Rebuild: `flutter run`

## Next Steps

1. Create sample data in the database
2. Test API endpoints using http://localhost:8000/docs
3. Implement authentication
4. Add media upload functionality
5. Connect frontend to backend API
6. Implement real-time features

## Support

For issues or questions, please refer to the main README.md file.

