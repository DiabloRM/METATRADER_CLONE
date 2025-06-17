import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/user.dart';
import '../models/position.dart';

class MT5ApiService {
  final String baseUrl;
  final http.Client _client;
  bool _isConnected = false;

  MT5ApiService({required this.baseUrl}) : _client = http.Client();

  Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'An error occurred');
    }
  }

  // Connect to MT5 server
  Future<Map<String, dynamic>> connectToMT5({
    required String serverIp,
    required int serverPort,
    required String login,
    required String password,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiConfig.mt5ApiUrl}${ApiConfig.mt5ConnectEndpoint}'),
        headers: ApiConfig.getMT5Headers(),
        body: json.encode({
          'server_ip': serverIp,
          'server_port': serverPort,
          'login': login,
          'password': password,
        }),
      );

      final data = await _handleResponse(response);
      if (data['success'] == true) {
        _isConnected = true;
      }
      return data;
    } catch (e) {
      throw Exception('MT5 connection failed: ${e.toString()}');
    }
  }

  // Get account information from MT5
  Future<Map<String, dynamic>> getMT5AccountInfo(String login) async {
    if (!_isConnected) {
      throw Exception('Not connected to MT5 server');
    }

    try {
      final response = await _client.get(
        Uri.parse(
            '${ApiConfig.mt5ApiUrl}${ApiConfig.mt5AccountEndpoint}?login=$login'),
        headers: ApiConfig.getMT5Headers(),
      );

      return await _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to get MT5 account info: ${e.toString()}');
    }
  }

  // Get available symbols from MT5
  Future<Map<String, dynamic>> getMT5Symbols() async {
    if (!_isConnected) {
      throw Exception('Not connected to MT5 server');
    }

    try {
      final response = await _client.get(
        Uri.parse('${ApiConfig.mt5ApiUrl}${ApiConfig.mt5SymbolsEndpoint}'),
        headers: ApiConfig.getMT5Headers(),
      );

      return await _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to get MT5 symbols: ${e.toString()}');
    }
  }

  // Get open positions from MT5
  Future<Map<String, dynamic>> getMT5Positions(String login) async {
    if (!_isConnected) {
      throw Exception('Not connected to MT5 server');
    }

    try {
      final response = await _client.get(
        Uri.parse(
            '${ApiConfig.mt5ApiUrl}${ApiConfig.mt5PositionsEndpoint}?login=$login'),
        headers: ApiConfig.getMT5Headers(),
      );

      return await _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to get MT5 positions: ${e.toString()}');
    }
  }

  // Get pending orders from MT5
  Future<Map<String, dynamic>> getMT5Orders(String login) async {
    if (!_isConnected) {
      throw Exception('Not connected to MT5 server');
    }

    try {
      final response = await _client.get(
        Uri.parse(
            '${ApiConfig.mt5ApiUrl}${ApiConfig.mt5OrdersEndpoint}?login=$login'),
        headers: ApiConfig.getMT5Headers(),
      );

      return await _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to get MT5 orders: ${e.toString()}');
    }
  }

  // Get server time from MT5
  Future<Map<String, dynamic>> getMT5ServerTime() async {
    if (!_isConnected) {
      throw Exception('Not connected to MT5 server');
    }

    try {
      final response = await _client.get(
        Uri.parse('${ApiConfig.mt5ApiUrl}${ApiConfig.mt5TimeEndpoint}'),
        headers: ApiConfig.getMT5Headers(),
      );

      return await _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to get MT5 server time: ${e.toString()}');
    }
  }

  // Get messages from MT5
  Future<Map<String, dynamic>> getMessages(String login) async {
    if (!_isConnected) {
      throw Exception('Not connected to MT5 server');
    }

    try {
      final response = await _client.get(
        Uri.parse(
            '${ApiConfig.mt5ApiUrl}${ApiConfig.mt5MessagesEndpoint}?login=$login'),
        headers: ApiConfig.getMT5Headers(),
      );

      return await _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to get messages: ${e.toString()}');
    }
  }

  // Disconnect from MT5 server
  Future<Map<String, dynamic>> disconnectFromMT5() async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiConfig.mt5ApiUrl}${ApiConfig.mt5DisconnectEndpoint}'),
        headers: ApiConfig.getMT5Headers(),
      );

      final data = await _handleResponse(response);
      if (data['success'] == true) {
        _isConnected = false;
      }
      return data;
    } catch (e) {
      throw Exception('Failed to disconnect from MT5: ${e.toString()}');
    }
  }

  // Check connection status
  bool get isConnected => _isConnected;

  // Legacy methods for backward compatibility
  Future<User> login(String username, String password) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl${ApiConfig.loginEndpoint}'),
        headers: ApiConfig.getHeaders(),
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );

      final data = await _handleResponse(response);
      return User.fromJson(data);
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  Future<User> register(String username, String password, String email) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl${ApiConfig.registerEndpoint}'),
        headers: ApiConfig.getHeaders(),
        body: json.encode({
          'username': username,
          'password': password,
          'email': email,
        }),
      );

      final data = await _handleResponse(response);
      return User.fromJson(data);
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  Future<User> getUserAccount(String token) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl${ApiConfig.userAccountEndpoint}'),
        headers: ApiConfig.getHeaders(token: token),
      );

      final data = await _handleResponse(response);
      return User.fromJson(data);
    } catch (e) {
      throw Exception('Failed to get user account: ${e.toString()}');
    }
  }

  Future<List<Position>> getUserPositions(String token) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl${ApiConfig.userPositionsEndpoint}'),
        headers: ApiConfig.getHeaders(token: token),
      );

      final data = await _handleResponse(response);
      return (data['positions'] as List)
          .map((position) => Position.fromJson(position))
          .toList();
    } catch (e) {
      throw Exception('Failed to get user positions: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> getQuotes(String symbol, String token) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl${ApiConfig.quotesEndpoint}?symbol=$symbol'),
        headers: ApiConfig.getHeaders(token: token),
      );

      return await _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to get quotes: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> placeTrade({
    required String symbol,
    required String type,
    required double volume,
    required double price,
    required String token,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl${ApiConfig.tradingEndpoint}'),
        headers: ApiConfig.getHeaders(token: token),
        body: json.encode({
          'symbol': symbol,
          'type': type,
          'volume': volume,
          'price': price,
        }),
      );

      return await _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to place trade: ${e.toString()}');
    }
  }

  void dispose() {
    _client.close();
  }
}
