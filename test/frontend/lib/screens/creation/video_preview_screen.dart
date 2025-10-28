import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

/// Video Preview Screen
/// Shows recorded/uploaded video with playback and controls
class VideoPreviewScreen extends StatefulWidget {
  final String videoUri;
  final String source; // 'camera' or 'gallery'
  final int duration;
  final int fileSize;

  const VideoPreviewScreen({
    super.key,
    required this.videoUri,
    required this.source,
    this.duration = 0,
    this.fileSize = 0,
  });

  @override
  State<VideoPreviewScreen> createState() => _VideoPreviewScreenState();
}

class _VideoPreviewScreenState extends State<VideoPreviewScreen> {
  bool _isPlaying = false;
  int _currentTime = 0;
  bool _isLoading = false;

  void _handleBack() {
    Navigator.pop(context);
  }

  void _handlePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  void _handleEdit() {
    // TODO: Navigate to VideoEditorScreen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigate to Video Editor')),
    );
  }

  void _handleAddCaptions() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add captions feature')),
    );
  }

  void _handleDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Video'),
        content: const Text('Are you sure you want to delete this video? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _handlePublish() {
    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Video Published'),
          content: const Text('Your video podcast has been published and shared with the community!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Navigate to home
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    });
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins}:${secs.toString().padLeft(2, '0')}';
  }

  String _formatFileSize(int bytes) {
    if (bytes == 0) return '0 Bytes';
    final k = 1024;
    final sizes = ['Bytes', 'KB', 'MB', 'GB'];
    final i = (bytes / k).floor();
    return '${(bytes / (k * i)).toStringAsFixed(2)} ${sizes[i]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _handleBack,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
          onPressed: _handleDelete,
        ),
        ],
      ),
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
        child: Column(
          children: [
            // Video Player
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(AppSpacing.large),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Video placeholder
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.videocam,
                            size: 80,
                            color: Colors.white.withOpacity(0.5),
                          ),
                          const SizedBox(height: AppSpacing.medium),
                          Text(
                            'Video Preview',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Play button overlay
                    if (!_isPlaying)
                      GestureDetector(
                        onTap: _handlePlayPause,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.play_arrow,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Progress Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.large),
              child: Row(
                children: [
                  SizedBox(
                    width: 50,
                    child: Text(
                      _formatTime(_currentTime),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                  Expanded(
                    child: Slider(
                      value: _currentTime.toDouble(),
                      min: 0,
                      max: widget.duration.toDouble(),
                      activeColor: Colors.white,
                      inactiveColor: Colors.white.withOpacity(0.3),
                      onChanged: (value) {
                        setState(() {
                          _currentTime = value.toInt();
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    width: 50,
                    child: Text(
                      _formatTime(widget.duration),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),

            // Video Info
            Container(
              margin: const EdgeInsets.all(AppSpacing.large),
              padding: const EdgeInsets.all(AppSpacing.medium),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildInfoRow(Icons.info, 'Source: ${widget.source == 'camera' ? 'Camera Recording' : 'Gallery'}'),
                  _buildInfoRow(Icons.schedule, 'Duration: ${_formatTime(widget.duration)}'),
                  _buildInfoRow(Icons.storage, 'Size: ${_formatFileSize(widget.fileSize)}'),
                ],
              ),
            ),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.all(AppSpacing.large),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildActionButton(
                    icon: Icons.edit,
                    label: 'Edit',
                    onPressed: _handleEdit,
                  ),
                  _buildActionButton(
                    icon: Icons.closed_caption,
                    label: 'Captions',
                    onPressed: _handleAddCaptions,
                  ),
                  _buildActionButton(
                    icon: Icons.publish,
                    label: _isLoading ? 'Publishing...' : 'Publish',
                    onPressed: _isLoading ? null : _handlePublish,
                    isPrimary: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.large),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.tiny),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.white),
          const SizedBox(width: AppSpacing.small),
          Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    VoidCallback? onPressed,
    bool isPrimary = false,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.medium),
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.small),
          decoration: BoxDecoration(
            color: isPrimary ? Colors.white.withOpacity(0.25) : Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(width: AppSpacing.tiny),
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

