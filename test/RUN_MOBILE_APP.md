# How to Run the Mobile Application

## Prerequisites

1. **Flutter SDK** installed (version 3.0 or higher)
   - Check installation: `flutter doctor`
   - Install: https://flutter.dev/docs/get-started/install

2. **Android Studio** (for Android) or **Xcode** (for iOS)
   - Android Studio: https://developer.android.com/studio
   - Xcode: Available from Mac App Store

3. **Backend Server Running** (required)
   - The mobile app needs the backend API to be running
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

**Important:** The backend must be running before starting the mobile app!

### 2. Configure API URL for Your Device

The mobile app needs to know where your backend is running. The default configuration depends on your platform:

#### For Android Emulator:
- **Default:** `http://10.0.2.2:8002/api/v1` (already configured)
- No changes needed if using Android emulator

#### For iOS Simulator:
- **Default:** Uses `localhost` (should work automatically)
- If not working, you may need to configure

#### For Physical Device (Phone/Tablet):
You need to use your computer's IP address instead of localhost:

1. **Find your computer's IP address:**
   ```bash
   # Linux/Mac
   ip addr show | grep "inet " | grep -v 127.0.0.1
   # OR
   ifconfig | grep "inet " | grep -v 127.0.0.1
   
   # Windows
   ipconfig
   # Look for IPv4 Address (e.g., 192.168.1.100)
   ```

2. **Run Flutter with custom API URL:**
   ```bash
   flutter run --dart-define=API_BASE=http://YOUR_IP:8002/api/v1 --dart-define=MEDIA_BASE=http://YOUR_IP:8002
   ```
   
   Example:
   ```bash
   flutter run --dart-define=API_BASE=http://192.168.1.100:8002/api/v1 --dart-define=MEDIA_BASE=http://192.168.1.100:8002
   ```

3. **Make sure your phone and computer are on the same WiFi network**

### 3. Run the Mobile App

#### Option A: Let Flutter Auto-Detect Device
```bash
cd frontend
flutter run
```

#### Option B: Specify Device Explicitly

**List available devices:**
```bash
flutter devices
```

**Run on specific device:**
```bash
# Android
flutter run -d android

# iOS
flutter run -d ios

# Specific device by ID
flutter run -d <device-id>
```

### 4. Common Commands

```bash
# Get dependencies (if you haven't already)
cd frontend
flutter pub get

# Check for connected devices
flutter devices

# Run in debug mode (default)
flutter run

# Run in release mode (optimized)
flutter run --release

# Hot reload (press 'r' in terminal while app is running)
# Hot restart (press 'R' in terminal)
# Quit (press 'q' in terminal)
```

## Troubleshooting

### Issue: "No devices found"
**Solution:**
- Make sure you have an emulator running or a physical device connected
- For Android: Start an emulator from Android Studio
- For iOS: Start a simulator from Xcode
- For physical device: Enable USB debugging and connect via USB

### Issue: "Cannot connect to backend"
**Solutions:**
1. **Check backend is running:**
   ```bash
   curl http://localhost:8002/health
   # Should return: {"status":"healthy"}
   ```

2. **For physical device, use your computer's IP:**
   - Make sure both devices are on same WiFi
   - Use the IP address command from Step 2 above
   - Run with `--dart-define` flags

3. **Check firewall settings:**
   - Make sure port 8002 is not blocked
   - On Linux: `sudo ufw allow 8002`

### Issue: "Build failed" or "Gradle error"
**Solutions:**
```bash
# Clean build
cd frontend
flutter clean
flutter pub get
flutter run
```

### Issue: "Permission denied" (Android)
**Solution:**
- The app requests permissions at runtime
- Make sure to grant permissions when prompted
- Check app settings if permissions were denied

## Quick Start (All-in-One)

```bash
# Terminal 1: Start Backend
cd backend
source venv/bin/activate
uvicorn app.main:app --reload --port 8002

# Terminal 2: Run Mobile App
cd frontend
flutter pub get
flutter run
```

## Development Tips

1. **Hot Reload**: Press `r` in the terminal to hot reload changes
2. **Hot Restart**: Press `R` to hot restart (full app restart)
3. **Open DevTools**: Press `d` to open Flutter DevTools
4. **Quit**: Press `q` to quit the app

## Testing on Different Platforms

### Android Emulator
- Default API URL works automatically (`10.0.2.2`)
- No additional configuration needed

### iOS Simulator
- Should work with default settings
- If issues occur, check network permissions

### Physical Android Device
- Use your computer's IP address
- Ensure same WiFi network
- Enable USB debugging

### Physical iOS Device
- Use your computer's IP address
- Ensure same WiFi network
- May need to configure network settings

## Next Steps

Once the app is running:
1. Navigate through the different screens
2. Test audio/video playback
3. Try creating content
4. Test community features
5. Check live streaming functionality

For backend API documentation, visit: `http://localhost:8002/docs`

