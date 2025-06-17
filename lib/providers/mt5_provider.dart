import 'package:flutter/foundation.dart';
import '../services/mt5_api_service.dart';
import '../models/user.dart';
import '../models/register_model.dart';
import '../models/trading_models.dart';
import '../models/mt5_settings_model.dart';
import '../config/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class MT5Provider with ChangeNotifier {
  final MT5ApiService _apiService;
  User? _currentUser;
  bool _isLoading = false;
  String? _error;
  bool _isConnected = false;
  MT5Settings? _settings;

  MT5Provider() : _apiService = MT5ApiService(baseUrl: ApiConfig.baseUrl);

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isConnected => _isConnected;
  MT5Settings? get settings => _settings;

  // Connect to MT5 server
  Future<Map<String, dynamic>> connectToMT5({
    required String serverIp,
    required int serverPort,
    required String login,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _apiService.connectToMT5(
        serverIp: serverIp,
        serverPort: serverPort,
        login: login,
        password: password,
      );

      if (result['success'] == true) {
        _isConnected = true;
      }

      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'error': e.toString()};
    }
  }

  // Disconnect from MT5 server
  Future<Map<String, dynamic>> disconnectFromMT5() async {
    try {
      final result = await _apiService.disconnectFromMT5();
      _isConnected = false;
      notifyListeners();
      return result;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return {'success': false, 'error': e.toString()};
    }
  }

  // Save MT5 settings
  Future<void> saveSettings(MT5Settings settings) async {
    _settings = settings;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('mt5_settings', json.encode(settings.toJson()));
    notifyListeners();
  }

  // Load MT5 settings
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString('mt5_settings');
    if (settingsJson != null) {
      _settings = MT5Settings.fromJson(json.decode(settingsJson));
      notifyListeners();
    }
  }

  // Get MT5 account info
  Future<Map<String, dynamic>> getMT5AccountInfo(String login) async {
    try {
      return await _apiService.getMT5AccountInfo(login);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return {'success': false, 'error': e.toString()};
    }
  }

  // Get MT5 symbols
  Future<Map<String, dynamic>> getMT5Symbols() async {
    try {
      return await _apiService.getMT5Symbols();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return {'success': false, 'error': e.toString()};
    }
  }

  // Get MT5 positions
  Future<Map<String, dynamic>> getMT5Positions(String login) async {
    try {
      return await _apiService.getMT5Positions(login);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return {'success': false, 'error': e.toString()};
    }
  }

  // Get MT5 orders
  Future<Map<String, dynamic>> getMT5Orders(String login) async {
    try {
      return await _apiService.getMT5Orders(login);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return {'success': false, 'error': e.toString()};
    }
  }

  // Get MT5 server time
  Future<Map<String, dynamic>> getMT5ServerTime() async {
    try {
      return await _apiService.getMT5ServerTime();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return {'success': false, 'error': e.toString()};
    }
  }

  // Get messages (mock data for now)
  Future<Map<String, dynamic>> getMessages(String login) async {
    try {
      return await _apiService.getMessages(login);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await _apiService.login(username, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(RegisterModel registerData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await _apiService.register(registerData.email,
          registerData.password, registerData.confirmPassword);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<User?> getUserAccount() async {
    if (_currentUser == null) return null;

    try {
      final accountData = await _apiService.getUserAccount(_currentUser!.login);
      return User.fromJson(accountData as Map<String, dynamic>);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<List<Position>?> getUserPositions() async {
    if (_currentUser == null) return null;

    try {
      final positionsData =
          await _apiService.getUserPositions(_currentUser!.login);
      return positionsData
          .map((json) => Position.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  void logout() {
    _currentUser = null;
    _error = null;
    _isConnected = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }
}
