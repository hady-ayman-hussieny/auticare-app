import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:auticare/core/constants/app_constants.dart';

class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  static const _storage = FlutterSecureStorage();

  late final Dio _dio = _buildDio();

  Dio get dio => _dio;

  Dio _buildDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: const Duration(milliseconds: AppConstants.connectTimeoutMs),
        receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeoutMs),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // Request interceptor – attach Bearer token
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          final status = error.response?.statusCode;

          // Build a readable message from the response body (mirrors web app)
          final data = error.response?.data;
          String? apiMsg;
          if (data is Map) {
            apiMsg = (data['message'] ?? data['error'] ?? data['title'])?.toString();
            if (apiMsg == null && data['errors'] is Map) {
              final first = (data['errors'] as Map).values.firstOrNull;
              if (first is List && first.isNotEmpty) apiMsg = first.first.toString();
            }
          }

          if (status == 401) {
            await _storage.delete(key: 'token');
            await _storage.delete(key: 'user');
          }

          // Wrap with a clean message
          final msg = apiMsg ?? error.message ?? 'An unknown error occurred';
          return handler.next(
            DioException(
              requestOptions: error.requestOptions,
              response: error.response,
              type: error.type,
              error: error.error,
              message: msg,
            ),
          );
        },
      ),
    );

    return dio;
  }

  /// Convenience helpers
  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? params}) =>
      _dio.get<T>(path, queryParameters: params);

  Future<Response<T>> post<T>(String path, {dynamic data}) =>
      _dio.post<T>(path, data: data);

  Future<Response<T>> put<T>(String path, {dynamic data}) =>
      _dio.put<T>(path, data: data);

  Future<Response<T>> patch<T>(String path, {dynamic data}) =>
      _dio.patch<T>(path, data: data);

  Future<Response<T>> delete<T>(String path) => _dio.delete<T>(path);
}

/// Shorthand
final api = ApiClient.instance;
