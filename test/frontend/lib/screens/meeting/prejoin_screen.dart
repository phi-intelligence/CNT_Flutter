import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../services/jitsi_service.dart';

/// Prejoin Screen - Device check before joining meeting
/// Jitsi handles camera/mic preview internally, so this is simplified
class PrejoinScreen extends StatefulWidget {
  final String meetingId;
  final String jitsiUrl;
  final String jwtToken;
  final String roomName;
  final String userName;
  final bool isHost;

  const PrejoinScreen({
    super.key,
    required this.meetingId,
    required this.jitsiUrl,
    required this.jwtToken,
    required this.roomName,
    required this.userName,
    this.isHost = false,
  });

  @override
  State<PrejoinScreen> createState() => _PrejoinScreenState();
}

class _PrejoinScreenState extends State<PrejoinScreen> {
  bool cameraEnabled = true;
  bool micEnabled = true;

  void _onJoin() {
    // Join Jitsi conference directly
    JitsiService().joinConference(
      roomName: widget.roomName,
      jwtToken: widget.jwtToken,
      displayName: widget.userName,
      audioMuted: !micEnabled,
      videoMuted: !cameraEnabled,
      isModerator: widget.isHost,
    ).then((_) {
      // Jitsi handles the meeting UI, so we can pop back when done
      // The meeting will close automatically when user leaves
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst || route.settings.name == '/');
      }
    }).catchError((error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to join meeting: $error')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Check Your Setup',
          style: AppTypography.heading3.copyWith(color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
              child: Column(
                children: [
            const SizedBox(height: AppSpacing.extraLarge),
            // Preview placeholder
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                border: Border.all(color: AppColors.borderPrimary),
              ),
                      alignment: Alignment.center,
              child: cameraEnabled
                  ? Icon(Icons.videocam, size: 80, color: AppColors.primaryMain)
                  : Icon(Icons.videocam_off, size: 80, color: AppColors.textSecondary),
                  ),
            const SizedBox(height: AppSpacing.extraLarge),
            Text(
              'Room: ${widget.roomName}',
              style: AppTypography.body.copyWith(color: AppColors.textSecondary),
                  ),
            const SizedBox(height: AppSpacing.medium),
            // Camera toggle
            ListTile(
              leading: Icon(
                cameraEnabled ? Icons.videocam : Icons.videocam_off,
                color: cameraEnabled ? AppColors.primaryMain : AppColors.textSecondary,
              ),
              title: Text(
                cameraEnabled ? 'Camera On' : 'Camera Off',
                style: AppTypography.body.copyWith(color: AppColors.textPrimary),
              ),
              trailing: Switch(
                value: cameraEnabled,
                onChanged: (value) {
                  setState(() {
                    cameraEnabled = value;
                  });
                },
              ),
            ),
            // Microphone toggle
            ListTile(
              leading: Icon(
                micEnabled ? Icons.mic : Icons.mic_off,
                color: micEnabled ? AppColors.primaryMain : AppColors.textSecondary,
              ),
              title: Text(
                micEnabled ? 'Microphone On' : 'Microphone Off',
                style: AppTypography.body.copyWith(color: AppColors.textPrimary),
              ),
              trailing: Switch(
                value: micEnabled,
                onChanged: (value) {
                  setState(() {
                    micEnabled = value;
                  });
                        },
                      ),
                  ),
            const Spacer(),
            // Join button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                icon: const Icon(Icons.meeting_room, color: Colors.white),
                label: const Text(
                  'Join Meeting',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
                ),
                      onPressed: _onJoin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryMain,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.large),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                  ),
                ),
                    ),
            ),
            const SizedBox(height: AppSpacing.medium),
                ],
              ),
            ),
    );
  }
}
