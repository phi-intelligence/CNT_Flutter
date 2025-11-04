import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../providers/user_provider.dart';
import '../../utils/format_utils.dart';

class ProfileScreenMobile extends StatefulWidget {
  const ProfileScreenMobile({super.key});

  @override
  State<ProfileScreenMobile> createState() => _ProfileScreenMobileState();
}

class _ProfileScreenMobileState extends State<ProfileScreenMobile> {
  @override
  void initState() {
    super.initState();
    print('✅ ProfileScreenMobile initState');
    // Fetch user data on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      try {
        context.read<UserProvider>().fetchUser();
      } catch (e) {
        print('❌ ProfileScreenMobile: Error fetching user: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: Consumer<UserProvider>(
        builder: (context, provider, child) {
          final user = provider.user;
          final stats = provider.stats;
          
          return ListView(
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
                    if (provider.isLoading)
                      const CircularProgressIndicator(color: Colors.white)
                    else ...[
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        backgroundImage: user?['avatar'] != null
                            ? NetworkImage(user!['avatar'])
                            : null,
                        child: user?['avatar'] == null
                            ? const Icon(Icons.person, size: 50, color: AppColors.primaryMain)
                            : null,
                      ),
                      const SizedBox(height: AppSpacing.medium),
                      Text(
                        user?['name'] ?? 'Guest User',
                        style: AppTypography.heading2.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.tiny),
                      Text(
                        user?['email'] ?? '',
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.small),
                      if (user?['created_at'] != null)
                        Text(
                          'Member since ${_formatMemberSince(user!['created_at'])}',
                          style: AppTypography.caption.copyWith(
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                    ],
                  ],
                ),
              ),

              // Stats Cards
              Padding(
                padding: EdgeInsets.all(AppSpacing.medium),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Minutes',
                        stats?['total_minutes']?.toString() ?? '0',
                        Icons.timer,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.small),
                    Expanded(
                      child: _buildStatCard(
                        'Songs',
                        stats?['songs_played']?.toString() ?? '0',
                        Icons.music_note,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.small),
                    Expanded(
                      child: _buildStatCard(
                        'Streak',
                        '${stats?['streak_days'] ?? 0}',
                        Icons.local_fire_department,
                      ),
                    ),
                  ],
                ),
              ),

              // Settings List
              _buildSectionTitle('Account'),
              _buildSettingTile(
                icon: Icons.person_outline,
                title: 'Edit Profile',
                onTap: () {
                  // TODO: Navigate to edit profile
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Edit profile coming soon')),
                  );
                },
              ),
              _buildSettingTile(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notifications settings coming soon')),
                  );
                },
              ),
              _buildSettingTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Settings',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Privacy settings coming soon')),
                  );
                },
              ),

              const SizedBox(height: AppSpacing.small),

              _buildSectionTitle('Support'),
              _buildSettingTile(
                icon: Icons.help_outline,
                title: 'Help & Support',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Help & support coming soon')),
                  );
                },
              ),
              _buildSettingTile(
                icon: Icons.info_outline,
                title: 'About',
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'CNT Media Platform',
                    applicationVersion: '1.0.0',
                    applicationLegalese: '© 2024 Christ New Tabernacle',
                  );
                },
              ),

              const SizedBox(height: AppSpacing.small),

              _buildSettingTile(
                icon: Icons.logout,
                title: 'Logout',
                titleColor: AppColors.errorMain,
                onTap: () {
                  provider.clearUser();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Logged out')),
                  );
                },
              ),

              const SizedBox(height: AppSpacing.extraLarge),
            ],
          );
        },
      ),
    );
  }

  String _formatMemberSince(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return FormatUtils.formatRelativeTime(date);
    } catch (e) {
      return 'Recently';
    }
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: AppSpacing.small,
        horizontal: AppSpacing.tiny,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryMain.withOpacity(0.12),
                  AppColors.accentMain.withOpacity(0.12),
                ],
              ),
              border: Border.all(
                color: AppColors.primaryMain.withOpacity(0.25),
                width: 2,
              ),
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 22, color: AppColors.primaryMain),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: AppTypography.heading4.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.small),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
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
