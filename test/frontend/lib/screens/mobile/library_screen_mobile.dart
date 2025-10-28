import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

class LibraryScreenMobile extends StatefulWidget {
  const LibraryScreenMobile({super.key});

  @override
  State<LibraryScreenMobile> createState() => _LibraryScreenMobileState();
}

class _LibraryScreenMobileState extends State<LibraryScreenMobile> {
  int _selectedIndex = 0;
  final List<String> _sections = ['Downloaded', 'Playlists', 'Favorites'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundPrimary,
        elevation: 0,
        title: const Text('Library'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Segmented Control
          Padding(
            padding: EdgeInsets.all(AppSpacing.medium),
            child: Row(
              children: List.generate(_sections.length, (index) {
                final isSelected = index == _selectedIndex;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.small),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryMain : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                      ),
                      child: Text(
                        _sections[index],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          // Content
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildDownloadedSection();
      case 1:
        return _buildPlaylistsSection();
      case 2:
        return _buildFavoritesSection();
      default:
        return const SizedBox();
    }
  }

  Widget _buildDownloadedSection() {
    return ListView(
      padding: EdgeInsets.all(AppSpacing.medium),
      children: [
        _buildPlaceholderContent(
          icon: Icons.download_outlined,
          title: 'No Downloads',
          message: 'Download content to listen offline',
        ),
      ],
    );
  }

  Widget _buildPlaylistsSection() {
    return ListView(
      padding: EdgeInsets.all(AppSpacing.medium),
      children: [
        _buildPlaceholderContent(
          icon: Icons.queue_music_outlined,
          title: 'No Playlists',
          message: 'Create your first playlist',
        ),
      ],
    );
  }

  Widget _buildFavoritesSection() {
    return ListView(
      padding: EdgeInsets.all(AppSpacing.medium),
      children: [
        _buildPlaceholderContent(
          icon: Icons.favorite_border,
          title: 'No Favorites',
          message: 'Like content to see it here',
        ),
      ],
    );
  }

  Widget _buildPlaceholderContent({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: AppSpacing.large),
          Text(
            title,
            style: AppTypography.heading3.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.small),
          Text(
            message,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
