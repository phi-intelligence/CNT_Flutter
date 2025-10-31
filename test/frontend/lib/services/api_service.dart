import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/api_models.dart';

/// API Service for connecting Flutter to backend
class ApiService {
  // For Android emulator, use 10.0.2.2 to access host localhost
  // For iOS simulator, use localhost
  // For real device, use your computer's IP address
  static const String baseUrl = 'http://10.0.2.2:8002/api/v1';
  static const String mediaBaseUrl = 'http://10.0.2.2:8002';
  
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

  /// Like a post
  Future<bool> likePost(int postId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/community/posts/$postId/like'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error liking post: $e');
      return false;
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
}
