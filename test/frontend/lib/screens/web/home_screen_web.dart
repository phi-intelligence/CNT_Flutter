import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/web/sidebar_nav.dart';

/// Web Home Screen - Exact replica of React web home page
class HomeScreenWeb extends StatelessWidget {
  const HomeScreenWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: Row(
        children: [
          // Sidebar
          WebSidebarNavigation(
            currentRoute: '/',
          ),
          
          // Main content area
          Expanded(
            child: Container(
              padding: EdgeInsets.all(AppSpacing.large * 1.5),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero Section
                    _buildHeroSection(),
                    
                    const SizedBox(height: AppSpacing.extraLarge),
                    
                    // Featured Podcasts
                    _buildFeaturedPodcasts(),
                    
                    const SizedBox(height: AppSpacing.extraLarge),
                    
                    // Recently Played
                    _buildRecentlyPlayed(),
                    
                    const SizedBox(height: AppSpacing.extraLarge),
                    
                    // New Podcasts
                    _buildNewPodcasts(),
                    
                    const SizedBox(height: AppSpacing.extraLarge),
                    
                    // Video Podcasts
                    _buildVideoPodcasts(),
                    
                    const SizedBox(height: AppSpacing.extraLarge),
                    
                    // Audio Podcasts
                    _buildAudioPodcasts(),
                    
                    const SizedBox(height: AppSpacing.extraLarge),
                    
                    // Music Section
                    _buildMusicSection(),
                    
                    const SizedBox(height: AppSpacing.extraLarge),
                    
                    // Playlists
                    _buildPlaylists(),
                    
                    const SizedBox(height: AppSpacing.extraLarge),
                    
                    // Bible Stories
                    _buildBibleStories(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome to Christ New Tabernacle',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.medium),
          const Text(
            'Experience God\'s word through engaging podcasts, Bible stories, and spiritual guidance. Join our community of believers in Christ.',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              height: 1.6,
            ),
          ),
          const SizedBox(height: AppSpacing.large),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primaryMain,
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.large * 2,
                    vertical: AppSpacing.medium,
                  ),
                ),
                child: const Text('Start Listening'),
              ),
              const SizedBox(width: AppSpacing.medium),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white, width: 2),
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.large * 2,
                    vertical: AppSpacing.medium,
                  ),
                ),
                child: const Text('Join Prayer'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedPodcasts() {
    return _buildSection(
      title: 'Featured',
      child: SizedBox(
        height: 300,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 4,
          itemBuilder: (context, index) {
            return Container(
              width: 250,
              margin: EdgeInsets.only(right: AppSpacing.medium),
              child: _buildPodcastCard(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRecentlyPlayed() {
    return _buildSection(
      title: 'Recently Played',
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 5,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.backgroundSecondary,
              child: const Icon(Icons.music_note),
            ),
            title: Text('Item ${index + 1}'),
            subtitle: Text('Artist ${index + 1}'),
            trailing: const Icon(Icons.play_circle_outline),
          );
        },
      ),
    );
  }

  Widget _buildNewPodcasts() {
    return _buildSection(
      title: 'New Podcasts',
      child: SizedBox(
        height: 200,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 6,
          itemBuilder: (context, index) {
            return Container(
              width: 200,
              margin: EdgeInsets.only(right: AppSpacing.medium),
              child: _buildPodcastCard(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildVideoPodcasts() {
    return _buildSection(
      title: 'Video Podcasts',
      child: SizedBox(
        height: 300,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 4,
          itemBuilder: (context, index) {
            return Container(
              width: 250,
              margin: EdgeInsets.only(right: AppSpacing.medium),
              child: _buildPodcastCard(isVideo: true),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAudioPodcasts() {
    return _buildSection(
      title: 'Audio Podcasts',
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 0.8,
          crossAxisSpacing: AppSpacing.medium,
          mainAxisSpacing: AppSpacing.medium,
        ),
        itemCount: 8,
        itemBuilder: (context, index) {
          return _buildPodcastCard();
        },
      ),
    );
  }

  Widget _buildMusicSection() {
    return _buildSection(
      title: 'Music',
      child: SizedBox(
        height: 200,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 8,
          itemBuilder: (context, index) {
            return Container(
              width: 180,
              margin: EdgeInsets.only(right: AppSpacing.medium),
              child: _buildPodcastCard(isMusic: true),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPlaylists() {
    return _buildSection(
      title: 'Your Playlists',
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 0.9,
          crossAxisSpacing: AppSpacing.medium,
          mainAxisSpacing: AppSpacing.medium,
        ),
        itemCount: 4,
        itemBuilder: (context, index) {
          return _buildPlaylistCard();
        },
      ),
    );
  }

  Widget _buildBibleStories() {
    return _buildSection(
      title: 'Bible Stories',
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.2,
          crossAxisSpacing: AppSpacing.medium,
          mainAxisSpacing: AppSpacing.medium,
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          return _buildBibleStoryCard();
        },
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.medium),
        child,
      ],
    );
  }

  Widget _buildPodcastCard({bool isVideo = false, bool isMusic = false}) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppSpacing.radiusMedium),
                ),
              ),
              child: Center(
                child: Icon(
                  isVideo ? Icons.videocam : isMusic ? Icons.music_note : Icons.headphones,
                  size: 48,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(AppSpacing.small),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Podcast Title',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  'Artist Name',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaylistCard() {
    return Card(
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppSpacing.radiusMedium),
                ),
              ),
              child: const Center(
                child: Icon(Icons.queue_music, size: 48, color: AppColors.textSecondary),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(AppSpacing.small),
            child: const Text(
              'Playlist Name',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBibleStoryCard() {
    return Card(
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppSpacing.radiusMedium),
                ),
              ),
              child: const Center(
                child: Icon(Icons.book, size: 48, color: AppColors.textSecondary),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(AppSpacing.small),
            child: Column(
              children: [
                const Text(
                  'Bible Story',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
