import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/platform_helper.dart';
import '../providers/app_state.dart';
import '../providers/podcast_provider.dart';
import '../providers/music_provider.dart';
import '../providers/community_provider.dart';
import '../providers/audio_player_provider.dart';
import '../providers/search_provider.dart';
import '../providers/user_provider.dart';
import '../providers/playlist_provider.dart';
import '../providers/favorites_provider.dart';
import '../services/websocket_service.dart';
import '../theme/app_theme.dart';
import 'mobile_navigation.dart';
import 'web_navigation.dart';

class AppRouter extends StatefulWidget {
  const AppRouter({super.key});

  @override
  State<AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<AppRouter> {
  @override
  void initState() {
    super.initState();
    print('✅ AppRouter initState');
    // Initialize WebSocket connection asynchronously after first frame
    // This prevents blocking the build method and handles errors gracefully
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _initializeWebSocket();
    });
  }

  void _initializeWebSocket() async {
    try {
      print('✅ AppRouter: Initializing WebSocket...');
      await WebSocketService().connect();
      print('✅ AppRouter: WebSocket connected');
    } catch (e, stackTrace) {
      // Log error but don't crash the app
      // WebSocket connection is non-critical for app functionality
      print('❌ AppRouter: WebSocket connection failed (non-critical): $e');
      print('Stack trace: $stackTrace');
    }
  }

  @override
  Widget build(BuildContext context) {
    print('✅ AppRouter: Building navigation...');
    // Choose navigation based on platform
    if (PlatformHelper.isWebPlatform()) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppState()),
          ChangeNotifierProvider(create: (_) => PodcastProvider()),
          ChangeNotifierProvider(create: (_) => MusicProvider()),
          ChangeNotifierProvider(create: (_) => CommunityProvider()),
          ChangeNotifierProvider(create: (_) => AudioPlayerState()),
          ChangeNotifierProvider(create: (_) => SearchProvider()),
          ChangeNotifierProvider(create: (_) => UserProvider()),
          ChangeNotifierProvider(create: (_) => PlaylistProvider()),
          ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ],
        child: MaterialApp(
          title: 'CNT Media Platform',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          home: const WebNavigationLayout(),
        ),
      );
    } else {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppState()),
          ChangeNotifierProvider(create: (_) => PodcastProvider()),
          ChangeNotifierProvider(create: (_) => MusicProvider()),
          ChangeNotifierProvider(create: (_) => CommunityProvider()),
          ChangeNotifierProvider(create: (_) => AudioPlayerState()),
          ChangeNotifierProvider(create: (_) => SearchProvider()),
          ChangeNotifierProvider(create: (_) => UserProvider()),
          ChangeNotifierProvider(create: (_) => PlaylistProvider()),
          ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ],
        child: MaterialApp(
          title: 'CNT Media Platform',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          home: const MobileNavigationLayout(),
        ),
      );
    }
  }
}

