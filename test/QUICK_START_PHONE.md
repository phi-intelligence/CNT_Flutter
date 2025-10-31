# Quick Start: Run App on Android Phone

## Your Computer's IP: **192.168.0.14**

## Quick Steps:

### 1. Enable USB Debugging on Phone
- Settings → About phone → Tap "Build number" 7 times
- Settings → Developer options → Enable "USB debugging"

### 2. Connect Phone
```bash
# Connect phone via USB, then:
adb devices  # Should show your phone
```

### 3. Run App on Phone
```bash
cd frontend
flutter run --dart-define=API_BASE=http://192.168.0.14:8002/api/v1 --dart-define=MEDIA_BASE=http://192.168.0.14:8002 --dart-define=JITSI_SERVER=http://192.168.0.14:8000
```

### 4. Build APK for Installation
```bash
cd frontend
flutter build apk --release --dart-define=API_BASE=http://192.168.0.14:8002/api/v1 --dart-define=MEDIA_BASE=http://192.168.0.14:8002 --dart-define=JITSI_SERVER=http://192.168.0.14:8000
adb install build/app/outputs/flutter-apk/app-release.apk
```

## Important Notes:
- Phone and computer MUST be on same WiFi network
- Backend must be running on port 8002
- If IP changes, update the commands with new IP

## Troubleshooting:
- Can't connect? Check firewall: `sudo ufw allow 8002/tcp`
- Test backend: Open `http://192.168.0.14:8002/health` in phone's browser
- ADB issues? Try: `adb kill-server && adb start-server`
