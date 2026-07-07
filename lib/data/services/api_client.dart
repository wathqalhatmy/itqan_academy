import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  late Dio dio;
  final _storage = const FlutterSecureStorage();
  
  // استخدم 10.0.2.2 بدلاً من 127.0.0.1 للعمل على محاكي أندرويد
  static const String baseUrl = 'http://10.0.2.2:8000/api/v1';

  ApiClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        responseType: ResponseType.json,
      ),
    );

    // إضافة الـ Interceptors لإدارة التوكن والأخطاء بشكل تلقائي
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // جلب التوكن من التخزين الآمن
          final token = await _storage.read(key: 'jwt_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          if (e.response?.statusCode == 401) {
            // هنا يمكن إضافة منطق تسجيل الخروج التلقائي عند انتهاء صلاحية التوكن
            print('Unauthorized: Token expired or invalid');
          }
          return handler.next(e);
        },
      ),
    );
  }

  // دوال مساعدة لتسهيل الطلبات
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
