import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CommunityProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  
  List<dynamic> _posts = [];
  bool _isLoading = false;
  String? _error;
  String? _selectedCategory;
  bool _hasMore = false; // Pagination support (set to false for now if backend doesn't support pagination)
  
  List<dynamic> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedCategory => _selectedCategory;
  bool get hasMore => _hasMore;
  
  Future<void> fetchPosts({String? category, bool refresh = false}) async {
    if (refresh) {
      _posts = []; // Clear existing posts on refresh
    }
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final newPosts = await _api.getCommunityPosts(category: category);
      if (refresh) {
        _posts = newPosts;
      } else {
        _posts.addAll(newPosts);
      }
      // For now, assume no more posts if we get less than expected (no pagination yet)
      // When pagination is implemented, set _hasMore based on response
      _hasMore = false; // Update this when backend supports pagination
      _error = null;
    } catch (e) {
      _error = 'Failed to load posts: $e';
      print('Error fetching posts: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void filterByCategory(String? category) {
    _selectedCategory = category;
    fetchPosts(category: category, refresh: true);
  }
  
  Future<void> likePost(int postId) async {
    try {
      final result = await _api.likePost(postId);
      if (result != null) {
        // Update the post in the local list
        final index = _posts.indexWhere((post) {
          final id = post is Map ? post['id'] : post.id;
          return id == postId;
        });
        
        if (index != -1) {
          final post = _posts[index];
          if (post is Map<String, dynamic>) {
            // Update Map-based post with response from API
            final updatedPost = Map<String, dynamic>.from(post);
            updatedPost['likes_count'] = result['likes_count'] ?? post['likes_count'] ?? 0;
            updatedPost['is_liked'] = result['liked'] ?? false;
            _posts[index] = updatedPost;
          } else {
            // For object-based posts, we'd need to create a new object
            // For now, just refetch if it's not a Map
            if (post is! Map) {
              await fetchPosts(category: _selectedCategory, refresh: true);
            }
          }
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error liking post: $e');
      // Optionally show an error message to user
    }
  }
}

