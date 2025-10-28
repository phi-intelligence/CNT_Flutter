import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../services/livekit_service.dart';

/// Live Stream Broadcaster Screen - Go live and broadcast
class LiveStreamBroadcaster extends StatefulWidget {
  final String token;
  final String serverUrl;
  final String streamTitle;
  final VoidCallback? onStreamEnded;

  const LiveStreamBroadcaster({
    super.key,
    required this.token,
    required this.serverUrl,
    required this.streamTitle,
    this.onStreamEnded,
  });

  @override
  State<LiveStreamBroadcaster> createState() => _LiveStreamBroadcasterState();
}

class _LiveStreamBroadcasterState extends State<LiveStreamBroadcaster> {
  bool _isStreaming = false;
  bool _isMuted = false;
  bool _isCameraOn = true;
  CameraController? _cameraController;
  final LiveKitService _livekitService = LiveKitService();
  int _viewerCount = 0;
  DateTime? _startTime;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      _cameraController = CameraController(
        cameras.first,
        ResolutionPreset.high,
      );
      await _cameraController!.initialize();
      setState(() {});
    }
  }

  Future<void> _startStreaming() async {
    final success = await _livekitService.connectToRoom(
      url: widget.serverUrl,
      token: widget.token,
    );

    if (success) {
      await _livekitService.setCameraEnabled(true);
      await _livekitService.setMicrophoneEnabled(true);
      
      setState(() {
        _isStreaming = true;
        _startTime = DateTime.now();
      });
      
      _updateViewerCount();
    }
  }

  Future<void> _stopStreaming() async {
    await _livekitService.disconnect();
    setState(() {
      _isStreaming = false;
    });
    if (widget.onStreamEnded != null) {
      widget.onStreamEnded!();
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
    _livekitService.setMicrophoneEnabled(!_isMuted);
  }

  void _toggleCamera() {
    setState(() {
      _isCameraOn = !_isCameraOn;
    });
    _livekitService.setCameraEnabled(_isCameraOn);
  }

  void _flipCamera() {
    _livekitService.flipCamera();
  }

  void _updateViewerCount() {
    if (_isStreaming) {
      setState(() {
        _viewerCount = _livekitService.participantCount;
      });
      Future.delayed(const Duration(seconds: 5), _updateViewerCount);
    }
  }

  String _getStreamingDuration() {
    if (_startTime == null) return '00:00';
    final duration = DateTime.now().difference(_startTime!);
    final mins = duration.inMinutes.toString().padLeft(2, '0');
    final secs = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _livekitService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview
          if (_cameraController?.value.isInitialized == true)
            SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: CameraPreview(_cameraController!),
            )
          else
            Container(
              color: Colors.black,
              child: const Center(child: CircularProgressIndicator(color: Colors.white)),
            ),

          // Top bar with streaming info
          SafeArea(
            child: Container(
              padding: EdgeInsets.all(AppSpacing.medium),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                children: [
                  if (_isStreaming) ...[
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.small,
                        vertical: AppSpacing.tiny,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'LIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.small),
                    const Icon(Icons.remove_red_eye, color: Colors.white70, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '$_viewerCount',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(width: AppSpacing.medium),
                    Text(
                      _getStreamingDuration(),
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ] else ...[
                    Text(
                      widget.streamTitle,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    color: Colors.white,
                    onPressed: _stopStreaming,
                  ),
                ],
              ),
            ),
          ),

          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(AppSpacing.large),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Flip camera
                  IconButton(
                    icon: const Icon(Icons.flip_camera_ios),
                    iconSize: 32,
                    color: Colors.white,
                    onPressed: _flipCamera,
                  ),

                  // Toggle camera
                  IconButton(
                    icon: Icon(_isCameraOn ? Icons.videocam : Icons.videocam_off),
                    iconSize: 32,
                    color: Colors.white,
                    onPressed: _toggleCamera,
                  ),

                  // Start/Stop streaming
                  _isStreaming
                      ? ElevatedButton(
                          onPressed: _stopStreaming,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.all(AppSpacing.medium),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                          child: const Text(
                            'End Stream',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: _startStreaming,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.all(AppSpacing.medium),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                          child: const Text(
                            'Go Live',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),

                  // Toggle mute
                  IconButton(
                    icon: Icon(_isMuted ? Icons.mic_off : Icons.mic),
                    iconSize: 32,
                    color: _isMuted ? Colors.red : Colors.white,
                    onPressed: _toggleMute,
                  ),

                  // More options
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    iconSize: 32,
                    color: Colors.white,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

