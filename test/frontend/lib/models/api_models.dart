/// API Models for Backend Integration

class Podcast {
  final int id;
  final String title;
  final String? description;
  final String? audioUrl;
  final String? videoUrl;
  final String? coverImage;
  final int? creatorId;
  final int? categoryId;
  final int? duration; // seconds
  final String status;
  final int playsCount;
  final DateTime createdAt;

  Podcast({
    required this.id,
    required this.title,
    this.description,
    this.audioUrl,
    this.videoUrl,
    this.coverImage,
    this.creatorId,
    this.categoryId,
    this.duration,
    required this.status,
    required this.playsCount,
    required this.createdAt,
  });

  factory Podcast.fromJson(Map<String, dynamic> json) {
    return Podcast(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      audioUrl: json['audio_url'] as String?,
      videoUrl: json['video_url'] as String?,
      coverImage: json['cover_image'] as String?,
      creatorId: json['creator_id'] as int?,
      categoryId: json['category_id'] as int?,
      duration: json['duration'] as int?,
      status: json['status'] as String,
      playsCount: json['plays_count'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'audio_url': audioUrl,
      'video_url': videoUrl,
      'cover_image': coverImage,
      'creator_id': creatorId,
      'category_id': categoryId,
      'duration': duration,
      'status': status,
      'plays_count': playsCount,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class MusicTrack {
  final int id;
  final String title;
  final String artist;
  final String? album;
  final String? genre;
  final String audioUrl;
  final String? coverImage;
  final int? duration; // seconds
  final String? lyrics;
  final bool isFeatured;
  final bool isPublished;
  final int playsCount;
  final DateTime createdAt;

  MusicTrack({
    required this.id,
    required this.title,
    required this.artist,
    this.album,
    this.genre,
    required this.audioUrl,
    this.coverImage,
    this.duration,
    this.lyrics,
    required this.isFeatured,
    required this.isPublished,
    required this.playsCount,
    required this.createdAt,
  });

  factory MusicTrack.fromJson(Map<String, dynamic> json) {
    return MusicTrack(
      id: json['id'] as int,
      title: json['title'] as String,
      artist: json['artist'] as String,
      album: json['album'] as String?,
      genre: json['genre'] as String?,
      audioUrl: json['audio_url'] as String,
      coverImage: json['cover_image'] as String?,
      duration: json['duration'] as int?,
      lyrics: json['lyrics'] as String?,
      isFeatured: (json['is_featured'] ?? false) as bool,
      isPublished: (json['is_published'] ?? true) as bool,
      playsCount: json['plays_count'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'genre': genre,
      'audio_url': audioUrl,
      'cover_image': coverImage,
      'duration': duration,
      'lyrics': lyrics,
      'is_featured': isFeatured,
      'is_published': isPublished,
      'plays_count': playsCount,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

