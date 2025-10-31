import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import 'video_recording_screen.dart';
import 'video_preview_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

/// Video Podcast Create Screen
/// Shows options to record video or choose from gallery
class VideoPodcastCreateScreen extends StatelessWidget {
  const VideoPodcastCreateScreen({super.key});

  Future<void> _selectVideoFromGallery(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? video = await picker.pickVideo(
        source: ImageSource.gallery,
      );

      if (video != null && context.mounted) {
        final file = File(video.path);
        final fileSize = await file.length();
        
        // Get video duration using video_player (basic estimation)
        // In production, you might want to use FFprobe or similar
        int estimatedDuration = 180; // Default estimate
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VideoPreviewScreen(
              videoUri: video.path,
              source: 'gallery',
              duration: estimatedDuration,
              fileSize: fileSize,
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting video: $e'),
            backgroundColor: AppColors.errorMain,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryMain,
              AppColors.accentMain,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.all(AppSpacing.large),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'Create Video Podcast',
                      style: AppTypography.heading4.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.large),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Record Video Option
                      _buildOptionCard(
                        context,
                        icon: Icons.videocam,
                        title: 'Record Video',
                        description: 'Use your camera to record a new video podcast',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const VideoRecordingScreen(),
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: AppSpacing.medium),
                      
                      // Choose from Gallery Option
                      _buildOptionCard(
                        context,
                        icon: Icons.photo_library,
                        title: 'Choose from Gallery',
                        description: 'Select an existing video from your gallery',
                        onTap: () => _selectVideoFromGallery(context),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.large),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppColors.primaryMain,
                size: 40,
              ),
            ),
            const SizedBox(height: AppSpacing.medium),
            Text(
              title,
              style: AppTypography.heading3.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.small),
            Text(
              description,
              style: AppTypography.body.copyWith(
                color: Colors.white.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

