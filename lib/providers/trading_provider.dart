import 'package:flutter/foundation.dart';
import '../services/trading_service.dart';
import '../models/trading_models.dart';

class TradingProvider with ChangeNotifier {
  final TradingService _tradingService;
  AccountInfo? _accountInfo;
  List<Order> _openOrders = [];
  List<Order> _orderHistory = [];
  List<Position> _openPositions = [];
  Map<String, double> _symbolPrices = {};
  bool _isLoading = false;
  String? _error;

  TradingProvider(this._tradingService);

  // Getters
  AccountInfo? get accountInfo => _accountInfo;
  List<Order> get openOrders => _openOrders;
  List<Order> get orderHistory => _orderHistory;
  List<Position> get openPositions => _openPositions;
  Map<String, double> get symbolPrices => _symbolPrices;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize trading data
  Future<void> initialize() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await Future.wait([
        _loadAccountInfo(),
        _loadOpenOrders(),
        _loadOrderHistory(),
        _loadOpenPositions(),
      ]);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load account information
  Future<void> _loadAccountInfo() async {
    try {
      _accountInfo = await _tradingService.getAccountInfo();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load account info: ${e.toString()}';
      notifyListeners();
    }
  }

  // Load open orders
  Future<void> _loadOpenOrders() async {
    try {
      _openOrders = await _tradingService.getOpenOrders();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load open orders: ${e.toString()}';
      notifyListeners();
    }
  }

  // Load order history
  Future<void> _loadOrderHistory() async {
    try {
      _orderHistory = await _tradingService.getOrderHistory();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load order history: ${e.toString()}';
      notifyListeners();
    }
  }

  // Load open positions
  Future<void> _loadOpenPositions() async {
    try {
      _openPositions = await _tradingService.getOpenPositions();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load open positions: ${e.toString()}';
      notifyListeners();
    }
  }

  // Create a new order
  Future<Order> createOrder(CreateOrderRequest request) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final order = await _tradingService.createOrder(request);
      await _loadOpenOrders(); // Refresh open orders
      await _loadAccountInfo(); // Refresh account info

      _isLoading = false;
      notifyListeners();
      return order;
    } catch (e) {
      _error = 'Failed to create order: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Modify an existing order
  Future<Order> modifyOrder(String orderId, ModifyOrderRequest request) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final order = await _tradingService.modifyOrder(orderId, request);
      await _loadOpenOrders(); // Refresh open orders

      _isLoading = false;
      notifyListeners();
      return order;
    } catch (e) {
      _error = 'Failed to modify order: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Cancel an order
  Future<void> cancelOrder(String orderId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _tradingService.cancelOrder(orderId);
      await _loadOpenOrders(); // Refresh open orders

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to cancel order: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Close a position
  Future<void> closePosition(String positionId,
      {ClosePositionRequest? request}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _tradingService.closePosition(positionId, request: request);
      await _loadOpenPositions(); // Refresh open positions
      await _loadAccountInfo(); // Refresh account info

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to close position: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Modify a position
  Future<Position> modifyPosition(
      String positionId, ModifyOrderRequest request) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final position =
          await _tradingService.modifyPosition(positionId, request);
      await _loadOpenPositions(); // Refresh open positions

      _isLoading = false;
      notifyListeners();
      return position;
    } catch (e) {
      _error = 'Failed to modify position: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Get symbol price
  Future<double> getSymbolPrice(String symbol) async {
    try {
      final price = await _tradingService.getSymbolPrice(symbol);
      _symbolPrices[symbol] = price;
      notifyListeners();
      return price;
    } catch (e) {
      _error = 'Failed to get symbol price: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  // Get prices for multiple symbols
  Future<Map<String, double>> getSymbolPrices(List<String> symbols) async {
    try {
      final prices = await _tradingService.getSymbolPrices(symbols);
      _symbolPrices.addAll(prices);
      notifyListeners();
      return prices;
    } catch (e) {
      _error = 'Failed to get symbol prices: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
