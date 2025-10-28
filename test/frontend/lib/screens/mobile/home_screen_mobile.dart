import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/voice/voice_bubble.dart';
import '../../widgets/shared/content_section.dart';
import '../../widgets/shared/loading_shimmer.dart';
import '../../widgets/shared/empty_state.dart';
import '../../providers/podcast_provider.dart';
import '../../providers/music_provider.dart';
import '../../providers/audio_player_provider.dart';
import '../../models/content_item.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../utils/format_utils.dart';
import '../../utils/platform_utils.dart';
import 'voice_chat_modal.dart';

class HomeScreenMobile extends StatefulWidget {
  const HomeScreenMobile({super.key});

  @override
  State<HomeScreenMobile> createState() => _HomeScreenMobileState();
}

class _HomeScreenMobileState extends State<HomeScreenMobile> {
  bool _isVoiceActive = false;

  @override
  void initState() {
    super.initState();
    // Fetch data on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PodcastProvider>().fetchPodcasts();
      context.read<MusicProvider>().fetchTracks();
    });
  }

  void _handleVoiceBubblePress() {
    // Open voice chat modal as full screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const VoiceChatModal(),
        fullscreenDialog: true,
      ),
    );
  }

  String _getGreeting() {
    return FormatUtils.getGreeting();
  }

  void _handlePlay(ContentItem item) {
    if (item.audioUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No audio available for ${item.title}')),
      );
      return;
    }

    // Play audio via AudioPlayerState
    context.read<AudioPlayerState>().playContent(item);
    
    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Now playing: ${item.title}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleItemTap(ContentItem item) {
    // Navigate to player - handled by SlidingAudioPlayer
    _handlePlay(item);
  }

  @override
  Widget build(BuildContext context) {
    final podcastProvider = Provider.of<PodcastProvider>(context, listen: false);
    final musicProvider = Provider.of<MusicProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              await Future.wait([
                podcastProvider.fetchPodcasts(),
                musicProvider.fetchTracks(),
              ]);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                // Hero Section with Gradient Background
                Container(
                  padding: EdgeInsets.only(
                    top: PlatformUtils.isIOS ? 50 : AppSpacing.large,
                    bottom: AppSpacing.large,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primaryMain, AppColors.accentMain],
                      ),
                    ),
                  child: Row(
                    children: [
                      Expanded(
                  child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: AppSpacing.large),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                                _getGreeting(),
                                style: AppTypography.heading3.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.small),
                              Text(
                                'Welcome to Christ New Tabernacle',
                                style: AppTypography.heading4.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.medium),
                              Text(
                                'Experience God\'s word through engaging podcasts, Bible stories, and spiritual guidance. Join our community of believers in Christ.',
                                style: AppTypography.bodySmall.copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.large),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {},
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: AppColors.primaryMain,
                                        padding: EdgeInsets.symmetric(
                                          vertical: AppSpacing.small,
                                          horizontal: AppSpacing.medium,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                                        ),
                                      ),
                                      child: const Text(
                                        'Start Listening',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.medium),
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () {},
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        side: const BorderSide(color: Colors.white, width: 2),
                                        padding: EdgeInsets.symmetric(
                                          vertical: AppSpacing.small,
                                          horizontal: AppSpacing.medium,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                                        ),
                                      ),
                                      child: const Text(
                                        'Join Prayer',
                          style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Voice Bubble
                      Padding(
                        padding: EdgeInsets.only(right: AppSpacing.large),
                        child: VoiceBubble(
                          onPressed: _handleVoiceBubblePress,
                          isActive: _isVoiceActive,
                          label: _isVoiceActive ? '' : '',
                          ),
                        ),
                      ],
                  ),
                ),
                
                const SizedBox(height: AppSpacing.extraLarge),
                
                // Featured Podcasts Section
                Consumer<PodcastProvider>(
                    builder: (context, provider, child) {
                      if (provider.isLoading) {
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: AppSpacing.medium),
                          child: SizedBox(
                            height: 200,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: 3,
                              itemBuilder: (_, __) => Padding(
                                padding: EdgeInsets.only(right: AppSpacing.small),
                                child: const LoadingShimmer(width: 160, height: 200),
                              ),
                            ),
                          ),
                        );
                      }
                      
                      if (provider.featuredPodcasts.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      
                      return ContentSection(
                        title: 'Featured',
                        items: provider.featuredPodcasts,
                        isHorizontal: true,
                        onItemPlay: _handlePlay,
                        onItemTap: _handleItemTap,
                      );
                    },
                ),
                
                const SizedBox(height: AppSpacing.large),
                
                // Recently Played Section
                Consumer<PodcastProvider>(
                    builder: (context, provider, child) {
                      if (provider.isLoading) {
                        return Padding(
                        padding: EdgeInsets.symmetric(horizontal: AppSpacing.medium),
                          child: Column(
                            children: List.generate(3, (_) => Padding(
                            padding: EdgeInsets.only(bottom: AppSpacing.small),
                            child: const LoadingShimmer(width: double.infinity, height: 100),
                            )),
                          ),
                        );
                      }
                      
                      if (provider.recentPodcasts.isEmpty) {
                        return const EmptyState(
                          icon: Icons.history,
                          title: 'No Recent Playbacks',
                          message: 'Start exploring content to see your recently played items here',
                        );
                      }
                      
                      return ContentSection(
                        title: 'Recently Played',
                        items: provider.recentPodcasts,
                        isHorizontal: false,
                        onItemPlay: _handlePlay,
                        onItemTap: _handleItemTap,
                      );
                    },
                ),
                
                const SizedBox(height: AppSpacing.large),
                
                // New Podcasts Section
                Consumer<PodcastProvider>(
                    builder: (context, provider, child) {
                      if (provider.podcasts.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      
                      return ContentSection(
                        title: 'New Podcasts',
                        items: provider.podcasts.take(3).toList(),
                        isHorizontal: false,
                        onItemPlay: _handlePlay,
                        onItemTap: _handleItemTap,
                      );
                    },
                ),
                
                const SizedBox(height: AppSpacing.large),
                
                // Featured Music Section
                Consumer<MusicProvider>(
                    builder: (context, provider, child) {
                      if (provider.isLoading) {
                        return const SizedBox.shrink();
                      }
                      
                      if (provider.featuredTracks.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      
                      return ContentSection(
                        title: 'Featured Music',
                        items: provider.featuredTracks,
                        isHorizontal: true,
                        onItemPlay: _handlePlay,
                        onItemTap: _handleItemTap,
                      );
                    },
                ),
                
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
