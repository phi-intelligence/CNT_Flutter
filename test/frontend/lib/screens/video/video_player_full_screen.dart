import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

/// Video Player Full Screen - Exact replica of React Native implementation
/// Features auto-hiding controls, fullscreen toggle, and gradient background
class VideoPlayerFullScreen extends StatefulWidget {
  final String videoId;
  final String title;
  final String author;
  final int duration;
  final List<Color> gradientColors;
  final bool isFavorite;
  final String videoUrl;
  final VoidCallback? onBack;
  final VoidCallback? onDonate;
  final VoidCallback? onFavorite;
  final void Function(int) onSeek;

  const VideoPlayerFullScreen({
    super.key,
    required this.videoId,
    required this.title,
    required this.author,
    required this.duration,
    required this.gradientColors,
    required this.videoUrl,
    this.isFavorite = false,
    this.onBack,
    this.onDonate,
    this.onFavorite,
    required this.onSeek,
  });

  @override
  State<VideoPlayerFullScreen> createState() => _VideoPlayerFullScreenState();
}

class _VideoPlayerFullScreenState extends State<VideoPlayerFullScreen> {
  VideoPlayerController? _controller;
  bool _isInitializing = true;
  bool _hasError = false;
  bool _isFullscreen = false;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
    _startControlsTimer();
  }

  Future<void> _initializePlayer() async {
    try {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
      await _controller!.initialize();
      await _controller!.play();
      
      _controller!.addListener(_videoListener);
      
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _hasError = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _hasError = true;
        });
      }
    }
  }

  void _videoListener() {
    if (mounted && _controller != null) {
      setState(() {
        // Update current time for seek callback
        final position = _controller!.value.position;
        widget.onSeek(position.inSeconds);
      });
    }
  }

  void _startControlsTimer() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _controller != null && _controller!.value.isPlaying) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _startControlsTimer();
    }
  }

  Future<void> _togglePlayPause() async {
    if (_controller == null) return;
    
    if (_controller!.value.isPlaying) {
      await _controller!.pause();
    } else {
      await _controller!.play();
    }
    setState(() {
      _showControls = true;
    });
    _startControlsTimer();
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(1, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _controller?.removeListener(_videoListener);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: _isFullscreen
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.black, Colors.black],
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: widget.gradientColors,
                ),
        ),
        child: Stack(
          children: [
            // Top Bar (hidden in fullscreen)
            if (!_isFullscreen)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Container(
                    padding: EdgeInsets.all(AppSpacing.medium),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          color: Colors.white,
                          onPressed: widget.onBack,
                        ),
                        Text(
                          'Video Podcast',
                          style: AppTypography.heading4.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: widget.onDonate,
                              icon: const Icon(Icons.favorite, size: 20),
                              label: const Text('Donate'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black.withOpacity(0.3),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppSpacing.small,
                                  vertical: AppSpacing.tiny,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                widget.isFavorite ? Icons.favorite : Icons.favorite_border,
                              ),
                              color: Colors.white,
                              onPressed: widget.onFavorite,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Video Container
            Center(
              child: GestureDetector(
                onTap: _toggleControls,
                child: Container(
                  width: double.infinity,
                  height: _isFullscreen
                      ? MediaQuery.of(context).size.height
                      : MediaQuery.of(context).size.height * 0.5,
                  color: Colors.black,
                  child: Stack(
                    children: [
                      // Video Player
                      if (_isInitializing)
                        const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      else if (_hasError)
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 80,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Error loading video',
                                style: TextStyle(color: Colors.white, fontSize: 18),
                              ),
                            ],
                          ),
                        )
                      else if (_controller != null && _controller!.value.isInitialized)
                        Positioned.fill(
                          child: Center(
                            child: AspectRatio(
                              aspectRatio: _controller!.value.aspectRatio,
                              child: VideoPlayer(_controller!),
                            ),
                          ),
                        ),

                      // Play/Pause Overlay
                      if (!_isInitializing && !_hasError && _controller != null && !_controller!.value.isPlaying)
                        Positioned.fill(
                          child: Center(
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.2),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.5),
                                  width: 2,
                                ),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.play_arrow),
                                iconSize: 64,
                                color: Colors.white,
                                onPressed: _togglePlayPause,
                              ),
                            ),
                          ),
                        ),

                      // Auto-hiding Controls
                      AnimatedOpacity(
                        opacity: _showControls ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: _isFullscreen
                            ? Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: EdgeInsets.all(AppSpacing.large),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withOpacity(0.7),
                                      ],
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.arrow_back),
                                            color: Colors.white,
                                            onPressed: () {
                                              setState(() {
                                                _isFullscreen = false;
                                              });
                                              _toggleControls();
                                            },
                                          ),
                                          const SizedBox(width: AppSpacing.small),
                                          Expanded(
                                            child: Slider(
                                              value: _currentTime.toDouble(),
                                              min: 0.0,
                                              max: widget.duration.toDouble(),
                                              activeColor: Colors.white,
                                              inactiveColor: Colors.white.withOpacity(0.3),
                                              onChanged: (value) {
                                                setState(() {
                                                  _currentTime = value.toInt();
                                                });
                                                widget.onSeek(_currentTime);
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: AppSpacing.small),
                                          IconButton(
                                            icon: Icon(
                                              _isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                                            ),
                                            color: Colors.white,
                                            onPressed: () {
                                              setState(() {
                                                _isFullscreen = !_isFullscreen;
                                              });
                                              _toggleControls();
                                            },
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            _formatTime(_currentTime),
                                            style: AppTypography.caption.copyWith(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                          ),
                                          Text(
                                            _formatTime(widget.duration),
                                            style: AppTypography.caption.copyWith(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: AppSpacing.large),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.skip_previous),
                                            color: Colors.white,
                                            iconSize: 32,
                                            onPressed: () {},
                                          ),
                                          Container(
                                            width: 64,
                                            height: 64,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white.withOpacity(0.2),
                                              border: Border.all(
                                                color: Colors.white.withOpacity(0.4),
                                                width: 2,
                                              ),
                                            ),
                                            child: IconButton(
                                              icon: Icon(
                                                _controller != null && _controller!.value.isPlaying
                                                    ? Icons.pause
                                                    : Icons.play_arrow,
                                                color: Colors.white,
                                                size: 48,
                                              ),
                                              onPressed: _togglePlayPause,
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.skip_next),
                                            color: Colors.white,
                                            iconSize: 32,
                                            onPressed: () {},
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: EdgeInsets.all(AppSpacing.large),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Slider(
                                              value: _currentTime.toDouble(),
                                              min: 0.0,
                                              max: widget.duration.toDouble(),
                                              activeColor: Colors.white,
                                              inactiveColor: Colors.white.withOpacity(0.3),
                                              onChanged: (value) {
                                                setState(() {
                                                  _currentTime = value.toInt();
                                                });
                                                widget.onSeek(_currentTime);
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: AppSpacing.small),
                                          IconButton(
                                            icon: Icon(
                                              _isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                                            ),
                                            color: Colors.white,
                                            onPressed: () {
                                              setState(() {
                                                _isFullscreen = !_isFullscreen;
                                              });
                                              _toggleControls();
                                            },
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            _formatTime(_currentTime),
                                            style: AppTypography.caption.copyWith(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                          ),
                                          Text(
                                            _formatTime(widget.duration),
                                            style: AppTypography.caption.copyWith(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

