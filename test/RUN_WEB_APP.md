# How to Run the Web Application

## Prerequisites

1. **Flutter SDK** installed (version 3.0 or higher)
   - Check: `flutter doctor`
   - Install: https://flutter.dev/docs/get-started/install

2. **Chrome Browser** (recommended for development)
   - Or any modern browser (Chrome, Edge, Firefox)

3. **Backend Server Running** (required)
   - The web app needs the backend API to be running
   - See backend setup below

## Step-by-Step Instructions

### 1. Start the Backend Server

**First, start the backend API:**

```bash
# Navigate to backend directory
cd backend

# Activate virtual environment (if not already activated)
source venv/bin/activate  # Linux/Mac
# OR
venv\Scripts\activate     # Windows

# Start the backend server
uvicorn app.main:app --reload --port 8002
```

The backend should now be running at `http://localhost:8002`

**Important:** The backend must be running before starting the web app!

### 2. Enable Flutter Web Support

**Check if web support is enabled:**
```bash
flutter doctor
```

**If web is not enabled, enable it:**
```bash
flutter config --enable-web
```

### 3. Run the Web Application

**Navigate to frontend directory:**
```bash
cd frontend
```

**Get dependencies (first time only):**
```bash
flutter pub get
```

**Run the web app:**
```bash
flutter run -d chrome
```

Or specify a different browser:
```bash
flutter run -d edge      # Microsoft Edge
flutter run -d web-server  # Start a local server (access at http://localhost:port)
```

### 4. Access the Application

Once running, the app will automatically open in your browser at:
- **Default URL:** `http://localhost:port` (port shown in terminal)
- Usually: `http://localhost:port` (e.g., `http://localhost:12345`)

## Quick Start (All-in-One)

```bash
# Terminal 1: Start Backend
cd backend
source venv/bin/activate
uvicorn app.main:app --reload --port 8002

# Terminal 2: Run Web App
cd frontend
flutter pub get
flutter run -d chrome
```

## Development Commands

```bash
# Hot reload (press 'r' in terminal while app is running)
# Hot restart (press 'R' in terminal)
# Quit (press 'q' in terminal)

# Run in release mode (optimized)
flutter run -d chrome --release

# Build web app (production build)
flutter build web

# Run production build locally
cd build/web
python -m http.server 8000  # Python 3
# OR
python -m SimpleHTTPServer 8000  # Python 2
```

## Configuration

### API URL Configuration

The web app uses the backend API. By default, it connects to:
- **Development:** `http://localhost:8002/api/v1`

If your backend is on a different host/port, you can configure it:

**Option 1: Environment Variables (Recommended)**
```bash
flutter run -d chrome --dart-define=API_BASE=http://localhost:8002/api/v1 --dart-define=MEDIA_BASE=http://localhost:8002
```

**Option 2: Edit the API Service**
- File: `frontend/lib/services/api_service.dart`
- Change the default values in the `baseUrl` getter

## Troubleshooting

### Issue: "Web support not enabled"
**Solution:**
```bash
flutter config --enable-web
flutter doctor
```

### Issue: "Cannot connect to backend"
**Solutions:**
1. **Check backend is running:**
   ```bash
   curl http://localhost:8002/health
   # Should return: {"status":"healthy"}
   ```

2. **Check browser console:**
   - Open DevTools (F12)
   - Check Console tab for errors
   - Check Network tab for failed API calls

3. **CORS Issues:**
   - The backend should already have CORS configured
   - If you see CORS errors, check `backend/app/main.py` CORS settings

### Issue: "Build failed" or compilation errors
**Solutions:**
```bash
# Clean build
cd frontend
flutter clean
flutter pub get
flutter run -d chrome
```

### Issue: "Port already in use"
**Solution:**
```bash
# Kill the process using the port, or
flutter run -d chrome --web-port=8080  # Use different port
```

### Issue: "Chrome not found"
**Solution:**
```bash
# Use web-server instead
flutter run -d web-server

# Then open browser manually to the URL shown
```

## Production Build

**Build for production:**
```bash
cd frontend
flutter build web --release
```

**Output location:**
- `frontend/build/web/`

**Deploy:**
- Copy contents of `build/web/` to your web server
- Works with any static file hosting (Nginx, Apache, Firebase Hosting, Netlify, etc.)

## Features Available in Web App

✅ **Home Screen** - Browse podcasts, music, and featured content
✅ **Podcasts** - Search and filter audio podcasts
✅ **Music** - Browse and play music tracks
✅ **Community** - Instagram-like posts and interactions
✅ **Create** - Create video/audio podcasts and meetings
✅ **Library** - Access downloads, playlists, and favorites
✅ **Search** - Search across all content types
✅ **Live Streaming** - Join and create live streams
✅ **Audio Player** - Full-screen audio player optimized for web
✅ **Video Player** - Video playback support

## Development Tips

1. **Hot Reload**: Press `r` in terminal to hot reload changes
2. **Hot Restart**: Press `R` to hot restart (full app restart)
3. **Open DevTools**: Press `d` to open Flutter DevTools
4. **Browser DevTools**: Press `F12` to open browser DevTools
5. **Quit**: Press `q` to quit the app

## Browser Compatibility

- ✅ Chrome (recommended)
- ✅ Edge
- ✅ Firefox
- ✅ Safari (may have some limitations)

## API Documentation

While the web app is running, you can access:
- **Backend API Docs:** http://localhost:8002/docs
- **Backend Health Check:** http://localhost:8002/health

## Next Steps

Once the web app is running:
1. Navigate through the sidebar menu
2. Test audio/video playback
3. Try creating content
4. Test community features
5. Check live streaming functionality
6. Test search functionality

Enjoy your Christian Media Platform! 🙏

