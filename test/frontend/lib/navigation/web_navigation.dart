import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../screens/web/home_screen_web.dart';
import '../screens/web/discover_screen_web.dart';
import '../screens/web/bible_stories_screen_web.dart';
import '../screens/web/podcasts_screen_web.dart';
import '../screens/web/music_screen_web.dart';
import '../screens/web/favorites_screen_web.dart';
import '../screens/web/create_screen_web.dart';
import '../screens/web/downloads_screen_web.dart';
import '../screens/web/notifications_screen_web.dart';
import '../screens/web/community_screen_web.dart';
import '../screens/web/prayer_screen_web.dart';
import '../screens/web/profile_screen_web.dart';
import '../screens/admin_dashboard.dart';
import '../screens/web/about_screen_web.dart';
import '../screens/web/meetings_screen_web.dart';
import '../screens/web/search_screen_web.dart';
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
    NavigationItem(icon: Icons.search, label: 'Search', route: 'search'),
    NavigationItem(icon: Icons.video_library, label: 'Create', route: 'create'),
    NavigationItem(icon: Icons.people, label: 'Community', route: 'community'),
    NavigationItem(icon: Icons.person, label: 'My Profile', route: 'profile'),
    NavigationItem(icon: Icons.calendar_today, label: 'Meetings', route: 'meetings'),
    NavigationItem(icon: Icons.explore, label: 'Discover', route: 'discover'),
    NavigationItem(icon: Icons.book, label: 'Bible Stories', route: 'bible-stories'),
    NavigationItem(icon: Icons.mic, label: 'Podcasts', route: 'podcasts'),
    NavigationItem(icon: Icons.music_note, label: 'Music', route: 'music'),
    NavigationItem(icon: Icons.star, label: 'Favorites', route: 'favorites'),
    NavigationItem(icon: Icons.download, label: 'Downloads', route: 'download-manager'),
    NavigationItem(icon: Icons.notifications, label: 'Notifications', route: 'notifications'),
    NavigationItem(icon: Icons.favorite, label: 'Prayer', route: 'prayer'),
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
        return const SearchScreenWeb();
      case 2:
        return const CreateScreenWeb();
      case 3:
        return const CommunityScreenWeb();
      case 4:
        return const ProfileScreenWeb();
      case 5:
        return const MeetingsScreenWeb();
      case 6:
        return const DiscoverScreenWeb();
      case 7:
        return const BibleStoriesScreenWeb();
      case 8:
        return const PodcastsScreenWeb();
      case 9:
        return const MusicScreenWeb();
      case 10:
        return const FavoritesScreenWeb();
      case 11:
        return const DownloadsScreenWeb();
      case 12:
        return const NotificationsScreenWeb();
      case 13:
        return const PrayerScreenWeb();
      case 14:
        return const AdminDashboardScreen();
      case 15:
        return const AboutScreenWeb();
      default:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline, size: 48, color: AppColors.textSecondary),
              const SizedBox(height: 16),
              Text(
                'Page: ${_navigationItems[_selectedIndex].label}',
                style: AppTypography.heading3.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Coming soon...',
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
                ),
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
          Expanded(
            child: Row(
            children: [
              // Sidebar Navigation
              Container(
                width: 280,
                color: AppColors.backgroundPrimary,
                child: Column(
                  children: [
                    // App Logo/Title
                    Container(
                      padding: EdgeInsets.all(AppSpacing.large * 1.5),
                      child: Row(
                        children: [
                          Icon(
                            Icons.church,
                            size: 32,
                            color: AppColors.primaryMain,
                          ),
                          const SizedBox(width: AppSpacing.medium),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'CNT Media',
                                  style: AppTypography.heading3.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryMain,
                                  ),
                                ),
                                Text(
                                  'Christian Platform',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      height: 1,
                      color: AppColors.borderPrimary,
                      thickness: 1,
                    ),
                    // Navigation Items
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: AppSpacing.small),
                        itemCount: _navigationItems.length,
                        itemBuilder: (context, index) {
                          final item = _navigationItems[index];
                          final isSelected = _selectedIndex == index;
                          
                          return InkWell(
                            onTap: () => _navigateToScreen(index),
                            borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSpacing.medium,
                                vertical: AppSpacing.small,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primaryMain.withOpacity(0.1)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    item.icon,
                                    size: 24,
                                    color: isSelected
                                        ? AppColors.primaryMain
                                        : AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: AppSpacing.medium),
                                  Expanded(
                                    child: Text(
                                      item.label,
                                      style: AppTypography.body.copyWith(
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                        color: isSelected
                                            ? AppColors.primaryMain
                                            : AppColors.textPrimary,
                                      ),
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

