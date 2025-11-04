import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/shared/content_section.dart';
import '../../widgets/shared/loading_shimmer.dart';
import '../../widgets/shared/empty_state.dart';
import '../../services/api_service.dart';
import '../../providers/music_provider.dart';
import '../../providers/audio_player_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/playlist_provider.dart';
import '../../models/content_item.dart';
import '../../models/api_models.dart';
import '../../utils/format_utils.dart';
import '../../widgets/video_player.dart';
import '../../utils/platform_helper.dart';
import '../../utils/responsive_grid_delegate.dart';
import '../../utils/dimension_utils.dart';
import '../audio/audio_player_full_screen_new.dart';
import 'audio_player_full_screen_web.dart';

/// Web Home Screen - Real data integration matching mobile
class HomeScreenWeb extends StatefulWidget {
  const HomeScreenWeb({super.key});

  @override
  State<HomeScreenWeb> createState() => _HomeScreenWebState();
}

class _HomeScreenWebState extends State<HomeScreenWeb> {
  final ApiService _api = ApiService();
  
  List<ContentItem> _audioPodcasts = [];
  List<ContentItem> _videoPodcasts = [];
  List<ContentItem> _recentPodcasts = [];
  List<ContentItem> _featuredPodcasts = [];
  List<ContentItem> _newPodcasts = [];
  List<ContentItem> _bibleStories = [];
  bool _isLoadingPodcasts = false;
  bool _isLoadingBibleStories = false;

  @override
  void initState() {
    super.initState();
    print('✅ HomeScreenWeb initState');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      try {
        print('✅ HomeScreenWeb: Fetching data...');
        _fetchPodcasts();
        _fetchBibleStories();
        context.read<MusicProvider>().fetchTracks();
        context.read<UserProvider>().fetchUser();
        context.read<PlaylistProvider>().fetchPlaylists();
        print('✅ HomeScreenWeb: Data fetch initiated');
      } catch (e) {
        print('❌ HomeScreenWeb: Error initializing providers: $e');
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
      
      // Get featured podcasts (sorted by plays_count)
      _featuredPodcasts = List.from(allContentItems);
      _featuredPodcasts.sort((a, b) => b.plays.compareTo(a.plays));
      _featuredPodcasts = _featuredPodcasts.take(10).toList();
      
      // Get new podcasts (sorted by created_at)
      _newPodcasts = List.from(allContentItems);
      _newPodcasts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _newPodcasts = _newPodcasts.take(10).toList();
      
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

  Future<void> _fetchBibleStories() async {
    if (_isLoadingBibleStories) return;
    
    setState(() {
      _isLoadingBibleStories = true;
    });

    try {
      // TODO: Implement getBibleStories API method
      // For now, use empty list
      _bibleStories = [];
    } catch (e) {
      print('❌ Error fetching bible stories: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingBibleStories = false;
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

    context.read<AudioPlayerState>().playContent(item);
  }

  void _handleItemTap(ContentItem item) {
    _handlePlay(item);
  }

  void _handlePlayVideo(ContentItem item) {
    if (item.videoUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No video available for ${item.title}')),
      );
      return;
    }

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
    _handlePlayVideo(item);
  }

  void _handleDiscIconPress() {
    if (_audioPodcasts.isNotEmpty) {
      final firstPodcast = _audioPodcasts.first;
      if (firstPodcast.audioUrl != null) {
        context.read<AudioPlayerState>().playContent(firstPodcast);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlatformHelper.isWebPlatform()
                ? const AudioPlayerFullScreenWeb()
                : const AudioPlayerFullScreenNew(),
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

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: Container(
        padding: ResponsiveGridDelegate.getResponsivePadding(context),
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              _fetchPodcasts(),
              _fetchBibleStories(),
              musicProvider.fetchTracks(),
              context.read<PlaylistProvider>().fetchPlaylists(),
            ]);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                      // Hero Section
                      _buildHeroSection(),
                      
                      const SizedBox(height: AppSpacing.extraLarge),
                      
                      // Featured Podcasts
                      if (_isLoadingPodcasts)
                        _buildLoadingSection('Featured', height: 300)
                      else if (_featuredPodcasts.isEmpty)
                        const SizedBox.shrink()
                      else
                        ContentSection(
                          title: 'Featured',
                          items: _featuredPodcasts,
                          isHorizontal: true,
                          onItemPlay: _handlePlay,
                          onItemTap: _handleItemTap,
                        ),
                      
                      const SizedBox(height: AppSpacing.extraLarge),
                      
                      // Audio Podcasts (moved above Recently Played)
                      if (_isLoadingPodcasts)
                        _buildLoadingSection('Audio Podcasts', height: 240)
                      else if (_audioPodcasts.isEmpty)
                        const SizedBox.shrink()
                      else
                        ContentSection(
                          title: 'Audio Podcasts',
                          items: _audioPodcasts.take(8).toList(),
                          isHorizontal: false,
                          useDiscDesign: true,
                          onItemPlay: _handlePlay,
                          onItemTap: _handleItemTap,
                        ),
                      
                      const SizedBox(height: AppSpacing.extraLarge),
                      
                      // Recently Played
                      if (_isLoadingPodcasts)
                        _buildLoadingSection('Recently Played', height: 200)
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
                          isHorizontal: true,
                          onItemPlay: _handlePlay,
                          onItemTap: _handleItemTap,
                        ),
                      
                      const SizedBox(height: AppSpacing.extraLarge),
                      
                      // New Podcasts
                      if (_isLoadingPodcasts)
                        _buildLoadingSection('New Podcasts', height: 200)
                      else if (_newPodcasts.isEmpty)
                        const SizedBox.shrink()
                      else
                        ContentSection(
                          title: 'New Podcasts',
                          items: _newPodcasts,
                          isHorizontal: true,
                          onItemPlay: _handlePlay,
                          onItemTap: _handleItemTap,
                        ),
                      
                      const SizedBox(height: AppSpacing.extraLarge),
                      
                      // Video Podcasts
                      if (_isLoadingPodcasts)
                        _buildLoadingSection('Video Podcasts', height: 300)
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
                      
                      const SizedBox(height: AppSpacing.extraLarge),
                      
                      // Music Section
                      Consumer<MusicProvider>(
                        builder: (context, provider, child) {
                          if (provider.isLoading) {
                            return _buildLoadingSection('Music', height: 200);
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
                      
                      const SizedBox(height: AppSpacing.extraLarge),
                      
                      // Playlists
                      Consumer<PlaylistProvider>(
                        builder: (context, provider, child) {
                          if (provider.isLoading) {
                            return _buildLoadingSection('Your Playlists', height: 200);
                          }
                          
                          if (provider.playlists.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          
                          // Convert playlists to ContentItems for display
                          final playlistItems = provider.playlists.take(4).map((playlist) {
                            return ContentItem(
                              id: playlist['id'].toString(),
                              title: playlist['name'] ?? 'Untitled Playlist',
                              creator: 'You',
                              description: playlist['description'],
                              coverImage: playlist['cover_image'],
                              category: 'Playlist',
                              createdAt: DateTime.parse(playlist['created_at'] ?? DateTime.now().toIso8601String()),
                            );
                          }).toList();
                          
                          return ContentSection(
                            title: 'Your Playlists',
                            items: playlistItems,
                            isHorizontal: false,
                            onItemTap: (item) {
                              // TODO: Navigate to playlist detail
                            },
                          );
                        },
                      ),
                      
                      const SizedBox(height: AppSpacing.extraLarge),
                      
                      // Bible Stories
                      if (_isLoadingBibleStories)
                        _buildLoadingSection('Bible Stories', height: 300)
                      else if (_bibleStories.isEmpty)
                        const SizedBox.shrink()
                      else
                        ContentSection(
                          title: 'Bible Stories',
                          items: _bibleStories,
                          isHorizontal: false,
                          onItemPlay: _handlePlay,
                          onItemTap: _handleItemTap,
                        ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingSection(String title, {required double height}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.heading2.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: height,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(right: AppSpacing.medium),
                child: const LoadingShimmer(width: 180, height: 220),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeroSection() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return Container(
          padding: EdgeInsets.all(AppSpacing.large * 2),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primaryMain, AppColors.accentMain],
            ),
            borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getGreeting(userProvider.user),
                      style: AppTypography.heading2.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.small),
                    const Text(
                      'Welcome back',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    const Text(
                      'Experience God\'s word through engaging podcasts, Bible stories, and spiritual guidance. Join our community of believers in Christ.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
              // Disc Icon
              Padding(
                padding: EdgeInsets.only(left: AppSpacing.large),
                child: GestureDetector(
                  onTap: _handleDiscIconPress,
                  child: Container(
                    width: 80,
                    height: 80,
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
                            size: 36,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
