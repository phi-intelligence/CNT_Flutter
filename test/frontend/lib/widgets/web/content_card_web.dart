import 'package:flutter/material.dart';
import '../../models/content_item.dart';
import '../shared/image_helper.dart';

class ContentCardWeb extends StatefulWidget {
  final ContentItem item;
  final VoidCallback? onTap;
  final VoidCallback? onPlay;

  const ContentCardWeb({
    super.key,
    required this.item,
    this.onTap,
    this.onPlay,
  });

  @override
  State<ContentCardWeb> createState() => _ContentCardWebState();
}

class _ContentCardWebState extends State<ContentCardWeb> {
  bool _isHovered = false;

  String _formatDuration(Duration? duration) {
    if (duration == null) return '';
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Card(
          elevation: _isHovered ? 4 : 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image(
                      image: ImageHelper.getImageProvider(
                        widget.item.coverImage,
                        fallbackAsset: ImageHelper.getFallbackAsset(
                          int.tryParse(widget.item.id) ?? 0,
                        ),
                      ),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          ImageHelper.getFallbackAsset(
                            int.tryParse(widget.item.id) ?? 0,
                          ),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.music_note,
                                size: 48,
                                color: Colors.grey,
                              ),
                            );
                          },
                        );
                      },
                    ),
                    // Play button overlay
                    if (_isHovered)
                      Container(
                        color: Colors.black54,
                        child: Center(
                          child: IconButton(
                            icon: const Icon(
                              Icons.play_circle_filled,
                              size: 64,
                              color: Colors.white,
                            ),
                            onPressed: widget.onPlay,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Content Info
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.item.creator,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (widget.item.duration != null ||
                        widget.item.plays > 0) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (widget.item.duration != null)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.access_time, size: 12, color: Colors.grey[500]),
                                const SizedBox(width: 4),
                                Text(
                                  _formatDuration(widget.item.duration),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          if (widget.item.duration != null && widget.item.plays > 0)
                            const SizedBox(width: 12),
                          if (widget.item.plays > 0)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.play_arrow, size: 12, color: Colors.grey[500]),
                                const SizedBox(width: 4),
                                Text(
                                  '${widget.item.plays}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

