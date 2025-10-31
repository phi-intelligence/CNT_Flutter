import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class UserProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  
  Map<String, dynamic>? _user;
  Map<String, dynamic>? _stats;
  bool _isLoading = false;
  String? _error;
  
  Map<String, dynamic>? get user => _user;
  Map<String, dynamic>? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<void> fetchUser() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _user = await _api.getCurrentUser();
      _stats = await _api.getUserStats();
      _error = null;
    } catch (e) {
      _error = 'Failed to load user: $e';
      print('Error fetching user: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void clearUser() {
    _user = null;
    _stats = null;
    notifyListeners();
  }
}

