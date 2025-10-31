import 'package:flutter/material.dart';
import 'dart:io';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../services/video_editing_service.dart';
import 'package:video_player/video_player.dart';
import 'package:file_picker/file_picker.dart';

/// Video Editor Screen
/// Allows users to edit video: trim, add/remove audio, apply filters
class VideoEditorScreen extends StatefulWidget {
  final String videoPath;
  final String? title;

  const VideoEditorScreen({
    super.key,
    required this.videoPath,
    this.title,
  });

  @override
  State<VideoEditorScreen> createState() => _VideoEditorScreenState();
}

class _VideoEditorScreenState extends State<VideoEditorScreen> {
  VideoPlayerController? _controller;
  final VideoEditingService _editingService = VideoEditingService();
  
  bool _isInitializing = true;
  bool _isEditing = false;
  bool _hasError = false;
  String? _errorMessage;
  
  Duration _videoDuration = Duration.zero;
  Duration _trimStart = Duration.zero;
  Duration _trimEnd = Duration.zero;
  
  bool _audioRemoved = false;
  String? _audioFilePath;
  
  // Filter values: -1.0 to 1.0 for brightness, 0.0 to 2.0 for contrast, 0.0 to 3.0 for saturation
  double _brightness = 0.0;
  double _contrast = 1.0;
  double _saturation = 1.0;
  
  String? _editedVideoPath;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      // Check if path is network or local file
      final isNetwork = widget.videoPath.startsWith('http');
      
      if (isNetwork) {
        _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoPath));
      } else {
        _controller = VideoPlayerController.file(File(widget.videoPath));
      }
      
      await _controller!.initialize();
      
      setState(() {
        _isInitializing = false;
        _videoDuration = _controller!.value.duration;
        _trimEnd = _videoDuration;
      });
    } catch (e) {
      setState(() {
        _isInitializing = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _applyTrim() async {
    if (_trimStart >= _trimEnd) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Start time must be less than end time')),
      );
      return;
    }

    setState(() {
      _isEditing = true;
      _hasError = false;
    });

    final outputPath = await _editingService.trimVideo(
      widget.videoPath,
      _trimStart,
      _trimEnd,
      onProgress: (progress) {
        // Progress callback
      },
      onError: (error) {
        setState(() {
          _isEditing = false;
          _hasError = true;
          _errorMessage = error;
        });
      },
    );

    if (outputPath != null) {
      setState(() {
        _editedVideoPath = outputPath;
        _isEditing = false;
      });
      // Reload player with edited video
      await _reloadPlayer(outputPath);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Video trimmed successfully')),
      );
    }
  }

  Future<void> _removeAudio() async {
    final inputPath = _editedVideoPath ?? widget.videoPath;
    
    setState(() {
      _isEditing = true;
      _hasError = false;
    });

    final outputPath = await _editingService.removeAudioTrack(
      inputPath,
      onProgress: (progress) {},
      onError: (error) {
        setState(() {
          _isEditing = false;
          _hasError = true;
          _errorMessage = error;
        });
      },
    );

    if (outputPath != null) {
      setState(() {
        _editedVideoPath = outputPath;
        _audioRemoved = true;
        _isEditing = false;
      });
      await _reloadPlayer(outputPath);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Audio removed successfully')),
      );
    }
  }

  Future<void> _selectAudioFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final audioPath = result.files.single.path!;
        await _addAudioTrack(audioPath);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting audio file: $e')),
      );
    }
  }

  Future<void> _addAudioTrack(String audioPath) async {
    final inputPath = _editedVideoPath ?? widget.videoPath;
    
    setState(() {
      _isEditing = true;
      _hasError = false;
    });

    final outputPath = await _editingService.addAudioTrack(
      inputPath,
      audioPath,
      onProgress: (progress) {},
      onError: (error) {
        setState(() {
          _isEditing = false;
          _hasError = true;
          _errorMessage = error;
        });
      },
    );

    if (outputPath != null) {
      setState(() {
        _editedVideoPath = outputPath;
        _audioFilePath = audioPath;
        _audioRemoved = false;
        _isEditing = false;
      });
      await _reloadPlayer(outputPath);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Audio track added successfully')),
      );
    }
  }

  Future<void> _applyFilters() async {
    final inputPath = _editedVideoPath ?? widget.videoPath;
    
    // Check if filters are different from defaults
    if (_brightness == 0.0 && _contrast == 1.0 && _saturation == 1.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No filters to apply')),
      );
      return;
    }

    setState(() {
      _isEditing = true;
      _hasError = false;
    });

    final filters = <String, double>{};
    if (_brightness != 0.0) filters['brightness'] = _brightness;
    if (_contrast != 1.0) filters['contrast'] = _contrast;
    if (_saturation != 1.0) filters['saturation'] = _saturation;

    final outputPath = await _editingService.applyFilters(
      inputPath,
      filters,
      onProgress: (progress) {},
      onError: (error) {
        setState(() {
          _isEditing = false;
          _hasError = true;
          _errorMessage = error;
        });
      },
    );

    if (outputPath != null) {
      setState(() {
        _editedVideoPath = outputPath;
        _isEditing = false;
      });
      await _reloadPlayer(outputPath);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Filters applied successfully')),
      );
    }
  }

  Future<void> _reloadPlayer(String path) async {
    await _controller?.dispose();
    _controller = VideoPlayerController.file(File(path));
    await _controller!.initialize();
    setState(() {});
  }

  void _handleExport() {
    if (_editedVideoPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No edits to export')),
      );
      return;
    }

    // Return edited video path to caller
    Navigator.pop(context, _editedVideoPath);
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
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
          'Edit Video',
          style: AppTypography.heading3.copyWith(color: AppColors.textPrimary),
        ),
        actions: [
          if (_editedVideoPath != null)
            TextButton(
              onPressed: _handleExport,
              child: Text(
                'Export',
                style: AppTypography.body.copyWith(
                  color: AppColors.primaryMain,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const SizedBox(width: 16),
        ],
      ),
      body: _isInitializing
          ? const Center(child: CircularProgressIndicator())
          : _hasError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: AppColors.errorMain),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading video',
                        style: AppTypography.heading4.copyWith(color: AppColors.textPrimary),
                      ),
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            _errorMessage!,
                            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      // Video Preview
                      Container(
                        height: 300,
                        color: Colors.black,
                        child: _controller != null && _controller!.value.isInitialized
                            ? AspectRatio(
                                aspectRatio: _controller!.value.aspectRatio,
                                child: VideoPlayer(_controller!),
                              )
                            : const Center(
                                child: CircularProgressIndicator(color: Colors.white),
                              ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.large),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Trim Section
                            Text(
                              'Trim Video',
                              style: AppTypography.heading4.copyWith(color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: AppSpacing.medium),
                            
                            // Trim Start
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Start: ${_formatDuration(_trimStart)}',
                                        style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                                      ),
                                      Slider(
                                        value: _trimStart.inSeconds.toDouble(),
                                        min: 0,
                                        max: _videoDuration.inSeconds.toDouble(),
                                        onChanged: (value) {
                                          setState(() {
                                            _trimStart = Duration(seconds: value.toInt());
                                            if (_trimStart >= _trimEnd) {
                                              _trimEnd = Duration(seconds: (value + 1).toInt());
                                            }
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            
                            // Trim End
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'End: ${_formatDuration(_trimEnd)}',
                                        style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                                      ),
                                      Slider(
                                        value: _trimEnd.inSeconds.toDouble(),
                                        min: 0,
                                        max: _videoDuration.inSeconds.toDouble(),
                                        onChanged: (value) {
                                          setState(() {
                                            _trimEnd = Duration(seconds: value.toInt());
                                            if (_trimEnd <= _trimStart) {
                                              _trimStart = Duration(seconds: (value - 1).toInt());
                                            }
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            
                            ElevatedButton.icon(
                              onPressed: _isEditing ? null : _applyTrim,
                              icon: _isEditing
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Icon(Icons.content_cut),
                              label: Text(_isEditing ? 'Trimming...' : 'Apply Trim'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryMain,
                                foregroundColor: Colors.white,
                              ),
                            ),

                            const SizedBox(height: AppSpacing.extraLarge),

                            // Audio Track Section
                            Text(
                              'Audio Track',
                              style: AppTypography.heading4.copyWith(color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: AppSpacing.medium),
                            
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _isEditing || _audioRemoved ? null : _removeAudio,
                                    icon: const Icon(Icons.volume_off),
                                    label: const Text('Remove Audio'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.errorMain,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.medium),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _isEditing ? null : _selectAudioFile,
                                    icon: const Icon(Icons.volume_up),
                                    label: const Text('Add Audio'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryMain,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: AppSpacing.extraLarge),

                            // Filters Section
                            Text(
                              'Filters',
                              style: AppTypography.heading4.copyWith(color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: AppSpacing.medium),
                            
                            // Brightness
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Brightness: ${_brightness.toStringAsFixed(2)}',
                                  style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                                ),
                                Slider(
                                  value: _brightness,
                                  min: -1.0,
                                  max: 1.0,
                                  divisions: 40,
                                  onChanged: (value) {
                                    setState(() {
                                      _brightness = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                            
                            // Contrast
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Contrast: ${_contrast.toStringAsFixed(2)}',
                                  style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                                ),
                                Slider(
                                  value: _contrast,
                                  min: 0.0,
                                  max: 2.0,
                                  divisions: 40,
                                  onChanged: (value) {
                                    setState(() {
                                      _contrast = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                            
                            // Saturation
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Saturation: ${_saturation.toStringAsFixed(2)}',
                                  style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                                ),
                                Slider(
                                  value: _saturation,
                                  min: 0.0,
                                  max: 3.0,
                                  divisions: 40,
                                  onChanged: (value) {
                                    setState(() {
                                      _saturation = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                            
                            ElevatedButton.icon(
                              onPressed: _isEditing ? null : _applyFilters,
                              icon: _isEditing
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Icon(Icons.filter),
                              label: Text(_isEditing ? 'Applying...' : 'Apply Filters'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryMain,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

