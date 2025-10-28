import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

/// Audio Preview Screen
/// Shows recorded/uploaded audio with playback and metadata form
class AudioPreviewScreen extends StatefulWidget {
  final String audioUri;
  final String source; // 'recording' or 'file'
  final int duration;
  final int fileSize;

  const AudioPreviewScreen({
    super.key,
    required this.audioUri,
    required this.source,
    this.duration = 0,
    this.fileSize = 0,
  });

  @override
  State<AudioPreviewScreen> createState() => _AudioPreviewScreenState();
}

class _AudioPreviewScreenState extends State<AudioPreviewScreen> {
  bool _isPlaying = false;
  int _currentTime = 0;
  bool _isLoading = false;

  final TextEditingController _titleController = TextEditingController(text: 'My Audio Podcast');
  final TextEditingController _descriptionController = TextEditingController(text: 'A wonderful audio podcast about faith and spirituality');
  final TextEditingController _tagsController = TextEditingController(text: 'podcast, faith, spirituality');

  void _handleBack() {
    Navigator.pop(context);
  }

  void _handlePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
    // TODO: Implement actual audio playback
  }

  void _handleEdit() {
    // TODO: Navigate to AudioEditorScreen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigate to Audio Editor')),
    );
  }

  void _handleAddCaptions() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add captions feature')),
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
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Audio podcast published successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Navigate to home
      Navigator.of(context).popUntil((route) => route.isFirst);
    });
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins}:${secs.toString().padLeft(2, '0')}';
  }

  String _formatFileSize(int bytes) {
    if (bytes == 0) return '0 B';
    final k = 1024;
    final sizes = ['B', 'KB', 'MB', 'GB'];
    final i = (bytes / k).floor();
    return '${(bytes / (k * i)).toStringAsFixed(2)} ${sizes[i]}';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
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
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.large),
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.extraLarge),
                  
                  // Action buttons at top
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionButton(
                        icon: Icons.edit,
                        label: 'Edit Audio',
                        onPressed: _handleEdit,
                      ),
                      _buildActionButton(
                        icon: Icons.closed_caption,
                        label: 'Add Captions',
                        onPressed: _handleAddCaptions,
                      ),
                      _buildActionButton(
                        icon: Icons.publish,
                        label: _isLoading ? 'Publishing...' : 'Publish',
                        onPressed: _isLoading ? null : _handlePublish,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: AppSpacing.extraLarge),

                  // Audio Player Section
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.extraLarge),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        // Audio Icon
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.audiotrack,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.medium),
                        Text(
                          'Audio Podcast',
                          style: AppTypography.heading3.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: AppSpacing.tiny),
                        Text(
                          '${_formatTime(widget.duration)} • ${_formatFileSize(widget.fileSize)}',
                          style: AppTypography.body.copyWith(color: Colors.white.withOpacity(0.8)),
                        ),
                        const SizedBox(height: AppSpacing.large),

                        // Play Button
                        GestureDetector(
                          onTap: _handlePlayPause,
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _isPlaying ? Icons.pause : Icons.play_arrow,
                              size: 32,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.medium),

                        // Progress Bar
                        Row(
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
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.large),

                  // Metadata Form
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.large),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Podcast Details',
                          style: AppTypography.heading3.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: AppSpacing.large),
                        
                        // Title
                        _buildTextField(
                          label: 'Title',
                          controller: _titleController,
                          hint: 'Enter podcast title',
                        ),
                        const SizedBox(height: AppSpacing.medium),
                        
                        // Description
                        _buildTextField(
                          label: 'Description',
                          controller: _descriptionController,
                          hint: 'Enter podcast description',
                          maxLines: 3,
                        ),
                        const SizedBox(height: AppSpacing.medium),
                        
                        // Tags
                        _buildTextField(
                          label: 'Tags',
                          controller: _tagsController,
                          hint: 'Enter tags (comma separated)',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.extraLarge),

                  // Loading Overlay
                  if (_isLoading)
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.extraLarge),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.publish, size: 32, color: Colors.white),
                          SizedBox(height: AppSpacing.medium),
                          Text(
                            'Publishing your podcast...',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
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

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    VoidCallback? onPressed,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.medium),
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.small),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(height: AppSpacing.tiny),
              Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: AppSpacing.tiny),
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(AppSpacing.medium),
          ),
        ),
      ],
    );
  }
}

