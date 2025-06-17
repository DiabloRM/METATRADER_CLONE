import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/trading_models.dart';
import 'api_service.dart';
import '../config/api_config.dart';

class TradingService {
  final MetaQuotesApiService _apiService;
  final Dio _dio;
  static const String _basePath = '/trading';
  late final String _baseUrl;

  TradingService(this._apiService) : _dio = Dio() {
    _baseUrl = _getBaseUrl();
    _configureDio();
  }

  String _getBaseUrl() {
    if (!ApiConfig.useLocalhost) {
      return ApiConfig.baseUrl;
    }

    if (kIsWeb) {
      return 'http://localhost:5000/api';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:5000/api'; // Android emulator localhost
    } else if (Platform.isIOS) {
      return Platform.environment.containsKey('FLUTTER_TEST')
          ? 'http://localhost:5000/api'
          : 'http://127.0.0.1:5000/api';
    }
    return 'http://localhost:5000/api';
  }

  void _configureDio() {
    _dio.options
      ..baseUrl = _baseUrl
      ..connectTimeout = const Duration(seconds: 30)
      ..receiveTimeout = const Duration(seconds: 30)
      ..validateStatus = (status) => status != null && status < 500;

    // Add interceptors for logging and token management
    _dio.interceptors.addAll([
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (object) => print(object.toString()),
      ),
    ]);
  }

  Future<AccountInfo> getAccountInfo() async {
    try {
      return await _apiService.getAccountInfo();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Order> createOrder(CreateOrderRequest request) async {
    try {
      final response = await _dio.post(
        '$_basePath/orders',
        data: request.toJson(),
      );
      return Order.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Order> modifyOrder(String orderId, ModifyOrderRequest request) async {
    try {
      final response = await _dio.put(
        '$_basePath/orders/$orderId',
        data: request.toJson(),
      );
      return Order.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> cancelOrder(String orderId) async {
    try {
      await _dio.delete('$_basePath/orders/$orderId');
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Order>> getOpenOrders() async {
    try {
      final response = await _dio.get('$_basePath/orders/open');
      final List<dynamic> data = response.data;
      return data.map((json) => Order.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Order>> getOrderHistory({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String();
      }

      final response = await _dio.get(
        '$_basePath/orders/history',
        queryParameters: queryParams,
      );
      final List<dynamic> data = response.data;
      return data.map((json) => Order.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Position>> getOpenPositions() async {
    try {
      return await _apiService.getOpenPositions();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> closePosition(String positionId,
      {ClosePositionRequest? request}) async {
    try {
      await _dio.post(
        '$_basePath/positions/$positionId/close',
        data: request?.toJson(),
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Position> modifyPosition(
    String positionId,
    ModifyOrderRequest request,
  ) async {
    try {
      final response = await _dio.put(
        '$_basePath/positions/$positionId',
        data: request.toJson(),
      );
      return Position.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<double> getSymbolPrice(String symbol) async {
    try {
      final response = await _dio.get('$_basePath/prices/$symbol');
      return (response.data['price'] as num).toDouble();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, double>> getSymbolPrices(List<String> symbols) async {
    try {
      final response = await _dio.post(
        '$_basePath/prices/batch',
        data: {'symbols': symbols},
      );
      return Map<String, double>.from(
        (response.data as Map<String, dynamic>).map(
          (key, value) => MapEntry(key, (value as num).toDouble()),
        ),
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  ApiException _handleError(dynamic error) {
    if (error is DioException) {
      final data = error.response?.data;
      final message =
          data is Map ? data['message'] ?? error.message : error.message;
      return ApiException(
        message.toString(),
        statusCode: error.response?.statusCode,
        data: data,
      );
    }
    return ApiException(error.toString());
  }
}
