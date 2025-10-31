# Deploy Flutter App to Android Phone - Complete Guide

## Prerequisites
- Android phone with USB cable
- Phone and computer on the same WiFi network
- USB debugging enabled on phone
- Backend server running on your computer

## Step-by-Step Instructions

### 1. Enable USB Debugging on Your Android Phone

1. Open **Settings** on your phone
2. Go to **About phone** (or **About device**)
3. Tap **Build number** 7 times to enable **Developer options**
4. Go back to **Settings** → **Developer options**
5. Enable **USB debugging**
6. (Optional) Enable **Install via USB** if available

### 2. Connect Phone via USB

1. Connect your phone to computer via USB cable
2. On your phone, when prompted, **Allow USB debugging** and check **Always allow from this computer**
3. Verify connection:
   ```bash
   adb devices
   ```
   You should see your device listed (e.g., `ABC123XYZ    device`)

### 3. Get Your Computer's IP Address

Your computer's IP address: **192.168.0.14**

To verify it's correct:
```bash
hostname -I
```
or
```bash
ip addr show | grep "inet " | grep -v 127.0.0.1
```

### 4. Ensure Phone and Computer Are on Same WiFi Network

- Both devices must be connected to the same WiFi network
- Check your phone's WiFi connection matches your computer's network

### 5. Update Flutter App Configuration

The app needs to use your computer's IP address instead of `10.0.2.2`.

**Option A: Build with IP address (Recommended)**
```bash
cd frontend
flutter run --dart-define=API_BASE=http://192.168.0.14:8002/api/v1 --dart-define=MEDIA_BASE=http://192.168.0.14:8002 --dart-define=JITSI_SERVER=http://192.168.0.14:8000
```

**Option B: Build APK with IP address**
```bash
cd frontend
flutter build apk --dart-define=API_BASE=http://192.168.0.14:8002/api/v1 --dart-define=MEDIA_BASE=http://192.168.0.14:8002 --dart-define=JITSI_SERVER=http://192.168.0.14:8000
```

### 6. Verify Backend Server is Running

```bash
cd backend
source venv/bin/activate
# Backend should be running on port 8002
# Check: http://localhost:8002/health
```

### 7. Test Backend from Phone's Network

From another device on the same network (or your phone's browser):
- Open: `http://192.168.0.14:8002/health`
- Should return: `{"status":"healthy"}`

If this doesn't work, check your firewall settings.

### 8. Build and Run on Phone

**Method 1: Direct Run (Recommended for Development)**
```bash
cd frontend
flutter devices  # Should show your phone
flutter run -d <device-id> --dart-define=API_BASE=http://192.168.0.14:8002/api/v1 --dart-define=MEDIA_BASE=http://192.168.0.14:8002 --dart-define=JITSI_SERVER=http://192.168.0.14:8000
```

**Method 2: Build APK and Install**
```bash
cd frontend
flutter build apk --release --dart-define=API_BASE=http://192.168.0.14:8002/api/v1 --dart-define=MEDIA_BASE=http://192.168.0.14:8002 --dart-define=JITSI_SERVER=http://192.168.0.14:8000
# APK will be at: build/app/outputs/flutter-apk/app-release.apk
# Install: adb install build/app/outputs/flutter-apk/app-release.apk
```

### 9. Troubleshooting

**Phone can't connect to backend:**
- Verify phone and computer are on same WiFi
- Check firewall allows connections on port 8002
- Test: Open `http://192.168.0.14:8002/health` in phone's browser
- If firewall blocks, allow connections:
  ```bash
  sudo ufw allow 8002/tcp
  ```

**ADB device not showing:**
- Try different USB cable
- Enable "PTP" mode instead of "MTP" on phone
- Restart ADB: `adb kill-server && adb start-server`
- Check USB drivers are installed

**App crashes or can't fetch data:**
- Verify backend is running: `curl http://localhost:8002/health`
- Check logs: `flutter logs` or `adb logcat | grep flutter`
- Verify IP address hasn't changed

**IP address changed:**
- Your computer's IP may change if you reconnect to WiFi
- Re-run: `hostname -I` to get new IP
- Rebuild app with new IP address

## Quick Commands Reference

```bash
# Check connected devices
adb devices

# Check computer IP
hostname -I

# Check backend health
curl http://localhost:8002/health

# Test from phone's network
curl http://192.168.0.14:8002/health

# Run app on connected device
cd frontend
flutter run --dart-define=API_BASE=http://192.168.0.14:8002/api/v1

# Build APK
cd frontend
flutter build apk --release --dart-define=API_BASE=http://192.168.0.14:8002/api/v1
```

## Next Steps After Deployment

1. Test all features: podcasts, videos, meetings, etc.
2. Monitor backend logs for any connection issues
3. If IP changes frequently, consider setting a static IP on your router
4. For production, use a domain name or static IP address

