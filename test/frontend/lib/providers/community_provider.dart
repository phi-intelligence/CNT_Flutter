import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CommunityProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  
  List<dynamic> _posts = [];
  bool _isLoading = false;
  String? _error;
  String? _selectedCategory;
  
  List<dynamic> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedCategory => _selectedCategory;
  
  Future<void> fetchPosts({String? category}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _posts = await _api.getCommunityPosts(category: category);
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
    fetchPosts(category: category);
  }
}

