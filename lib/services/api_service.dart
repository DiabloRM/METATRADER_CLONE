import 'package:dio/dio.dart';
import '../models/register_model.dart';
import '../models/mt5_settings.dart';

class MetaQuotesApiService {
  final Dio _dio;
  final String baseUrl;

  MetaQuotesApiService({required this.baseUrl})
      : _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 5),
            receiveTimeout: const Duration(seconds: 3),
          ),
        );

  // Authentication
  Future<Map<String, dynamic>> register(RegisterModel model) async {
    try {
      final response = await _dio.post(
        '/api/auth/register',
        data: model.toJson(),
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/api/auth/login',
        data: {'email': email, 'password': password},
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // MT5 Connection
  Future<void> connectToMT5(MT5Settings settings) async {
    try {
      final response = await _dio.post(
        '/api/mt5/connect',
        data: settings.toJson(),
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Error handling
  Exception _handleError(dynamic error) {
    if (error is DioException) {
      return Exception(error.response?.data['message'] ?? 'An error occurred');
    }
    return Exception('An unexpected error occurred');
  }
}
