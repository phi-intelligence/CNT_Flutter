import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../screens/mobile/home_screen_mobile.dart';
import '../screens/mobile/search_screen_mobile.dart';
import '../screens/mobile/create_screen_mobile.dart';
import '../screens/mobile/community_screen_mobile.dart';
import '../screens/mobile/profile_screen_mobile.dart';
import '../widgets/media/sliding_audio_player.dart';
import '../providers/audio_player_provider.dart';
import '../utils/platform_utils.dart';
import '../theme/app_colors.dart';

/// Mobile Navigation Layout - 5 tabs matching React Native exactly
/// Tabs: Home, Search, Plus/Create, Community, Profile
class MobileNavigationLayout extends StatefulWidget {
  const MobileNavigationLayout({super.key});

  @override
  State<MobileNavigationLayout> createState() => _MobileNavigationLayoutState();
}

class _MobileNavigationLayoutState extends State<MobileNavigationLayout> {
  int _currentIndex = 0;
  final GlobalKey<SlidingAudioPlayerState> _playerKey = GlobalKey<SlidingAudioPlayerState>();

  final List<Widget> _screens = [
    const HomeScreenMobile(),
    const SearchScreenMobile(),
    const CreateScreenMobile(),
    const CommunityScreenMobile(),
    const ProfileScreenMobile(),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    final tabBarHeight = PlatformUtils.isIOS
        ? (isSmallScreen ? 90 : 85)
        : 60;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (!didPop) {
          // Check if player is expanded
          final playerState = _playerKey.currentState;
          if (playerState != null && playerState.isExpanded) {
            // Minimize player instead of exiting
            playerState.minimizePlayer();
          } else {
            // Exit app when player is minimized or no track playing
            SystemNavigator.pop();
          }
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            _screens[_currentIndex],
            // Sliding audio player overlay at bottom (above navbar)
            Consumer<AudioPlayerState>(
              builder: (context, audioPlayer, child) {
                // Only show if there's a current track
                if (audioPlayer.currentTrack == null) {
                  return const SizedBox.shrink();
                }
                
                final playerState = _playerKey.currentState;
                final isExpanded = playerState?.isExpanded ?? false;
                
                // Position player at bottom, accounting for navbar height when minimized
                return Positioned(
                  bottom: isExpanded ? 0 : 60,
                  left: 0,
                  right: 0,
                  child: SlidingAudioPlayer(key: _playerKey),
                );
              },
            ),
          ],
        ),
      bottomNavigationBar: 
        // Hide bottom nav when player is expanded, show when minimized
        Builder(
          builder: (context) {
            final audioPlayer = context.watch<AudioPlayerState>();
            
            // Listen to player expansion state changes
            return ValueListenableBuilder<bool>(
              valueListenable: SlidingAudioPlayerState.expansionStateNotifier,
              builder: (context, isExpanded, child) {
                // Show navbar if:
                // 1. No track playing, OR
                // 2. Track playing but player is minimized (not expanded)
                final shouldShowNav = audioPlayer.currentTrack == null || !isExpanded;
                return shouldShowNav ? Container(
        height: tabBarHeight.toDouble(),
        decoration: BoxDecoration(
          color: AppColors.backgroundPrimary,
          border: Border(
            top: BorderSide(
              color: AppColors.borderPrimary,
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, -2),
              blurRadius: 4,
            ),
          ],
        ),
        child: BottomNavigationBar(
              currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: AppColors.primaryMain,
            unselectedItemColor: AppColors.textSecondary,
            selectedLabelStyle: TextStyle(
              fontSize: isSmallScreen ? 9 : (PlatformUtils.isIOS ? 11 : 10),
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: isSmallScreen ? 9 : (PlatformUtils.isIOS ? 11 : 10),
              fontWeight: FontWeight.w500,
            ),
            iconSize: PlatformUtils.isIOS ? 28 : 24,
            items: [
          BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                activeIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
                icon: Icon(Icons.search_rounded),
                activeIcon: Icon(Icons.search_rounded),
            label: 'Search',
          ),
          BottomNavigationBarItem(
                icon: Icon(Icons.add_circle_rounded),
                activeIcon: Icon(Icons.add_circle_rounded),
                label: 'Create',
          ),
          BottomNavigationBarItem(
                icon: Icon(Icons.people_rounded),
                activeIcon: Icon(Icons.people_rounded),
            label: 'Community',
          ),
          BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded),
                activeIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
          ),
        ) : const SizedBox.shrink();
              },
            );
          },
        ),
      ),
    );
  }
}

