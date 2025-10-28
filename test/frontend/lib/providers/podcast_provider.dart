import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/content_item.dart';
import '../models/api_models.dart';

class PodcastProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  
  List<ContentItem> _podcasts = [];
  List<ContentItem> _featuredPodcasts = [];
  List<ContentItem> _recentPodcasts = [];
  bool _isLoading = false;
  String? _error;
  
  List<ContentItem> get podcasts => _podcasts;
  List<ContentItem> get featuredPodcasts => _featuredPodcasts;
  List<ContentItem> get recentPodcasts => _recentPodcasts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<void> fetchPodcasts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Fetch all podcasts from API
      final podcastsData = await _api.getPodcasts();
      
      // Convert Podcast models to ContentItem models
      _podcasts = podcastsData.map((podcast) {
        return ContentItem(
          id: podcast.id.toString(),
          title: podcast.title,
          creator: 'Christ Tabernacle',
          description: podcast.description,
          coverImage: podcast.coverImage != null 
            ? _api.getMediaUrl(podcast.coverImage!) 
            : null,
          audioUrl: podcast.audioUrl != null 
            ? _api.getMediaUrl(podcast.audioUrl!) 
            : null,
          duration: podcast.duration != null 
            ? Duration(seconds: podcast.duration!)
            : null,
          category: _getCategoryName(podcast.categoryId),
          plays: podcast.playsCount,
          createdAt: podcast.createdAt,
        );
      }).toList();
      
      // Get featured podcasts (sorted by plays count)
      _featuredPodcasts = List.from(_podcasts);
      _featuredPodcasts.sort((a, b) => b.plays.compareTo(a.plays));
      _featuredPodcasts = _featuredPodcasts.take(5).toList();
      
      // Get recent podcasts (sorted by created_at)
      _recentPodcasts = List.from(_podcasts);
      _recentPodcasts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _recentPodcasts = _recentPodcasts.take(5).toList();
      
      _error = null;
      print('✅ Loaded ${_podcasts.length} podcasts from API');
    } catch (e) {
      _error = 'Failed to load podcasts: $e';
      print('❌ Error fetching podcasts: $e');
      // Add mock data for development if API fails
      _addMockData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  String _getCategoryName(int? categoryId) {
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
  
  Future<ContentItem?> getPodcastById(int id) async {
    try {
      final podcast = await _api.getPodcast(id);
      return ContentItem(
        id: podcast.id.toString(),
        title: podcast.title,
        creator: 'Christ Tabernacle',
        description: podcast.description,
        coverImage: podcast.coverImage != null 
          ? _api.getMediaUrl(podcast.coverImage!) 
          : null,
        audioUrl: podcast.audioUrl != null 
          ? _api.getMediaUrl(podcast.audioUrl!) 
          : null,
        duration: podcast.duration != null 
          ? Duration(seconds: podcast.duration!)
          : null,
        category: _getCategoryName(podcast.categoryId),
        plays: podcast.playsCount,
        createdAt: podcast.createdAt,
      );
    } catch (e) {
      print('Error fetching podcast: $e');
      return null;
    }
  }
  
  void _addMockData() {
    _podcasts = [
      ContentItem(
        id: '1',
        title: 'Finding Peace in Troubled Times',
        creator: 'Pastor John Smith',
        description: 'A message of hope and peace',
        coverImage: 'https://via.placeholder.com/300',
        audioUrl: 'https://example.com/audio1.mp3',
        duration: Duration(minutes: 45),
        category: 'teaching',
        plays: 1234,
        likes: 89,
        createdAt: DateTime.now().subtract(Duration(days: 2)),
      ),
      ContentItem(
        id: '2',
        title: 'The Power of Prayer',
        creator: 'Rev. Mary Johnson',
        description: 'Understanding the strength of prayer',
        coverImage: 'https://via.placeholder.com/300',
        audioUrl: 'https://example.com/audio2.mp3',
        duration: Duration(minutes: 30),
        category: 'prayer',
        plays: 856,
        likes: 67,
        createdAt: DateTime.now().subtract(Duration(days: 5)),
      ),
      ContentItem(
        id: '3',
        title: 'Walking in Faith',
        creator: 'Pastor David Lee',
        description: 'Daily devotionals for spiritual growth',
        coverImage: 'https://via.placeholder.com/300',
        audioUrl: 'https://example.com/audio3.mp3',
        duration: Duration(minutes: 20),
        category: 'devotion',
        plays: 2341,
        likes: 156,
        createdAt: DateTime.now().subtract(Duration(days: 1)),
      ),
    ];
    _featuredPodcasts = _podcasts.take(3).toList();
    _recentPodcasts = _podcasts;
  }
}

