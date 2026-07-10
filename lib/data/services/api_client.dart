import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  // Singleton pattern
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late Dio dio;
  final _storage = const FlutterSecureStorage();
  
  // Callback when session is completely expired (e.g., refresh token fails or is expired)
  VoidCallback? onSessionExpired;

  // Flag to prevent infinite refresh loops or concurrent refreshes
  bool _isRefreshing = false;

  // نستخدم localhost مع أمر adb reverse tcp:8000 tcp:8000
  static String get baseUrl => 'http://127.0.0.1:8000/api/v1';

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        responseType: ResponseType.json,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'jwt_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          debugPrint('🚀 Sending [${options.method}] to: ${options.uri}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint('✅ Response [${response.statusCode}] from: ${response.requestOptions.uri}');
          return handler.next(response);
        },
        onError: (DioException e, handler) async {
          debugPrint('❌ API Error: [${e.type}] - ${e.message}');
          if (e.response != null) {
            debugPrint('📦 Error Details: ${e.response?.data}');
          }

          // Check if response is 401 Unauthorized
          if (e.response?.statusCode == 401) {
            final refreshToken = await _storage.read(key: 'refresh_token');
            if (refreshToken != null && !_isRefreshing) {
              _isRefreshing = true;
              try {
                debugPrint('🔄 Attempting to refresh token using refresh_token...');
                
                // Create a separate clean Dio instance to call the token refresh endpoint
                // and avoid triggering interceptor loops.
                final refreshDio = Dio(
                  BaseOptions(
                    baseUrl: baseUrl,
                    connectTimeout: const Duration(seconds: 10),
                    receiveTimeout: const Duration(seconds: 10),
                  ),
                );

                final response = await refreshDio.post('/token/refresh/', data: {
                  'refresh': refreshToken,
                });

                if (response.statusCode == 200) {
                  final newAccessToken = response.data['access'];
                  debugPrint('🔑 Token refreshed successfully. Saving new access token...');
                  
                  await _storage.write(key: 'jwt_token', value: newAccessToken);
                  _isRefreshing = false;

                  // Retry the original request with the new token
                  final options = e.requestOptions;
                  options.headers['Authorization'] = 'Bearer $newAccessToken';
                  
                  // Clone and execute the request
                  final cloneReq = await dio.request(
                    options.path,
                    data: options.data,
                    queryParameters: options.queryParameters,
                    options: Options(
                      method: options.method,
                      headers: options.headers,
                    ),
                  );
                  
                  return handler.resolve(cloneReq);
                }
              } catch (refreshError) {
                debugPrint('❌ Token refresh failed: $refreshError');
              } finally {
                _isRefreshing = false;
              }
            }

            // If we reach here, either refresh failed, or there is no refresh token, or we are already refreshing.
            // Trigger logout and session expiry.
            debugPrint('🚨 Session expired or invalid. Clearing tokens and logging out...');
            await _storage.delete(key: 'jwt_token');
            await _storage.delete(key: 'refresh_token');
            await _storage.delete(key: 'user_name');
            
            if (onSessionExpired != null) {
              onSessionExpired!();
            }
          }

          return handler.next(e);
        },
      ),
    );
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    return await dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) async {
    return await dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) async {
    return await dio.put(path, data: data);
  }

  Future<Response> delete(String path) async {
    return await dio.delete(path);
  }
}
