import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../meeting/meeting_created_screen.dart';
import '../meeting/schedule_meeting_screen.dart';
import '../meeting/join_meeting_screen.dart';

/// Meeting Options Screen
/// Shows options for instant meeting, schedule meeting, or join meeting
class MeetingOptionsScreenMobile extends StatelessWidget {
  const MeetingOptionsScreenMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.all(AppSpacing.large),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      'Meeting Options',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            
            const SizedBox(height: AppSpacing.extraLarge),
            
            // Options Grid
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.large),
                child: Column(
                  children: [
                    // Row 1: Instant Meeting & Schedule Meeting
                    Row(
                      children: [
                        Expanded(
                          child: _buildOptionCard(
                            title: 'Instant Meeting',
                            subtitle: 'Start a meeting right now',
                            icon: Icons.video_call,
                            color: AppColors.primaryMain,
                            onTap: () {
                              // Generate meeting ID and link for instant meeting
                              final meetingId = DateTime.now().millisecondsSinceEpoch.toString().substring(6);
                              final meetingLink = 'https://meet.christtabernacle.com/$meetingId';
                              
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MeetingCreatedScreen(
                                    meetingId: meetingId,
                                    meetingLink: meetingLink,
                                    isInstant: true,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: AppSpacing.medium),
                        Expanded(
                          child: _buildOptionCard(
                            title: 'Schedule Meeting',
                            subtitle: 'Plan a meeting for later',
                            icon: Icons.schedule,
                            color: AppColors.accentMain,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ScheduleMeetingScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: AppSpacing.large),
                    
                    // Row 2: Join Meeting
                    _buildOptionCard(
                      title: 'Join Meeting',
                      subtitle: 'Enter meeting ID or link',
                      icon: Icons.login,
                      color: AppColors.secondaryMain,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const JoinMeetingScreen(),
                          ),
                        );
                      },
                      isFullWidth: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard({
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
        padding: EdgeInsets.all(AppSpacing.extraLarge),
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
          children: [
            Container(
              width: 80,
              height: 80,
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
                size: 40,
              ),
            ),
            const SizedBox(height: AppSpacing.medium),
            Text(
              title,
              style: AppTypography.heading4.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.tiny),
            Text(
              subtitle,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

