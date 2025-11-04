import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../utils/responsive_grid_delegate.dart';
import '../../utils/dimension_utils.dart';

/// Web About Screen
class AboutScreenWeb extends StatelessWidget {
  const AboutScreenWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: Container(
        padding: ResponsiveGridDelegate.getResponsivePadding(context),
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo/Icon
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.primaryMain,
                      borderRadius: BorderRadius.circular(60),
                    ),
                    child: const Icon(
                      Icons.church,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.extraLarge),
                  
                  // App Name
                  Text(
                    'CNT Media Platform',
                    style: AppTypography.heading1.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryMain,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.small),
                  
                  // Tagline
                  Text(
                    'Christian Podcasts, Music, and Community',
                    style: AppTypography.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.extraLarge),
                  
                  // Version
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.large),
                      child: Column(
                        children: [
                          Text(
                            'Version 1.0.0',
                            style: AppTypography.heading3,
                          ),
                          const SizedBox(height: AppSpacing.small),
                          Text(
                            '© 2024 Christ New Tabernacle',
                            style: AppTypography.body.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.extraLarge),
                  
                  // Description
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.large),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'About',
                            style: AppTypography.heading3.copyWith(
                              fontWeight: FontWeight.bold,
      ),
                          ),
                          const SizedBox(height: AppSpacing.medium),
                          Text(
                            'CNT Media Platform is a comprehensive Christian media application offering podcasts, music, Bible stories, live streaming, and community features. Join our community of believers in Christ.',
                            style: AppTypography.body,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.large),
                  
                  // Features
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.large),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Features',
                            style: AppTypography.heading3.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.medium),
                          _buildFeatureItem(Icons.podcasts, 'Audio & Video Podcasts'),
                          _buildFeatureItem(Icons.music_note, 'Christian Music Library'),
                          _buildFeatureItem(Icons.book, 'Bible Stories'),
                          _buildFeatureItem(Icons.radio, 'Live Streaming'),
                          _buildFeatureItem(Icons.people, 'Community Posts'),
                          _buildFeatureItem(Icons.folder, 'Playlists & Favorites'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.small),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryMain, size: 20),
          const SizedBox(width: AppSpacing.medium),
          Text(
            text,
            style: AppTypography.body,
          ),
        ],
      ),
    );
  }
}

