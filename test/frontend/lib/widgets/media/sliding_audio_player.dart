import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/audio_player_provider.dart';
import '../../models/content_item.dart';
import '../../theme/app_colors.dart';
import '../../widgets/audio/vinyl_disc.dart';

/// Sliding Audio Player - Slides up from bottom with vinyl disc
class SlidingAudioPlayer extends StatefulWidget {
  const SlidingAudioPlayer({super.key});

  @override
  State<SlidingAudioPlayer> createState() => SlidingAudioPlayerState();
}

/// Public state class for GlobalKey access
class SlidingAudioPlayerState extends State<SlidingAudioPlayer> with SingleTickerProviderStateMixin {
  bool _isExpanded = false; // Start minimized - user taps to expand
  ContentItem? _lastTrackId; // Track the current track to detect changes
  
  // Expose state for external access (used by GlobalKey)
  bool get isExpanded => _isExpanded;
  
  // ValueNotifier to notify parent of state changes
  static final ValueNotifier<bool> expansionStateNotifier = ValueNotifier<bool>(false);
  
  @override
  void initState() {
    super.initState();
    expansionStateNotifier.value = _isExpanded;
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final audioPlayer = Provider.of<AudioPlayerState>(context, listen: false);
    
    // Handle track becoming null (stopped/cleared)
    if (audioPlayer.currentTrack == null && _lastTrackId != null) {
      // Track was cleared - reset expansion state immediately
      _lastTrackId = null;
      if (_isExpanded && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _isExpanded = false;
              expansionStateNotifier.value = _isExpanded;
            });
          }
        });
      }
      return;
    }
    
    // Handle new track playing
    if (audioPlayer.currentTrack != null && audioPlayer.currentTrack != _lastTrackId) {
      // New track detected - ensure minimized
      _lastTrackId = audioPlayer.currentTrack;
      if (_isExpanded && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _isExpanded = false;
              expansionStateNotifier.value = _isExpanded;
            });
          }
        });
      }
    }
  }
  
  void minimizePlayer() {
    if (_isExpanded) {
      setState(() {
        _isExpanded = false;
        expansionStateNotifier.value = _isExpanded;
      });
    }
  }
  
  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      expansionStateNotifier.value = _isExpanded;
    });
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final audioPlayer = Provider.of<AudioPlayerState>(context);

    // Don't show anything if no track is playing
    if (audioPlayer.currentTrack == null) {
      // Reset expansion state if it was expanded to ensure clean hide
      if (_isExpanded && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _isExpanded = false;
              expansionStateNotifier.value = _isExpanded;
              _lastTrackId = null;
            });
          }
        });
      }
      return const SizedBox.shrink();
    }

    final track = audioPlayer.currentTrack!;
    final screenHeight = MediaQuery.of(context).size.height;

    // Update last track reference
    if (_lastTrackId != track) {
      _lastTrackId = track;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
      height: _isExpanded ? screenHeight : 80,
      width: double.infinity,
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryMain, AppColors.accentMain],
        ),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(_isExpanded ? 0 : 12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(_isExpanded ? 0 : 12),
        ),
        child: _isExpanded 
            ? _buildExpandedPlayer(context, audioPlayer, track) 
            : _buildMinimizedPlayer(context, audioPlayer, track),
      ),
    );
  }

  Widget _buildMinimizedPlayer(BuildContext context, AudioPlayerState audioPlayer, track) {
    return GestureDetector(
      onTap: _toggleExpanded,
      child: Container(
        height: 80,
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        alignment: Alignment.center,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
          // Album Art
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: track.coverImage != null
                ? Image.network(
                    track.coverImage!,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 56,
                        height: 56,
                        color: Colors.grey[300],
                        child: const Icon(Icons.music_note, color: Colors.grey),
                      );
                    },
                  )
                : Container(
                    width: 56,
                    height: 56,
                    color: Colors.grey[300],
                    child: const Icon(Icons.music_note, color: Colors.grey),
                  ),
          ),
          const SizedBox(width: 12),
          
          // Track Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  track.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  track.creator,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 4),
          
          // Previous Button
          IconButton(
            icon: const Icon(Icons.skip_previous, color: Colors.white),
            iconSize: 24,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => audioPlayer.previous(),
          ),
          
          // Play/Pause Button
          IconButton(
            icon: Icon(
              audioPlayer.isPlaying ? Icons.pause_circle : Icons.play_circle,
              size: 36,
              color: Colors.white,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => audioPlayer.togglePlayPause(),
          ),
          
          // Next Button
          IconButton(
            icon: const Icon(Icons.skip_next, color: Colors.white),
            iconSize: 24,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => audioPlayer.next(),
          ),
          
          // Close Button
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            iconSize: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () async {
              await audioPlayer.stop();
            },
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildExpandedPlayer(BuildContext context, AudioPlayerState audioPlayer, track) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Minimize button
              IconButton(
                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                onPressed: _toggleExpanded,
              ),
              
              // Donate button
              Flexible(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Thank you for your support!')),
                    );
                  },
                  icon: const Icon(Icons.favorite, size: 20),
                  label: const Text('Donate'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.3),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              
              // Close button
              IconButton(
                icon: const Icon(Icons.close),
                color: Colors.white,
                onPressed: () async {
                  await audioPlayer.stop();
                },
              ),
            ],
          ),
        ),

        // Vinyl Disc - Center of Screen
        Expanded(
          child: Center(
            child: VinylDisc(
              size: 220,
              artist: track.creator,
              isPlaying: audioPlayer.isPlaying,
            ),
          ),
        ),

        // Track Info
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                track.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                track.creator,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white.withOpacity(0.9),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                track.description ?? '',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),

        // Progress Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Slider(
                value: audioPlayer.duration.inSeconds > 0
                    ? audioPlayer.position.inSeconds / audioPlayer.duration.inSeconds
                    : 0.0,
                min: 0.0,
                max: 1.0,
                activeColor: Colors.white,
                inactiveColor: Colors.white.withOpacity(0.3),
                onChanged: (value) {
                  final newPosition = Duration(
                    seconds: (value * audioPlayer.duration.inSeconds).toInt(),
                  );
                  audioPlayer.seek(newPosition);
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDuration(audioPlayer.position),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    _formatDuration(audioPlayer.duration),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),

        // Controls
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Shuffle
              IconButton(
                icon: Icon(
                  Icons.shuffle,
                  color: Colors.white.withOpacity(0.7),
                ),
                iconSize: 24,
                onPressed: () {},
              ),

              // Previous
              IconButton(
                icon: const Icon(Icons.skip_previous, color: Colors.white),
                iconSize: 32,
                onPressed: () => audioPlayer.previous(),
              ),

              // Play/Pause
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
                    audioPlayer.isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 48,
                  ),
                  onPressed: () => audioPlayer.togglePlayPause(),
                ),
              ),

              // Next
              IconButton(
                icon: const Icon(Icons.skip_next, color: Colors.white),
                iconSize: 32,
                onPressed: () => audioPlayer.next(),
              ),

              // Repeat
              IconButton(
                icon: Icon(
                  Icons.repeat,
                  color: Colors.white.withOpacity(0.7),
                ),
                iconSize: 24,
                onPressed: () {},
              ),
            ],
          ),
        ),

        // Bottom spacing
        const SizedBox(height: 32),
      ],
    );
  }
}


