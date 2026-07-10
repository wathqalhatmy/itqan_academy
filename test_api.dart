import 'package:dio/dio.dart';
import 'dart:convert';

void main() async {
  print("🚀 Starting API diagnostic test...");
  final dio = Dio(BaseOptions(
    baseUrl: 'http://127.0.0.1:8000/api/v1',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  try {
    print("🔑 Authenticating as admin/admin (default setup test)...");
    final loginRes = await dio.post('/login/', data: {
      'username': 'admin',
      'password': 'password123', // Adjust password as needed
    });
    
    final token = loginRes.data['access'];
    print("✅ Authenticated. Access Token: ${token.substring(0, 15)}...");

    dio.options.headers['Authorization'] = 'Bearer $token';

    print("\n--- Testing GET /circles/ ---");
    final circlesRes = await dio.get('/circles/');
    print("Status: ${circlesRes.statusCode}");
    print("Data: ${jsonEncode(circlesRes.data)}");

    print("\n--- Testing GET /students/ ---");
    final studentsRes = await dio.get('/students/');
    print("Status: ${studentsRes.statusCode}");
    print("Data: ${jsonEncode(studentsRes.data)}");

    if (circlesRes.data is List && (circlesRes.data as List).isNotEmpty) {
      final circleId = circlesRes.data[0]['id'];
      print("\n--- Testing GET /circles/$circleId/students/ ---");
      final circleStudentsRes = await dio.get('/circles/$circleId/students/');
      print("Status: ${circleStudentsRes.statusCode}");
      print("Data: ${jsonEncode(circleStudentsRes.data)}");
    }

    print("\n🏁 Diagnostic complete successfully!");
  } catch (e) {
    print("\n❌ Diagnostic failed with error:");
    if (e is DioException) {
      print("DioException [${e.type}]: ${e.message}");
      print("Response: ${e.response?.data}");
    } else {
      print(e);
    }
  }
}
