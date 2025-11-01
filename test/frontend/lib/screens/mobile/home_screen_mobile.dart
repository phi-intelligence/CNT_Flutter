import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/shared/content_section.dart';
import '../../widgets/shared/loading_shimmer.dart';
import '../../widgets/shared/empty_state.dart';
import '../../services/api_service.dart';
import '../../providers/music_provider.dart';
import '../../providers/audio_player_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/content_item.dart';
import '../../models/api_models.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../utils/format_utils.dart';
import '../../utils/platform_utils.dart';
import '../../widgets/video_player.dart';
import '../audio/audio_player_full_screen_new.dart';
import '../../widgets/shared/image_helper.dart';

class HomeScreenMobile extends StatefulWidget {
  const HomeScreenMobile({super.key});

  @override
  State<HomeScreenMobile> createState() => _HomeScreenMobileState();
}

class _HomeScreenMobileState extends State<HomeScreenMobile> {
  final ApiService _api = ApiService();
  
  List<ContentItem> _audioPodcasts = [];
  List<ContentItem> _videoPodcasts = [];
  List<ContentItem> _recentPodcasts = [];
  bool _isLoadingPodcasts = false;

  @override
  void initState() {
    super.initState();
    print('✅ HomeScreenMobile initState');
    // Fetch data on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      try {
        print('✅ HomeScreenMobile: Fetching data...');
        _fetchPodcasts();
        context.read<MusicProvider>().fetchTracks();
        context.read<UserProvider>().fetchUser();
        print('✅ HomeScreenMobile: Data fetch initiated');
      } catch (e) {
        print('❌ HomeScreenMobile: Error initializing providers: $e');
      }
    });
  }

  Future<void> _fetchPodcasts() async {
    if (_isLoadingPodcasts) return;
    
    setState(() {
      _isLoadingPodcasts = true;
    });

    try {
      final podcastsData = await _api.getPodcasts();
      
      // Convert Podcast models to ContentItem models
      final allContentItems = podcastsData.map((podcast) {
        final audioUrl = podcast.audioUrl != null && podcast.audioUrl!.isNotEmpty
            ? _api.getMediaUrl(podcast.audioUrl!)
            : null;
        final videoUrl = podcast.videoUrl != null && podcast.videoUrl!.isNotEmpty
            ? _api.getMediaUrl(podcast.videoUrl!)
            : null;
        
        return ContentItem(
          id: podcast.id.toString(),
          title: podcast.title,
          creator: 'Christ Tabernacle',
          description: podcast.description,
          coverImage: podcast.coverImage != null 
            ? _api.getMediaUrl(podcast.coverImage!) 
            : null,
          audioUrl: audioUrl,
          videoUrl: videoUrl,
          duration: podcast.duration != null 
            ? Duration(seconds: podcast.duration!)
            : null,
          category: _getCategoryName(podcast.categoryId),
          plays: podcast.playsCount,
          createdAt: podcast.createdAt,
        );
      }).toList();
      
      // Separate audio and video podcasts
      _audioPodcasts = allContentItems.where((p) => 
        p.audioUrl != null && 
        p.audioUrl!.isNotEmpty && 
        (p.videoUrl == null || p.videoUrl!.isEmpty)
      ).toList();
      
      _videoPodcasts = allContentItems.where((p) => 
        p.videoUrl != null && 
        p.videoUrl!.isNotEmpty
      ).toList();
      
      // Get recent podcasts (audio podcasts sorted by created_at)
      _recentPodcasts = List.from(_audioPodcasts);
      _recentPodcasts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _recentPodcasts = _recentPodcasts.take(5).toList();
      
      print('✅ Loaded ${_audioPodcasts.length} audio podcasts and ${_videoPodcasts.length} video podcasts');
    } catch (e) {
      print('❌ Error fetching podcasts: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingPodcasts = false;
        });
      }
    }
  }

  String _getCategoryName(int? categoryId) {
    switch (categoryId) {
      case 1: return 'Sermons';
      case 2: return 'Bible Study';
      case 3: return 'Devotionals';
      case 4: return 'Prayer';
      case 5: return 'Worship';
      case 6: return 'Gospel';
      default: return 'Podcast';
    }
  }

  String _getGreeting(Map<String, dynamic>? user) {
    final username = user?['name'] ?? 'Guest';
    return 'Hey $username';
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
  }

  void _handleItemTap(ContentItem item) {
    // Navigate to player - handled by SlidingAudioPlayer
    _handlePlay(item);
  }

  void _handlePlayVideo(ContentItem item) {
    if (item.videoUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No video available for ${item.title}')),
      );
      return;
    }

    // Navigate to video player screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerWidget(
          videoUrl: item.videoUrl!,
          title: item.title,
        ),
      ),
    );
  }

  void _handleItemTapVideo(ContentItem item) {
    // Navigate to video player
    _handlePlayVideo(item);
  }

  void _handleDiscIconPress() {
    // If there's a first audio podcast, play it and open full screen player
    if (_audioPodcasts.isNotEmpty) {
      final firstPodcast = _audioPodcasts.first;
      if (firstPodcast.audioUrl != null) {
        // Play the content
        context.read<AudioPlayerState>().playContent(firstPodcast);
        // Navigate to full screen audio player
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AudioPlayerFullScreenNew(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No audio available')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No podcasts available')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final musicProvider = Provider.of<MusicProvider>(context, listen: false);

    return Container(
      color: AppColors.backgroundPrimary,
      child: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              await Future.wait([
                _fetchPodcasts(),
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
                              Consumer<UserProvider>(
                                builder: (context, userProvider, child) {
                                  return Text(
                                    _getGreeting(userProvider.user),
                                    style: AppTypography.heading3.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: AppSpacing.small),
                              Text(
                                'welcome back',
                                style: AppTypography.heading4.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Disc Icon
                      Padding(
                        padding: EdgeInsets.only(right: AppSpacing.large),
                        child: GestureDetector(
                          onTap: _handleDiscIconPress,
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppColors.primaryMain,
                                      AppColors.accentMain,
                                    ],
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.music_note,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: AppSpacing.extraLarge),
                
                // Video Podcasts Section (All Video Podcasts)
                if (_isLoadingPodcasts)
                  Padding(
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
                  )
                else if (_videoPodcasts.isEmpty)
                  const SizedBox.shrink()
                else
                  ContentSection(
                    title: 'Video Podcasts',
                    items: _videoPodcasts,
                    isHorizontal: true,
                    onItemPlay: _handlePlayVideo,
                    onItemTap: _handleItemTapVideo,
                  ),
                
                const SizedBox(height: AppSpacing.large),
                
                // Audio Podcasts Section
                if (_isLoadingPodcasts)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.medium),
                    child: Column(
                      children: List.generate(3, (_) => Padding(
                        padding: EdgeInsets.only(bottom: AppSpacing.small),
                        child: const LoadingShimmer(width: double.infinity, height: 100),
                      )),
                    ),
                  )
                else if (_audioPodcasts.isEmpty)
                  const SizedBox.shrink()
                else
                  ContentSection(
                    title: 'Audio Podcasts',
                    items: _audioPodcasts.take(3).toList(),
                    isHorizontal: false,
                    useDiscDesign: true,
                    onItemPlay: _handlePlay,
                    onItemTap: _handleItemTap,
                  ),
                
                const SizedBox(height: AppSpacing.large),
                
                // Recently Played Section
                if (_isLoadingPodcasts)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.medium),
                    child: Column(
                      children: List.generate(3, (_) => Padding(
                        padding: EdgeInsets.only(bottom: AppSpacing.small),
                        child: const LoadingShimmer(width: double.infinity, height: 100),
                      )),
                    ),
                  )
                else if (_recentPodcasts.isEmpty)
                  const EmptyState(
                    icon: Icons.history,
                    title: 'No Recent Playbacks',
                    message: 'Start exploring content to see your recently played items here',
                  )
                else
                  ContentSection(
                    title: 'Recently Played',
                    items: _recentPodcasts,
                    isHorizontal: false,
                    onItemPlay: _handlePlay,
                    onItemTap: _handleItemTap,
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
