class ContentItem {
  final String id;
  final String title;
  final String creator;
  final String? description;
  final String? coverImage;
  final String? audioUrl;
  final String? videoUrl;
  final Duration? duration;
  final String category;
  final int plays;
  final int likes;
  final DateTime createdAt;
  final bool isFavorite;

  ContentItem({
    required this.id,
    required this.title,
    required this.creator,
    this.description,
    this.coverImage,
    this.audioUrl,
    this.videoUrl,
    this.duration,
    required this.category,
    this.plays = 0,
    this.likes = 0,
    required this.createdAt,
    this.isFavorite = false,
  });

  factory ContentItem.fromJson(Map<String, dynamic> json) {
    return ContentItem(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      creator: json['creator'] ?? json['author'] ?? '',
      description: json['description'],
      coverImage: json['cover_image'] ?? json['thumbnail'] ?? json['coverImage'],
      audioUrl: json['audio_url'] ?? json['audioUrl'],
      videoUrl: json['video_url'] ?? json['videoUrl'],
      duration: json['duration'] != null 
          ? Duration(seconds: json['duration']) 
          : null,
      category: json['category'] ?? 'general',
      plays: json['plays'] ?? 0,
      likes: json['likes'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      isFavorite: json['is_favorite'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'creator': creator,
      'description': description,
      'cover_image': coverImage,
      'audio_url': audioUrl,
      'video_url': videoUrl,
      'duration': duration?.inSeconds,
      'category': category,
      'plays': plays,
      'likes': likes,
      'created_at': createdAt.toIso8601String(),
      'is_favorite': isFavorite,
    };
  }

  ContentItem copyWith({
    String? id,
    String? title,
    String? creator,
    String? description,
    String? coverImage,
    String? audioUrl,
    String? videoUrl,
    Duration? duration,
    String? category,
    int? plays,
    int? likes,
    DateTime? createdAt,
    bool? isFavorite,
  }) {
    return ContentItem(
      id: id ?? this.id,
      title: title ?? this.title,
      creator: creator ?? this.creator,
      description: description ?? this.description,
      coverImage: coverImage ?? this.coverImage,
      audioUrl: audioUrl ?? this.audioUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      duration: duration ?? this.duration,
      category: category ?? this.category,
      plays: plays ?? this.plays,
      likes: likes ?? this.likes,
      createdAt: createdAt ?? this.createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  /// Helper method to get category name from category ID
  static String _getCategoryName(int? categoryId) {
    switch (categoryId) {
      case 1: return 'Sermons';
      case 2: return 'Bible Study';
      case 3: return 'Devotionals';
      case 4: return 'Prayer';
      case 5: return 'Worship';
      case 6: return 'Gospel';
      default: return 'Podcast';
    }
  }
}

