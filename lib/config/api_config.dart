class ApiConfig {
  static const String baseUrl = 'http://localhost:5124';
  static const String mt5ApiUrl = 'http://localhost:8000/api'; // PHP MT5 API

  // Environment configuration
  static const bool useLocalhost = true; // Set to false for production

  // Timeout configurations
  static const int connectTimeout = 30; // 30 seconds
  static const int receiveTimeout = 30; // 30 seconds

  // Auth endpoints
  static const String loginEndpoint = '/api/auth/login';
  static const String registerEndpoint = '/api/auth/register';

  // User endpoints
  static const String userAccountEndpoint = '/api/user/account';
  static const String userPositionsEndpoint = '/api/user/positions';

  // Trading endpoints
  static const String quotesEndpoint = '/api/trading/quotes';
  static const String tradingEndpoint = '/api/trading/place';

  // MT5 API endpoints
  static const String mt5ConnectEndpoint = '/flutter_endpoints.php/connect';
  static const String mt5AccountEndpoint = '/flutter_endpoints.php/account';
  static const String mt5SymbolsEndpoint = '/flutter_endpoints.php/symbols';
  static const String mt5PositionsEndpoint = '/flutter_endpoints.php/positions';
  static const String mt5OrdersEndpoint = '/flutter_endpoints.php/orders';
  static const String mt5TimeEndpoint = '/flutter_endpoints.php/time';
  static const String mt5MessagesEndpoint = '/flutter_endpoints.php/messages';
  static const String mt5DisconnectEndpoint =
      '/flutter_endpoints.php/disconnect';

  static Map<String, String> getHeaders({String? token}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  static Map<String, String> getMT5Headers() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }
}
