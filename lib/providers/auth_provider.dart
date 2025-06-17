import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/user.dart';
import '../models/register_model.dart';

class AuthProvider with ChangeNotifier {
  final MetaQuotesApiService _apiService;
  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;

  AuthProvider(this._apiService) {
    // Initialize from stored credentials if available
    _initializeFromStorage();
  }

  // Getters
  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _token != null;

  // Initialize from secure storage
  Future<void> _initializeFromStorage() async {
    try {
      final storedToken = await _apiService.getStoredToken();
      if (storedToken != null) {
        _token = storedToken;
        // Fetch user data
        await _fetchUserData();
      }
    } catch (e) {
      debugPrint('Error initializing auth state: $e');
    }
  }

  Future<void> _fetchUserData() async {
    try {
      final userData = await _apiService.getUserProfile();
      _user = User.fromJson(userData);
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching user data: $e');
    }
  }

  Future<void> register(RegisterModel model) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.register(model);
      _token = response['token'];
      _user = User.fromJson(response['user']);
      await _apiService.storeToken(_token!);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.login(email, password);
      _token = response['token'];
      _user = User.fromJson(response['user']);
      await _apiService.storeToken(_token!);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.logout();
      await _apiService.clearStoredToken();
      _token = null;
      _user = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
