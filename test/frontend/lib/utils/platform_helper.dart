import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

/// Platform detection utilities
class PlatformHelper {
  /// Check if running on web platform
  static bool isWebPlatform() {
    return kIsWeb;
  }
  
  /// Check if running on mobile platform (iOS or Android)
  static bool isMobilePlatform() {
    return !kIsWeb && (Platform.isAndroid || Platform.isIOS);
  }
  
  /// Check if running on iOS
  static bool isIOS() {
    return !kIsWeb && Platform.isIOS;
  }
  
  /// Check if running on Android
  static bool isAndroid() {
    return !kIsWeb && Platform.isAndroid;
  }
  
  /// Get screen type based on width
  static ScreenType getScreenType(double width) {
    if (width < 600) {
      return ScreenType.mobile;
    } else if (width < 1024) {
      return ScreenType.tablet;
    } else {
      return ScreenType.desktop;
    }
  }
  
  /// Get base URL for API calls based on platform
  static String getApiBaseUrl() {
    if (kIsWeb) {
      return 'http://localhost:8000/api/v1';
    } else {
      // Android emulator uses 10.0.2.2 to access host machine's localhost
      return 'http://10.0.2.2:8000/api/v1';
    }
  }
  
  /// Get WebSocket URL for real-time features
  static String getWebSocketUrl() {
    if (kIsWeb) {
      return 'ws://localhost:8000';
    } else {
      return 'ws://10.0.2.2:8000';
    }
  }
}

/// Screen type enum
enum ScreenType {
  mobile,
  tablet,
  desktop,
}

