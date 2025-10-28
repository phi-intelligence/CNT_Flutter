import 'package:flutter/material.dart';
import '../screens/web/home_screen_web.dart';
import '../screens/web/discover_screen_web.dart';
import '../screens/web/bible_stories_screen_web.dart';
import '../screens/podcasts_screen.dart';
import '../screens/music_screen.dart';
import '../screens/live_streaming_screen.dart';
import '../screens/web/favorites_screen_web.dart';
import '../screens/web/create_screen_web.dart';
import '../screens/web/stream_screen_web.dart';
import '../screens/web/downloads_screen_web.dart';
import '../screens/library_screen.dart';
import '../screens/web/notifications_screen_web.dart';
import '../screens/community_screen.dart';
import '../screens/web/prayer_screen_web.dart';
import '../screens/web/voice_chat_screen_web.dart';
import '../screens/profile_screen.dart';
import '../screens/admin_dashboard.dart';
import '../screens/web/about_screen_web.dart';
import '../screens/web/meetings_screen_web.dart';
import '../widgets/media/global_audio_player.dart';

class WebNavigationLayout extends StatefulWidget {
  const WebNavigationLayout({super.key});

  @override
  State<WebNavigationLayout> createState() => _WebNavigationLayoutState();
}

class _WebNavigationLayoutState extends State<WebNavigationLayout> {
  int _selectedIndex = 0;

  final List<NavigationItem> _navigationItems = [
    NavigationItem(icon: Icons.home, label: 'Home', route: 'home'),
    NavigationItem(icon: Icons.calendar_today, label: 'Meetings', route: 'meetings'),
    NavigationItem(icon: Icons.explore, label: 'Discover', route: 'discover'),
    NavigationItem(icon: Icons.book, label: 'Bible Stories', route: 'bible-stories'),
    NavigationItem(icon: Icons.mic, label: 'Podcasts', route: 'podcasts'),
    NavigationItem(icon: Icons.music_note, label: 'Music', route: 'music'),
    NavigationItem(icon: Icons.radio, label: 'Live', route: 'live'),
    NavigationItem(icon: Icons.star, label: 'Favorites', route: 'favorites'),
    NavigationItem(icon: Icons.video_library, label: 'Create', route: 'create'),
    NavigationItem(icon: Icons.broadcast_on_personal, label: 'Stream', route: 'stream'),
    NavigationItem(icon: Icons.download, label: 'Downloads', route: 'download-manager'),
    NavigationItem(icon: Icons.folder, label: 'Library', route: 'library'),
    NavigationItem(icon: Icons.notifications, label: 'Notifications', route: 'notifications'),
    NavigationItem(icon: Icons.people, label: 'Community', route: 'community'),
    NavigationItem(icon: Icons.favorite, label: 'Prayer', route: 'prayer'),
    NavigationItem(icon: Icons.chat, label: 'Voice Chat', route: 'voice-chat'),
    NavigationItem(icon: Icons.person, label: 'My Profile', route: 'profile'),
    NavigationItem(icon: Icons.admin_panel_settings, label: 'Admin Dashboard', route: 'admin'),
    NavigationItem(icon: Icons.info, label: 'About', route: 'about'),
  ];

  void _navigateToScreen(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildCurrentScreen() {
    switch (_selectedIndex) {
      case 0:
        return const HomeScreenWeb();
      case 1:
        return const MeetingsScreenWeb();
      case 2:
        return const DiscoverScreenWeb();
      case 3:
        return const BibleStoriesScreenWeb();
      case 4:
        return const PodcastsScreen();
      case 5:
        return const MusicScreen();
      case 6:
        return const LiveStreamingScreen();
      case 7:
        return const FavoritesScreenWeb();
      case 8:
        return const CreateScreenWeb();
      case 9:
        return const StreamScreenWeb();
      case 10:
        return const DownloadsScreenWeb();
      case 11:
        return const LibraryScreen();
      case 12:
        return const NotificationsScreenWeb();
      case 13:
        return const CommunityScreen();
      case 14:
        return const PrayerScreenWeb();
      case 15:
        return const VoiceChatScreenWeb();
      case 16:
        return const ProfileScreen();
      case 17:
        return const AdminDashboardScreen();
      case 18:
        return const AboutScreenWeb();
      default:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'Page: ${_navigationItems[_selectedIndex].label}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Coming soon...',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Row(
            children: [
              // Sidebar Navigation
              Container(
                width: 280,
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Column(
                  children: [
                    // App Logo/Title
                    Container(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Icon(Icons.church, size: 32, color: Theme.of(context).primaryColor),
                          const SizedBox(width: 12),
                          Text(
                            'CNT Media',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    // Navigation Items
                    Expanded(
                      child: ListView.builder(
                        itemCount: _navigationItems.length,
                        itemBuilder: (context, index) {
                          final item = _navigationItems[index];
                          final isSelected = _selectedIndex == index;
                          
                          return InkWell(
                            onTap: () => _navigateToScreen(index),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.transparent,
                              child: Row(
                                children: [
                                  Icon(
                                    item.icon,
                                    size: 24,
                                    color: isSelected ? Theme.of(context).primaryColor : Colors.grey[600],
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    item.label,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                      color: isSelected ? Theme.of(context).primaryColor : Colors.grey[800],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              // Main Content Area
              Expanded(
                child: _buildCurrentScreen(),
              ),
            ],
          ),
          // Global Audio Player at bottom
          const GlobalAudioPlayer(),
        ],
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final String label;
  final String route;

  NavigationItem({
    required this.icon,
    required this.label,
    required this.route,
  });
}

