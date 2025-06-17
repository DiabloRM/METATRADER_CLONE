import 'dart:async';
import 'package:signalr_netcore/signalr_client.dart';
import '../models/trading_models.dart';

class QuotesWebSocketService {
  final HubConnection _hubConnection;
  final Function(List<MarketData>) onQuotesReceived;
  final Function(MarketData) onQuoteUpdate;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int maxReconnectAttempts = 5;
  static const Duration reconnectDelay = Duration(seconds: 5);

  QuotesWebSocketService({
    required this.onQuotesReceived,
    required this.onQuoteUpdate,
  }) : _hubConnection = HubConnectionBuilder()
            .withUrl('http://localhost:5000/hubs/quotes',
                options: HttpConnectionOptions(
                  skipNegotiation: true,
                  transport: HttpTransportType.WebSockets,
                ))
            .withAutomaticReconnect()
            .build() {
    _setupHubConnection();
  }

  void _setupHubConnection() {
    _hubConnection.on('ReceiveQuotes', (arguments) {
      if (arguments != null) {
        try {
          final List<dynamic> quotesJson = arguments;
          final quotes = quotesJson
              .map((json) => MarketData.fromJson(json as Map<String, dynamic>))
              .toList();
          onQuotesReceived(quotes);
        } catch (e) {
          print('Error processing quotes: $e');
        }
      }
    });

    _hubConnection.on('ReceiveQuoteUpdate', (arguments) {
      if (arguments != null) {
        try {
          final quote = MarketData.fromJson(arguments as Map<String, dynamic>);
          onQuoteUpdate(quote);
        } catch (e) {
          print('Error processing quote update: $e');
        }
      }
    });

    _hubConnection.onclose(({Exception? error}) {
      print('WebSocket connection closed${error != null ? ': $error' : ''}');
      _scheduleReconnect();
    });
  }

  void _scheduleReconnect() {
    if (_reconnectTimer != null) return;

    _reconnectTimer = Timer(reconnectDelay, () async {
      if (_reconnectAttempts < maxReconnectAttempts) {
        _reconnectAttempts++;
        print(
            'Attempting to reconnect (${_reconnectAttempts}/$maxReconnectAttempts)...');
        await connect();
      } else {
        print('Max reconnection attempts reached');
      }
      _reconnectTimer = null;
    });
  }

  Future<void> connect() async {
    try {
      await _hubConnection.start();
      _reconnectAttempts = 0;
      print('WebSocket connected successfully');
    } catch (e) {
      print('Error connecting to WebSocket: $e');
      _scheduleReconnect();
      rethrow;
    }
  }

  Future<void> disconnect() async {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    await _hubConnection.stop();
  }

  Future<void> subscribeToSymbol(String symbol) async {
    try {
      await _hubConnection.invoke('SubscribeToSymbol', args: [symbol]);
      print('Subscribed to symbol: $symbol');
    } catch (e) {
      print('Error subscribing to symbol: $e');
      rethrow;
    }
  }

  Future<void> unsubscribeFromSymbol(String symbol) async {
    try {
      await _hubConnection.invoke('UnsubscribeFromSymbol', args: [symbol]);
      print('Unsubscribed from symbol: $symbol');
    } catch (e) {
      print('Error unsubscribing from symbol: $e');
      rethrow;
    }
  }
}
