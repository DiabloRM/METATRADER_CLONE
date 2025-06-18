import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/register_model.dart';
import '../models/trading_models.dart';
import '../models/mt5_settings_model.dart';
import '../models/news_model.dart';
import '../models/message_model.dart';
import '../config/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/journal_model.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException(this.message, {this.statusCode, this.data});

  @override
  String toString() =>
      'ApiException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

class MetaQuotesApiService {
  final Dio _dio;
  final FlutterSecureStorage _storage;
  late final String _baseUrl;

  // Singleton instance
  static MetaQuotesApiService? _instance;

  // Factory constructor to ensure singleton pattern
  factory MetaQuotesApiService() {
    _instance ??= MetaQuotesApiService._internal();
    return _instance!;
  }

  MetaQuotesApiService._internal()
      : _dio = Dio(),
        _storage = const FlutterSecureStorage() {
    _baseUrl = _getBaseUrl();
    _configureDio();
  }

  void _configureDio() {
    _dio.options = BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: Duration(seconds: ApiConfig.connectTimeout),
      receiveTimeout: Duration(seconds: ApiConfig.receiveTimeout),
      validateStatus: (status) => status != null && status < 500,
    );

    // Add interceptors for logging and token management
    _dio.interceptors.addAll([
      _AuthInterceptor(_storage),
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (object) => debugPrint(object.toString()),
      ),
    ]);
  }

  String _getBaseUrl() {
    if (kIsWeb) {
      return 'http://localhost:8000';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000'; // Android emulator localhost
    } else if (Platform.isIOS) {
      return Platform.environment.containsKey('FLUTTER_TEST')
          ? 'http://localhost:8000'
          : 'http://127.0.0.1:8000';
    }
    return 'http://localhost:8000';
  }

  String? _token;

  // Token management methods
  Future<void> storeToken(String token) async {
    _token = token;
    await _storage.write(key: 'auth_token', value: token);
  }

  Future<String?> getStoredToken() async {
    if (_token == null) {
      _token = await _storage.read(key: 'auth_token');
    }
    return _token;
  }

  Future<void> clearStoredToken() async {
    _token = null;
    await _storage.delete(key: 'auth_token');
  }

  // Auth methods
  Future<Map<String, dynamic>> register(RegisterModel model) async {
    try {
      // Use the simple API that doesn't require MT5 connection
      final response = await http.post(
        Uri.parse('http://localhost:8000/auth/register_simple.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(model.toJson()),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['token'] != null) {
          await storeToken(data['token']);
        }
        return data;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Registration failed');
      }
    } catch (e) {
      // Fallback to original API
      try {
        final response = await _dio.post(
          '/auth/register',
          data: model.toJson(),
        );
        return _handleResponse(response);
      } catch (fallbackError) {
        throw _handleError(e);
      }
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      // Use the simple API that doesn't require MT5 connection
      final response = await http.post(
        Uri.parse('http://localhost:8000/auth/login_simple.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['token'] != null) {
          await storeToken(data['token']);
        }
        return data;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Login failed');
      }
    } catch (e) {
      // Fallback to original API
      try {
        final response = await _dio.post(
          '/auth/login',
          data: {'email': email, 'password': password},
        );
        final data = _handleResponse(response);
        if (data['token'] != null) {
          await storeToken(data['token']);
        }
        return data;
      } catch (fallbackError) {
        throw _handleError(e);
      }
    }
  }

  Future<void> logout() async {
    await clearStoredToken();
  }

  // User profile methods
  Future<Map<String, dynamic>> getUserProfile() async {
    final token = await getStoredToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/api/user/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw _handleError(response);
    }
  }

  // Market data methods
  Future<List<Map<String, dynamic>>> getMarketSymbols() async {
    try {
      // Try to get symbols from the new quotes endpoint
      final response = await http.get(
        Uri.parse('$_baseUrl/api/quotes_endpoint.php'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] && data['data']) {
          // Convert quotes data to symbols format
          return data['data']
              .map<Map<String, dynamic>>((quote) => {
                    'symbol': quote['symbol'],
                    'description': quote['symbol'],
                    'digits': 5,
                    'spread': (quote['ask'] - quote['bid']) *
                        10000, // Convert to pips
                    'spread_balance': 0,
                    'trade_stops_level': 10,
                    'trade_freeze_level': 0,
                  })
              .toList();
        }
      }
    } catch (e) {
      print('Failed to get symbols from quotes endpoint: $e');
    }

    // Fallback to original endpoint
    try {
      final token = await getStoredToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/api/market/symbols'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      // Return mock symbols if all else fails
      return [
        {'symbol': 'EURUSD', 'description': 'Euro vs US Dollar'},
        {'symbol': 'GBPUSD', 'description': 'British Pound vs US Dollar'},
        {'symbol': 'USDJPY', 'description': 'US Dollar vs Japanese Yen'},
        {'symbol': 'AUDUSD', 'description': 'Australian Dollar vs US Dollar'},
        {'symbol': 'USDCAD', 'description': 'US Dollar vs Canadian Dollar'},
        {'symbol': 'NZDUSD', 'description': 'New Zealand Dollar vs US Dollar'},
        {'symbol': 'USDCHF', 'description': 'US Dollar vs Swiss Franc'},
        {'symbol': 'EURGBP', 'description': 'Euro vs British Pound'},
      ];
    }
  }

  Future<Map<String, dynamic>> getSymbolQuote(String symbol) async {
    try {
      // Try to get quote from the new quotes endpoint
      final response = await http.get(
        Uri.parse('$_baseUrl/api/quotes_endpoint.php?symbol=$symbol'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] && data['data']) {
          return data['data'];
        }
      }
    } catch (e) {
      print('Failed to get quote from quotes endpoint: $e');
    }

    // Fallback to original endpoint
    try {
      final token = await getStoredToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/api/market/quote/$symbol'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      // Return mock quote if all else fails
      return {
        'symbol': symbol,
        'bid': 1.0000,
        'ask': 1.0002,
        'last': 1.0001,
        'volume': 1000,
        'timestamp': DateTime.now().toIso8601String(),
        'real_data': false,
      };
    }
  }

  // MT5 Connection Methods
  Future<Map<String, dynamic>> connectToMT5(MT5Settings settings) async {
    try {
      final response = await _dio.post(
        '/mt5/connect',
        data: settings.toJson(),
      );
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Account Methods
  Future<AccountInfo> getAccountInfo() async {
    try {
      final response = await _dio.get('/user/account');
      return AccountInfo.fromJson(_handleResponse(response));
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Market Data Methods
  Future<List<MarketData>> getMarketData(String symbol) async {
    try {
      final response = await _dio.get(
        '/market/data',
        queryParameters: {'symbol': symbol},
      );
      final List<dynamic> data = _handleResponse(response);
      return data.map((json) => MarketData.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<MarketData>> getQuotes() async {
    try {
      // Try to get quotes from the new endpoint
      final response = await http.get(
        Uri.parse('$_baseUrl/api/quotes_endpoint.php'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] && data['data']) {
          return data['data']
              .map<MarketData>((quote) => MarketData.fromJson(quote))
              .toList();
        }
      }
    } catch (e) {
      print('Failed to get quotes from new endpoint: $e');
    }

    // Fallback to original endpoint
    try {
      final response = await _dio.get('/quotes');
      final List<dynamic> data = _handleResponse(response);
      return data.map((json) => MarketData.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<MarketData> getQuoteBySymbol(String symbol) async {
    try {
      // Try to get quote from the new endpoint
      final response = await http.get(
        Uri.parse('$_baseUrl/api/quotes_endpoint.php?symbol=$symbol'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] && data['data']) {
          return MarketData.fromJson(data['data']);
        }
      }
    } catch (e) {
      print('Failed to get quote from new endpoint: $e');
    }

    // Fallback to original endpoint
    try {
      final response = await _dio.get('/quotes/$symbol');
      return MarketData.fromJson(_handleResponse(response));
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Chart Data Methods
  Future<Map<String, dynamic>> getChartData({
    required String symbol,
    required String timeframe,
    int count = 100,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/chart_endpoint.php').replace(
        queryParameters: {
          'symbol': symbol,
          'timeframe': timeframe,
          'count': count.toString(),
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return data;
        } else {
          throw Exception(data['error'] ?? 'Failed to get chart data');
        }
      } else {
        throw Exception(
            'HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Failed to get chart data: $e');
      // Return mock chart data on error
      return {
        'success': true,
        'data': _generateMockChartData(symbol, timeframe, count),
        'symbol': symbol,
        'timeframe': timeframe,
        'source': 'mock',
        'error': e.toString(),
        'message': 'Using demo data due to error'
      };
    }
  }

  List<Map<String, dynamic>> _generateMockChartData(
      String symbol, String timeframe, int count) {
    final data = <Map<String, dynamic>>[];
    final basePrice = _getBasePriceForSymbol(symbol);
    final volatility = _getVolatilityForTimeframe(timeframe);

    final currentTime = DateTime.now();
    final interval = _getIntervalForTimeframe(timeframe);

    for (int i = count - 1; i >= 0; i--) {
      final timestamp = currentTime.subtract(Duration(seconds: i * interval));

      // Generate realistic OHLC data
      final open = basePrice + (Random().nextDouble() - 0.5) * volatility;
      final close = open + (Random().nextDouble() - 0.5) * volatility;
      final high = max(open, close) + Random().nextDouble() * volatility * 0.5;
      final low = min(open, close) - Random().nextDouble() * volatility * 0.5;
      final volume = Random().nextInt(10000) + 100;

      data.add({
        'timestamp': timestamp.millisecondsSinceEpoch ~/ 1000,
        'datetime': timestamp.toIso8601String(),
        'open': double.parse(open.toStringAsFixed(5)),
        'high': double.parse(high.toStringAsFixed(5)),
        'low': double.parse(low.toStringAsFixed(5)),
        'close': double.parse(close.toStringAsFixed(5)),
        'volume': volume
      });
    }

    return data;
  }

  double _getBasePriceForSymbol(String symbol) {
    final basePrices = {
      'EURUSD': 1.1428,
      'GBPUSD': 1.2650,
      'USDJPY': 148.50,
      'AUDUSD': 0.6650,
      'USDCAD': 1.3550,
      'NZDUSD': 0.6150,
      'USDCHF': 0.8850,
      'EURGBP': 0.9030
    };

    return basePrices[symbol] ?? 1.1428;
  }

  double _getVolatilityForTimeframe(String timeframe) {
    final volatilities = {
      'M1': 0.0001,
      'M5': 0.0002,
      'M15': 0.0003,
      'M30': 0.0005,
      'H1': 0.0008,
      'H4': 0.0015,
      'D1': 0.0030,
      'W1': 0.0080,
      'MN1': 0.0200
    };

    return volatilities[timeframe] ?? 0.0010;
  }

  int _getIntervalForTimeframe(String timeframe) {
    final intervals = {
      'M1': 60,
      'M5': 300,
      'M15': 900,
      'M30': 1800,
      'H1': 3600,
      'H4': 14400,
      'D1': 86400,
      'W1': 604800,
      'MN1': 2592000
    };

    return intervals[timeframe] ?? 86400;
  }

  // Trading Methods
  Future<Map<String, dynamic>> placeOrder({
    required String symbol,
    required String type,
    required double volume,
    required double price,
  }) async {
    try {
      final response = await _dio.post(
        '/trade/order',
        data: {
          'symbol': symbol,
          'type': type,
          'volume': volume,
          'price': price,
        },
      );
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Position>> getOpenPositions() async {
    try {
      final response = await _dio.get('/trade/positions');
      final List<dynamic> data = _handleResponse(response);
      return data.map((json) => Position.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Map<String, dynamic>>> getOrderHistory() async {
    final token = await getStoredToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/api/trading/history'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw _handleError(response);
    }
  }

  // News Methods
  Future<NewsResponse> getNews() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/news_endpoint.php'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return NewsResponse.fromJson(data);
      } else {
        throw Exception('Failed to get news: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to get news: $e');
      // Return mock news data on error
      return NewsResponse(
        success: true,
        articles: _generateMockNews(),
        source: 'mock',
        note: 'Error connecting to server. Showing demo news data.',
        connected: false,
        error: e.toString(),
      );
    }
  }

  Future<Map<String, dynamic>> sendNews({
    required String subject,
    required String content,
    String category = 'General',
    int priority = 0,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/news_endpoint.php'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'subject': subject,
          'content': content,
          'category': category,
          'priority': priority,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to send news: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to send news: $e');
      // Return mock success response
      return {
        'success': true,
        'message': 'News would be sent (server not available)',
        'source': 'mock',
        'note':
            'This is a demo response. In production, MT5 server would be required.',
      };
    }
  }

  List<NewsArticle> _generateMockNews() {
    return [
      NewsArticle(
        id: '1',
        title: 'EUR/USD Reaches Key Resistance Level',
        summary:
            'The Euro has reached a critical resistance level at 1.1450 against the US Dollar.',
        content:
            'The EUR/USD pair has been showing strong momentum over the past week, reaching the key resistance level of 1.1450. This level has historically acted as a significant barrier for the Euro.',
        category: 'Forex',
        priority: 'high',
        author: 'Market Analysis Team',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        tags: ['EUR/USD', 'Forex', 'Technical Analysis'],
      ),
      NewsArticle(
        id: '2',
        title: 'Federal Reserve Signals Potential Rate Cut',
        summary:
            'Federal Reserve officials have indicated a possible interest rate cut in the coming months.',
        content:
            'Federal Reserve officials have recently signaled that they may consider cutting interest rates in the coming months due to ongoing economic uncertainty and global trade tensions.',
        category: 'Economics',
        priority: 'high',
        author: 'Economic Research',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        tags: ['Federal Reserve', 'Interest Rates', 'USD'],
      ),
      NewsArticle(
        id: '3',
        title: 'Gold Prices Surge to 6-Month High',
        summary:
            'Gold prices have reached their highest level in six months as investors seek safe-haven assets.',
        content:
            'Gold prices have surged to their highest level in six months, reaching \$2,050 per ounce. This rally has been driven by increased demand for safe-haven assets.',
        category: 'Commodities',
        priority: 'medium',
        author: 'Commodities Desk',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        tags: ['Gold', 'Commodities', 'Safe Haven'],
      ),
    ];
  }

  // Message Methods
  Future<MessagesResponse> getMessages() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/messages_endpoint.php'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return MessagesResponse.fromJson(data);
      } else {
        throw Exception('Failed to get messages: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to get messages: $e');
      // Return mock message data on error
      return MessagesResponse(
        success: true,
        messages: _generateMockMessages(),
        unreadCount: 1,
        totalCount: 8,
        source: 'mock',
        note: 'Error connecting to server. Showing demo message data.',
        connected: false,
        error: e.toString(),
      );
    }
  }

  Future<Map<String, dynamic>> sendMessage({
    required String to,
    required String subject,
    required String text,
    String type = 'mail',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/messages_endpoint.php'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'to': to,
          'subject': subject,
          'text': text,
          'type': type,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to send message: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to send message: $e');
      // Return mock success response
      return {
        'success': true,
        'message': 'Message would be sent (server not available)',
        'source': 'mock',
        'note':
            'This is a demo response. In production, MT5 server would be required.',
      };
    }
  }

  List<Message> _generateMockMessages() {
    return [
      Message(
        id: '1',
        title: 'Welcome to MetaTrader 5',
        content:
            'Thank you for choosing MetaTrader 5. Your account has been successfully activated and you can now start trading.',
        sender: 'MetaQuotes Ltd.',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        isRead: false,
        type: 'system',
        priority: 'high',
      ),
      Message(
        id: '2',
        title: 'Risk Warning',
        content:
            'Trading in financial markets involves substantial risk of loss and is not suitable for all investors.',
        sender: 'Trading Platform',
        timestamp: DateTime.now().subtract(const Duration(hours: 6)),
        isRead: true,
        type: 'notification',
        priority: 'high',
      ),
      Message(
        id: '3',
        title: 'Rent High-Speed Hosting for 24/7 Automated Trading',
        content:
            'Boost your trading performance with our high-speed hosting solutions. Perfect for Expert Advisors.',
        sender: 'Trading Platform',
        timestamp: DateTime.now().subtract(const Duration(hours: 12)),
        isRead: true,
        type: 'promotion',
        priority: 'medium',
      ),
      Message(
        id: '4',
        title: 'Order Your Own Robot According to Your Strategy',
        content:
            'Custom Expert Advisors tailored to your trading strategy. Our development team can create automated solutions.',
        sender: 'Trading Platform',
        timestamp: DateTime.now().subtract(const Duration(hours: 18)),
        isRead: true,
        type: 'promotion',
        priority: 'medium',
      ),
      Message(
        id: '5',
        title: 'Robots and Indicators Can Improve Your Trading',
        content:
            'Discover how automated trading tools and technical indicators can enhance your trading performance.',
        sender: 'Trading Platform',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
        type: 'educational',
        priority: 'low',
      ),
      Message(
        id: '6',
        title: 'Copy Signals of Successful Traders',
        content:
            'Join our copy trading platform and automatically replicate the trades of experienced traders.',
        sender: 'Trading Platform',
        timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 6)),
        isRead: true,
        type: 'promotion',
        priority: 'medium',
      ),
      Message(
        id: '7',
        title: 'Welcome to the Trading Platform',
        content:
            'Welcome to our advanced trading platform! We\'re excited to have you on board.',
        sender: 'Trading Platform',
        timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 12)),
        isRead: true,
        type: 'system',
        priority: 'low',
      ),
      Message(
        id: '8',
        title: 'Create Your Own Trading App',
        content:
            'Build custom trading applications with our API. Integrate real-time market data and execute trades.',
        sender: 'Trading Platform',
        timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 18)),
        isRead: true,
        type: 'promotion',
        priority: 'low',
      ),
    ];
  }

  // Journal Methods
  Future<JournalResponse> getJournalLogs() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/journal_endpoint.php'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return JournalResponse.fromJson(data);
      } else {
        throw Exception('Failed to get journal logs: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to get journal logs: $e');
      // Return mock journal data on error
      return JournalResponse(
        success: true,
        logs: _generateMockJournalLogs(),
        totalCount: 30,
        date: DateTime.now().toIso8601String().substring(0, 10),
        startTime: '09:00:00',
        endTime: '10:00:00',
        source: 'mock',
        note: 'Error connecting to server. Showing demo journal data.',
        connected: false,
        error: e.toString(),
      );
    }
  }

  List<JournalEntry> _generateMockJournalLogs() {
    return [
      JournalEntry(
        id: '1',
        timestamp:
            DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
        time: '09:05:28.992',
        type: 'Terminal',
        message: 'MetaTrader 5 for Android',
        level: 'info',
      ),
      JournalEntry(
        id: '2',
        timestamp: DateTime.now()
            .subtract(const Duration(hours: 1, seconds: -3))
            .toIso8601String(),
        time: '09:05:28.995',
        type: 'Terminal',
        message: 'Copyright 2000-2025, MetaQuotes Ltd',
        level: 'info',
      ),
      JournalEntry(
        id: '3',
        timestamp: DateTime.now()
            .subtract(const Duration(hours: 1, seconds: -3))
            .toIso8601String(),
        time: '09:05:28.995',
        type: 'Terminal',
        message:
            'Loading native library. Version 500 Build 4982 Rev. 15382 (google)',
        level: 'info',
      ),
      JournalEntry(
        id: '4',
        timestamp: DateTime.now()
            .subtract(const Duration(hours: 1, seconds: -12))
            .toIso8601String(),
        time: '09:05:29.004',
        type: 'Terminal',
        message: 'Native library loaded.',
        level: 'info',
      ),
      JournalEntry(
        id: '5',
        timestamp: DateTime.now()
            .subtract(const Duration(hours: 1, seconds: -120))
            .toIso8601String(),
        time: '09:05:29.112',
        type: 'Activity',
        message: 'onCreate',
        level: 'debug',
      ),
      // ... more mock entries ...
    ];
  }

  // Response and Error Handling
  dynamic _handleResponse(Response response) {
    if (response.statusCode! >= 200 && response.statusCode! < 300) {
      return response.data;
    }
    throw ApiException(
      response.data['message'] ?? 'An error occurred',
      statusCode: response.statusCode,
      data: response.data,
    );
  }

  ApiException _handleError(dynamic error) {
    if (error is ApiException) {
      return error;
    }
    if (error is DioException) {
      return ApiException(
        error.response?.data['message'] ?? 'Network error occurred',
        statusCode: error.response?.statusCode,
        data: error.response?.data,
      );
    }
    return ApiException(error.toString());
  }
}

// Auth Interceptor for automatic token management
class _AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;

  _AuthInterceptor(this._storage);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read(key: 'auth_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Handle token expiration or invalid token
      _storage.delete(key: 'auth_token');
    }
    handler.next(err);
  }
}

class ApiService {
  static const String baseUrl =
      'http://localhost:8000'; // Local PHP development server

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Authentication methods
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }

  Future<Map<String, dynamic>> register(RegisterModel model) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(model.toJson()),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Registration failed');
      }
    } catch (e) {
      throw Exception('Registration error: $e');
    }
  }

  Future<void> logout() async {
    // In a real app, you might want to call a logout endpoint
    await clearStoredToken();
  }

  // Token storage methods
  Future<void> storeToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<String?> getStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> clearStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // User profile methods
  Future<Map<String, dynamic>> getUserProfile() async {
    // For now, return mock data. In a real app, this would fetch from the server
    return {
      'login': 'testuser',
      'email': 'test@example.com',
      'name': 'Test User',
      'phone': '+1234567890',
      'country': 'USA',
      'city': 'New York',
      'zipCode': '10001',
      'isActive': true,
      'createdAt': '2024-01-01T00:00:00Z'
    };
  }

  // MT5 API methods
  Future<Map<String, dynamic>> connectToMT5({
    required String serverIp,
    required int serverPort,
    required String login,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/connect.php'),
        body: {
          'server_ip': serverIp,
          'server_port': serverPort.toString(),
          'login': login,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to connect: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }

  Future<Map<String, dynamic>> getAccountInfo(String login) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/account_info.php?login=$login'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get account info: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting account info: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getSymbols() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/symbols.php'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to get symbols: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting symbols: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getOpenPositions(String login) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/positions.php?login=$login'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to get positions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting positions: $e');
    }
  }
}
