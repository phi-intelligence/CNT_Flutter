import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/api_models.dart';

/// API Service for connecting Flutter to backend
class ApiService {
  // For Android emulator, use 10.0.2.2 to access host localhost
  // For iOS simulator, use localhost
  // For real device, use your computer's IP address (e.g., 192.168.0.14)
  // Configure via --dart-define=API_BASE=http://YOUR_IP:8002/api/v1
  static String get baseUrl => const String.fromEnvironment(
    'API_BASE',
    defaultValue: 'http://10.0.2.2:8002/api/v1',
  );
  static String get mediaBaseUrl => const String.fromEnvironment(
    'MEDIA_BASE',
    defaultValue: 'http://10.0.2.2:8002',
  );
  
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  /// Create a live stream/meeting (returns backend stream object)
  Future<Map<String, dynamic>> createStream({
    String title = 'Instant Meeting',
    String? description,
    String? category,
    DateTime? scheduledStart,
  }) async {
    try {
      final body = <String, dynamic>{
        'title': title,
        'description': description,
        'category': category,
        'scheduled_start': scheduledStart?.toIso8601String(),
      }..removeWhere((k, v) => v == null);

      final response = await http.post(
        Uri.parse('$baseUrl/live/streams'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
      throw Exception('Failed to create stream: HTTP ${response.statusCode} ${response.body}');
    } catch (e) {
      throw Exception('Network error creating stream: $e');
    }
  }

  /// List streams (optional helper when joining by room without backend route)
  Future<List<Map<String, dynamic>>> listStreams({String? status}) async {
    try {
      Uri uri = Uri.parse('$baseUrl/live/streams');
      if (status != null) {
        uri = uri.replace(queryParameters: {'status': status});
      }
      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      throw Exception('Failed to list streams: HTTP ${response.statusCode}');
    } catch (e) {
      throw Exception('Network error listing streams: $e');
    }
  }

  /// Get full media URL for audio/image files
  String getMediaUrl(String? path) {
    if (path == null) return '';
    // Backend mounts media directory at /media endpoint
    return '$mediaBaseUrl/media/$path';
  }

  /// Get all podcasts
  Future<List<Podcast>> getPodcasts({
    int skip = 0,
    int limit = 100,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/podcasts/?skip=$skip&limit=$limit'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Podcast.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load podcasts: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching podcasts: $e');
    }
  }

  /// Get single podcast
  Future<Podcast> getPodcast(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/podcasts/$id'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return Podcast.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load podcast: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching podcast: $e');
    }
  }

  /// Get music tracks
  Future<List<MusicTrack>> getMusicTracks({
    int skip = 0,
    int limit = 100,
    String? genre,
    String? artist,
  }) async {
    try {
      Uri uri = Uri.parse('$baseUrl/music/tracks/?skip=$skip&limit=$limit');
      if (genre != null) {
        uri = uri.replace(queryParameters: {
          ...uri.queryParameters,
          'genre': genre,
        });
      }
      if (artist != null) {
        uri = uri.replace(queryParameters: {
          ...uri.queryParameters,
          'artist': artist,
        });
      }

      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => MusicTrack.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load music tracks: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching music tracks: $e');
    }
  }

  /// Get single music track
  Future<MusicTrack> getMusicTrack(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/music/tracks/$id'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return MusicTrack.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load music track: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching music track: $e');
    }
  }

  /// Get featured podcasts (top plays or status = approved)
  Future<List<Podcast>> getFeaturedPodcasts() async {
    final podcasts = await getPodcasts(limit: 50);
    // Filter and sort by plays_count
    podcasts.sort((a, b) => b.playsCount.compareTo(a.playsCount));
    return podcasts.take(10).toList();
  }

  /// Get recent podcasts (newest first)
  Future<List<Podcast>> getRecentPodcasts() async {
    final podcasts = await getPodcasts(limit: 20);
    // Sort by created_at descending
    podcasts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return podcasts.take(10).toList();
  }

  /// Get community posts
  Future<List<dynamic>> getCommunityPosts({
    String? category,
    int skip = 0,
    int limit = 20,
  }) async {
    try {
      Uri uri = Uri.parse('$baseUrl/community/posts');
      final queryParams = {
        'skip': skip.toString(),
        'limit': limit.toString(),
      };
      if (category != null && category != 'All' && category.isNotEmpty) {
        queryParams['category'] = category.toLowerCase();
      }
      
      final response = await http.get(
        uri.replace(queryParameters: queryParams),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Failed to load posts: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching posts: $e');
    }
  }

  /// Create a new community post
  Future<Map<String, dynamic>> createPost({
    required String title,
    required String content,
    String? category,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/community/posts'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'title': title,
          'content': content,
          'category': category ?? 'General',
        }),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      }
      throw Exception('Failed to create post: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error creating post: $e');
    }
  }

  /// Like a post (toggles like/unlike)
  Future<Map<String, dynamic>?> likePost(int postId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/community/posts/$postId/like'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error liking post: $e');
      return null;
    }
  }

  /// Comment on a post
  Future<Map<String, dynamic>> commentPost(int postId, String comment) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/community/posts/$postId/comments'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'content': comment}),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      }
      throw Exception('Failed to comment: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error commenting: $e');
    }
  }

  /// Get current user profile
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      // For now, return mock user data
      // TODO: Replace with actual API endpoint when authentication is implemented
      return {
        'id': 1,
        'name': 'John Doe',
        'email': 'john.doe@example.com',
        'avatar': null,
        'created_at': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw Exception('Error fetching user: $e');
    }
  }

  /// Get user stats (total listening time, tracks played, etc.)
  Future<Map<String, dynamic>> getUserStats() async {
    try {
      // TODO: Implement actual stats endpoint
      return {
        'total_minutes': 1234,
        'songs_played': 567,
        'streak_days': 30,
      };
    } catch (e) {
      return {
        'total_minutes': 0,
        'songs_played': 0,
        'streak_days': 0,
      };
    }
  }

  /// Get all playlists
  Future<List<dynamic>> getPlaylists() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/playlists'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data;
      }
      return [];
    } catch (e) {
      print('Error fetching playlists: $e');
    return [];
    }
  }

  /// Create a new playlist
  Future<Map<String, dynamic>> createPlaylist({
    required String name,
    String? description,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/playlists'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'description': description,
        }),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      }
      throw Exception('Failed to create playlist: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error creating playlist: $e');
    }
  }

  /// Add item to playlist
  Future<bool> addToPlaylist(int playlistId, String contentType, int contentId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/playlists/$playlistId/items'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'content_type': contentType,
          'content_id': contentId,
        }),
      ).timeout(const Duration(seconds: 10));
      
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error adding to playlist: $e');
      return false;
    }
  }

  /// Get favorites
  Future<List<dynamic>> getFavorites() async {
    try {
      // TODO: Implement favorites endpoint
      // For now, return empty list
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Add to favorites
  Future<bool> addToFavorites(String contentType, int contentId) async {
    try {
      // TODO: Implement favorites endpoint
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Remove from favorites
  Future<bool> removeFromFavorites(String contentType, int contentId) async {
    try {
      // TODO: Implement favorites endpoint
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Search across all content types
  Future<Map<String, dynamic>> searchContent({
    required String query,
    String? type, // 'podcasts', 'music', 'videos', 'posts', 'users'
    int skip = 0,
    int limit = 20,
  }) async {
    try {
      // For now, implement client-side search as backend search endpoint may not exist
      // Try API first, fallback to client-side search
      Uri uri = Uri.parse('$baseUrl/search');
      final queryParams = {
        'q': query,
        'skip': skip.toString(),
        'limit': limit.toString(),
      };
      if (type != null && type != 'All') {
        queryParams['type'] = type.toLowerCase();
      }
      
      final response = await http.get(
        uri.replace(queryParameters: queryParams),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      // If search endpoint doesn't exist, return empty results
      // Client-side search will be handled in SearchProvider
      return {'podcasts': [], 'music': [], 'posts': []};
    } catch (e) {
      // Return empty results if search endpoint doesn't exist
      return {'podcasts': [], 'music': [], 'posts': []};
    }
  }

  /// Upload file and get URL
  Future<String> uploadFile(
    String filePath,
    String endpoint, {
    Function(int, int)? onProgress,
  }) async {
    try {
      final file = await http.MultipartFile.fromPath('file', filePath);
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl$endpoint'));
      request.files.add(file);
      
      final streamedResponse = await request.send().timeout(const Duration(minutes: 5));
      
      if (streamedResponse.statusCode == 200 || streamedResponse.statusCode == 201) {
        final response = await http.Response.fromStream(streamedResponse);
        final data = json.decode(response.body);
        return data['url'] ?? data['path'] ?? '';
      }
      throw Exception('Failed to upload file: HTTP ${streamedResponse.statusCode}');
    } catch (e) {
      throw Exception('Error uploading file: $e');
    }
  }

  /// Download file from URL
  Future<String> downloadFile(
    String url,
    String savePath, {
    Function(int, int)? onProgress,
  }) async {
    try {
      final uri = Uri.parse(url.startsWith('http') ? url : '$mediaBaseUrl$url');
      final request = http.Request('GET', uri);
      final streamedResponse = await request.send().timeout(const Duration(minutes: 5));
      
      if (streamedResponse.statusCode == 200) {
        final file = await http.Response.fromStream(streamedResponse);
        // Save file to savePath
        // This is a simplified version - in production you'd write to FileSystem
        return savePath;
      }
      throw Exception('Failed to download file: HTTP ${streamedResponse.statusCode}');
    } catch (e) {
      throw Exception('Error downloading file: $e');
    }
  }

  /// Video editing endpoints
  Future<Map<String, dynamic>> trimVideo(
    String videoPath,
    double startTime,
    double endTime, {
    Function(int, int)? onProgress,
  }) async {
    try {
      final file = await http.MultipartFile.fromPath('video_file', videoPath);
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/video-editing/trim'));
      request.files.add(file);
      request.fields['start_time'] = startTime.toString();
      request.fields['end_time'] = endTime.toString();
      
      final streamedResponse = await request.send().timeout(const Duration(minutes: 10));
      
      if (streamedResponse.statusCode == 200) {
        final response = await http.Response.fromStream(streamedResponse);
        return json.decode(response.body);
      }
      throw Exception('Failed to trim video: HTTP ${streamedResponse.statusCode}');
    } catch (e) {
      throw Exception('Error trimming video: $e');
    }
  }

  Future<Map<String, dynamic>> removeAudio(String videoPath) async {
    try {
      final file = await http.MultipartFile.fromPath('video_file', videoPath);
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/video-editing/remove-audio'));
      request.files.add(file);
      
      final streamedResponse = await request.send().timeout(const Duration(minutes: 10));
      
      if (streamedResponse.statusCode == 200) {
        final response = await http.Response.fromStream(streamedResponse);
        return json.decode(response.body);
      }
      throw Exception('Failed to remove audio: HTTP ${streamedResponse.statusCode}');
    } catch (e) {
      throw Exception('Error removing audio: $e');
    }
  }

  Future<Map<String, dynamic>> addAudio(String videoPath, String audioPath) async {
    try {
      final videoFile = await http.MultipartFile.fromPath('video_file', videoPath);
      final audioFile = await http.MultipartFile.fromPath('audio_file', audioPath);
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/video-editing/add-audio'));
      request.files.add(videoFile);
      request.files.add(audioFile);
      
      final streamedResponse = await request.send().timeout(const Duration(minutes: 10));
      
      if (streamedResponse.statusCode == 200) {
        final response = await http.Response.fromStream(streamedResponse);
        return json.decode(response.body);
      }
      throw Exception('Failed to add audio: HTTP ${streamedResponse.statusCode}');
    } catch (e) {
      throw Exception('Error adding audio: $e');
    }
  }

  Future<Map<String, dynamic>> applyVideoFilters(
    String videoPath, {
    double? brightness,
    double? contrast,
    double? saturation,
  }) async {
    try {
      final file = await http.MultipartFile.fromPath('video_file', videoPath);
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/video-editing/apply-filters'));
      request.files.add(file);
      if (brightness != null) request.fields['brightness'] = brightness.toString();
      if (contrast != null) request.fields['contrast'] = contrast.toString();
      if (saturation != null) request.fields['saturation'] = saturation.toString();
      
      final streamedResponse = await request.send().timeout(const Duration(minutes: 10));
      
      if (streamedResponse.statusCode == 200) {
        final response = await http.Response.fromStream(streamedResponse);
        return json.decode(response.body);
      }
      throw Exception('Failed to apply filters: HTTP ${streamedResponse.statusCode}');
    } catch (e) {
      throw Exception('Error applying filters: $e');
    }
  }

  /// Audio editing endpoints
  Future<Map<String, dynamic>> trimAudio(
    String audioPath,
    double startTime,
    double endTime,
  ) async {
    try {
      final file = await http.MultipartFile.fromPath('audio_file', audioPath);
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/audio-editing/trim'));
      request.files.add(file);
      request.fields['start_time'] = startTime.toString();
      request.fields['end_time'] = endTime.toString();
      
      final streamedResponse = await request.send().timeout(const Duration(minutes: 10));
      
      if (streamedResponse.statusCode == 200) {
        final response = await http.Response.fromStream(streamedResponse);
        return json.decode(response.body);
      }
      throw Exception('Failed to trim audio: HTTP ${streamedResponse.statusCode}');
    } catch (e) {
      throw Exception('Error trimming audio: $e');
    }
  }

  Future<Map<String, dynamic>> mergeAudio(List<String> audioPaths) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/audio-editing/merge'));
      
      for (final audioPath in audioPaths) {
        final file = await http.MultipartFile.fromPath('audio_files', audioPath);
        request.files.add(file);
      }
      
      final streamedResponse = await request.send().timeout(const Duration(minutes: 10));
      
      if (streamedResponse.statusCode == 200) {
        final response = await http.Response.fromStream(streamedResponse);
        return json.decode(response.body);
      }
      throw Exception('Failed to merge audio: HTTP ${streamedResponse.statusCode}');
    } catch (e) {
      throw Exception('Error merging audio: $e');
    }
  }

  Future<Map<String, dynamic>> fadeInAudio(String audioPath, double fadeDuration) async {
    try {
      final file = await http.MultipartFile.fromPath('audio_file', audioPath);
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/audio-editing/fade-in'));
      request.files.add(file);
      request.fields['fade_duration'] = fadeDuration.toString();
      
      final streamedResponse = await request.send().timeout(const Duration(minutes: 10));
      
      if (streamedResponse.statusCode == 200) {
        final response = await http.Response.fromStream(streamedResponse);
        return json.decode(response.body);
      }
      throw Exception('Failed to apply fade in: HTTP ${streamedResponse.statusCode}');
    } catch (e) {
      throw Exception('Error applying fade in: $e');
    }
  }

  Future<Map<String, dynamic>> fadeOutAudio(String audioPath, double fadeDuration) async {
    try {
      final file = await http.MultipartFile.fromPath('audio_file', audioPath);
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/audio-editing/fade-out'));
      request.files.add(file);
      request.fields['fade_duration'] = fadeDuration.toString();
      
      final streamedResponse = await request.send().timeout(const Duration(minutes: 10));
      
      if (streamedResponse.statusCode == 200) {
        final response = await http.Response.fromStream(streamedResponse);
        return json.decode(response.body);
      }
      throw Exception('Failed to apply fade out: HTTP ${streamedResponse.statusCode}');
    } catch (e) {
      throw Exception('Error applying fade out: $e');
    }
  }

  Future<Map<String, dynamic>> fadeInOutAudio(
    String audioPath,
    double fadeInDuration,
    double fadeOutDuration,
  ) async {
    try {
      final file = await http.MultipartFile.fromPath('audio_file', audioPath);
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/audio-editing/fade-in-out'));
      request.files.add(file);
      request.fields['fade_in_duration'] = fadeInDuration.toString();
      request.fields['fade_out_duration'] = fadeOutDuration.toString();
      
      final streamedResponse = await request.send().timeout(const Duration(minutes: 10));
      
      if (streamedResponse.statusCode == 200) {
        final response = await http.Response.fromStream(streamedResponse);
        return json.decode(response.body);
      }
      throw Exception('Failed to apply fade in/out: HTTP ${streamedResponse.statusCode}');
    } catch (e) {
      throw Exception('Error applying fade in/out: $e');
    }
  }
}
