import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/web/sidebar_nav.dart';

class DiscoverScreenWeb extends StatelessWidget {
  const DiscoverScreenWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: Row(
        children: [
          WebSidebarNavigation(currentRoute: '/discover'),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(AppSpacing.large * 1.5),
              child: const Center(child: Text('Discover Screen - Coming Soon')),
            ),
          ),
        ],
      ),
    );
  }
}
