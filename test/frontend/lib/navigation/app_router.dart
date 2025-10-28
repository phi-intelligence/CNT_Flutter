import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/platform_helper.dart';
import '../providers/app_state.dart';
import '../providers/podcast_provider.dart';
import '../providers/music_provider.dart';
import '../providers/community_provider.dart';
import '../providers/audio_player_provider.dart';
import '../services/websocket_service.dart';
import '../theme/app_theme.dart';
import 'mobile_navigation.dart';
import 'web_navigation.dart';

class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize WebSocket connection
    WebSocketService().connect();
    
    // Choose navigation based on platform
    if (PlatformHelper.isWebPlatform()) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppState()),
          ChangeNotifierProvider(create: (_) => PodcastProvider()),
          ChangeNotifierProvider(create: (_) => MusicProvider()),
          ChangeNotifierProvider(create: (_) => CommunityProvider()),
          ChangeNotifierProvider(create: (_) => AudioPlayerState()),
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

