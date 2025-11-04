import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../creation/video_podcast_create_screen.dart';
import '../creation/audio_podcast_create_screen.dart';
import '../mobile/meeting_options_screen_mobile.dart';
import '../../utils/responsive_grid_delegate.dart';
import '../../utils/dimension_utils.dart';

/// Web Create Screen - Full implementation
class CreateScreenWeb extends StatelessWidget {
  const CreateScreenWeb({super.key});

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
      body: Container(
        padding: ResponsiveGridDelegate.getResponsivePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Create Content',
              style: AppTypography.heading2.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.extraLarge),
            
            // Responsive layout: Row for desktop, Column for mobile/tablet
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final isDesktop = width >= 1024;
                
                if (isDesktop) {
                  // Desktop: 2 columns side by side
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                          const SizedBox(width: AppSpacing.large),
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
                          MeetingOptionsScreenMobile(),
                        ),
                        isFullWidth: true,
                      ),
                    ],
                  );
                } else {
                  // Mobile/Tablet: Stack vertically
                  return Column(
                    children: [
                      _buildOptionCard(
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
                      const SizedBox(height: AppSpacing.large),
                      _buildOptionCard(
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
                      const SizedBox(height: AppSpacing.large),
                      _buildOptionCard(
                        context,
                        title: 'Meeting',
                        subtitle: 'Start meeting',
                        icon: Icons.group,
                        color: AppColors.accentMain,
                        onTap: () => _navigateToScreen(
                          context,
                          MeetingOptionsScreenMobile(),
                        ),
                        isFullWidth: true,
                      ),
                    ],
                  );
                }
              },
            ),
          ],
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
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          constraints: isFullWidth 
            ? const BoxConstraints(minHeight: 200, maxHeight: 220) // Increased for content
            : const BoxConstraints(minHeight: 260, maxHeight: 280), // Increased for content
          width: double.infinity,
          padding: EdgeInsets.all(isFullWidth ? AppSpacing.large : AppSpacing.large * 1.5),
          decoration: BoxDecoration(
            color: AppColors.backgroundSecondary,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
            border: Border.all(
              color: AppColors.borderPrimary,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon circle
              Container(
                width: isFullWidth ? 64 : 96,
                height: isFullWidth ? 64 : 96,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: AppColors.backgroundPrimary,
                  size: isFullWidth ? 32 : 48,
                ),
              ),
              SizedBox(height: isFullWidth ? AppSpacing.medium : AppSpacing.large),
              // Title
              Text(
                title,
                style: AppTypography.heading3.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: isFullWidth ? 20 : 24,
                  height: 1.2, // Tighter line height
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: isFullWidth ? AppSpacing.small : AppSpacing.medium),
              // Subtitle
              Text(
                subtitle,
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: isFullWidth ? 14 : 16,
                  height: 1.2, // Tighter line height
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
