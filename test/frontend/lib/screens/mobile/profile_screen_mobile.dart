import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

class ProfileScreenMobile extends StatelessWidget {
  const ProfileScreenMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: ListView(
        children: [
          // Profile Header
          Container(
            padding: EdgeInsets.all(AppSpacing.large),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primaryMain, AppColors.accentMain],
              ),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.person, size: 50, color: AppColors.primaryMain),
                ),
                const SizedBox(height: AppSpacing.medium),
                Text(
                  'John Doe',
                  style: AppTypography.heading2.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.tiny),
                Text(
                  'john.doe@example.com',
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: AppSpacing.small),
                Text(
                  'Member since January 2024',
                  style: AppTypography.caption.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),

          // Stats Cards
          Padding(
            padding: EdgeInsets.all(AppSpacing.medium),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard('Minutes', '1,234', Icons.timer),
                ),
                const SizedBox(width: AppSpacing.small),
                Expanded(
                  child: _buildStatCard('Songs', '567', Icons.music_note),
                ),
                const SizedBox(width: AppSpacing.small),
                Expanded(
                  child: _buildStatCard('Streak', '30', Icons.local_fire_department),
                ),
              ],
            ),
          ),

          // Settings List
          _buildSectionTitle('Account'),
          _buildSettingTile(
            icon: Icons.person_outline,
            title: 'Edit Profile',
            onTap: () {},
          ),
          _buildSettingTile(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            onTap: () {},
          ),
          _buildSettingTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Settings',
            onTap: () {},
          ),

          const SizedBox(height: AppSpacing.small),

          _buildSectionTitle('Support'),
          _buildSettingTile(
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: () {},
          ),
          _buildSettingTile(
            icon: Icons.info_outline,
            title: 'About',
            onTap: () {},
          ),

          const SizedBox(height: AppSpacing.small),

          _buildSettingTile(
            icon: Icons.logout,
            title: 'Logout',
            titleColor: AppColors.errorMain,
            onTap: () {
              // TODO: Implement logout
            },
          ),

          const SizedBox(height: AppSpacing.extraLarge),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.medium),
        child: Column(
          children: [
            Icon(icon, size: 32, color: AppColors.primaryMain),
            const SizedBox(height: AppSpacing.small),
            Text(
              value,
              style: AppTypography.heading3.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.tiny),
            Text(
              label,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.medium,
        AppSpacing.medium,
        AppSpacing.medium,
        AppSpacing.small,
      ),
      child: Text(
        title,
        style: AppTypography.heading4.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? titleColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryMain),
      title: Text(title, style: TextStyle(color: titleColor ?? AppColors.textPrimary)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textTertiary),
      onTap: onTap,
    );
  }
}
