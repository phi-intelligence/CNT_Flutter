import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/audio_player_provider.dart';

class GlobalAudioPlayer extends StatelessWidget {
  const GlobalAudioPlayer({super.key});

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final audioPlayer = Provider.of<AudioPlayerState>(context);

    // Only show player if there's a current track
    if (audioPlayer.currentTrack == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Album Art
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: (audioPlayer.currentTrack!.coverImage != null)
              ? Image.network(
                  audioPlayer.currentTrack!.coverImage!,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 56,
                      height: 56,
                      color: Colors.grey[300],
                      child: Icon(Icons.music_note, color: Colors.grey[600]),
                    );
                  },
                )
              : Container(
                  width: 56,
                  height: 56,
                  color: Colors.grey[300],
                  child: Icon(Icons.music_note, color: Colors.grey[600]),
                ),
          ),
          const SizedBox(width: 16),
          
          // Track Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  audioPlayer.currentTrack!.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  audioPlayer.currentTrack!.creator,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Progress Bar
                Row(
                  children: [
                    Text(
                      _formatDuration(audioPlayer.position),
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                    ),
                    Expanded(
                      child: Slider(
                        value: audioPlayer.duration.inSeconds > 0
                            ? audioPlayer.position.inSeconds / audioPlayer.duration.inSeconds
                            : 0.0,
                        onChanged: audioPlayer.isLoading
                            ? null
                            : (value) {
                                final newPosition = Duration(
                                  seconds: (value * audioPlayer.duration.inSeconds).toInt(),
                                );
                                audioPlayer.seek(newPosition);
                              },
                      ),
                    ),
                    Text(
                      _formatDuration(audioPlayer.duration),
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Controls
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.skip_previous),
                onPressed: audioPlayer.queue.isNotEmpty && audioPlayer.currentTrack != null
                    ? () => audioPlayer.previous()
                    : null,
              ),
              IconButton(
                icon: audioPlayer.isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        audioPlayer.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                        size: 48,
                      ),
                onPressed: () => audioPlayer.togglePlayPause(),
              ),
              IconButton(
                icon: const Icon(Icons.skip_next),
                onPressed: audioPlayer.queue.isNotEmpty && audioPlayer.currentTrack != null
                    ? () => audioPlayer.next()
                    : null,
              ),
            ],
          ),
          
          // Volume
          SizedBox(
            width: 100,
            child: Row(
              children: [
                Icon(Icons.volume_up, size: 20, color: Colors.grey[600]),
                Expanded(
                  child: Slider(
                    value: audioPlayer.volume,
                    onChanged: (value) => audioPlayer.setVolume(value),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

