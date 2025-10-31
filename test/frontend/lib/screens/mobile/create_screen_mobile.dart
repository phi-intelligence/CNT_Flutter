import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../creation/video_podcast_create_screen.dart';
import '../creation/audio_podcast_create_screen.dart';
import 'meeting_options_screen_mobile.dart';

/// Plus/Create Screen - Main entry point for creating content
/// Matches React Native PlusScreen exactly
class CreateScreenMobile extends StatelessWidget {
  const CreateScreenMobile({super.key});

  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.large),
          child: Column(
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Create Content',
                    style: AppTypography.heading2.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    },
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
              
              const SizedBox(height: AppSpacing.extraLarge),
              
              // Options Grid (2 columns, 48% width each)
              Row(
                children: [
                  Expanded(
                    child: _buildOptionCard(
                      context,
                      title: 'Video',
                      subtitle: 'Video podcast',
                      icon: Icons.videocam,
                      color: AppColors.primaryMain,
                      onTap: () => _navigateToScreen(
                        context,
                        const VideoPodcastCreateScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.medium),
                  Expanded(
                    child: _buildOptionCard(
                      context,
                      title: 'Audio',
                      subtitle: 'Audio podcast',
                      icon: Icons.mic,
                      color: AppColors.accentMain,
                      onTap: () => _navigateToScreen(
                        context,
                        const AudioPodcastCreateScreen(),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppSpacing.large),
              
              // Meeting option (full width)
              _buildOptionCard(
                context,
                title: 'Meeting',
                subtitle: 'Start meeting',
                icon: Icons.group,
                color: AppColors.accentMain,
                onTap: () => _navigateToScreen(
                  context,
                  const MeetingOptionsScreenMobile(),
                ),
                isFullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isFullWidth = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: isFullWidth 
          ? const BoxConstraints(minHeight: 120, maxHeight: 150)
          : const BoxConstraints(minHeight: 190, maxHeight: 190),
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: isFullWidth ? AppSpacing.medium : AppSpacing.medium,
          vertical: isFullWidth ? AppSpacing.small : AppSpacing.medium,
        ),
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          border: Border.all(
            color: AppColors.borderPrimary,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon circle - smaller for full width cards to fit
            Container(
              width: isFullWidth ? 48 : 72,
              height: isFullWidth ? 48 : 72,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: AppColors.backgroundPrimary,
                size: isFullWidth ? 24 : 36,
              ),
            ),
            SizedBox(height: isFullWidth ? 6 : AppSpacing.extraSmall),
            // Title
            Text(
              title,
              style: AppTypography.heading4.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: isFullWidth ? 16 : 19,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: isFullWidth ? 2 : 4.0),
            // Subtitle
            Text(
              subtitle,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: isFullWidth ? 12 : 13,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
