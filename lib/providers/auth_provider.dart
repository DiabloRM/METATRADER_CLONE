import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/register_model.dart';

class AuthProvider with ChangeNotifier {
  final MetaQuotesApiService _apiService;
  bool _isAuthenticated = false;
  String? _token;

  AuthProvider(this._apiService);

  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;

  Future<void> register(RegisterModel model) async {
    try {
      final response = await _apiService.register(model);
      _token = response['token'];
      _isAuthenticated = true;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> login(String email, String password) async {
    try {
      final response = await _apiService.login(email, password);
      _token = response['token'];
      _isAuthenticated = true;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  void logout() {
    _token = null;
    _isAuthenticated = false;
    notifyListeners();
  }
}
