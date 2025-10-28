import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/web/sidebar_nav.dart';

/// Web Podcasts Screen
class PodcastsScreenWeb extends StatelessWidget {
  const PodcastsScreenWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: Row(
        children: [
          WebSidebarNavigation(currentRoute: '/podcasts'),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(AppSpacing.large * 1.5),
              child: const Center(
                child: Text('Podcasts Screen - Coming Soon'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

