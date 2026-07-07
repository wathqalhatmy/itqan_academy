import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../data/services/api_client.dart';

enum AuthStatus {
  unauthenticated,
  authenticating,
  authenticated,
}

class AuthProvider extends ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  final _apiClient = ApiClient(); // يمكن تمريره عبر Constructor للحقن (Injection)

  AuthStatus _status = AuthStatus.unauthenticated;
  String? _userName;
  String? _token;

  AuthStatus get status => _status;
  String? get userName => _userName;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  AuthProvider() {
    _checkExistingToken();
  }

  /// التحقق من وجود توكن محفوظ عند تشغيل التطبيق (Auto Login)
  Future<void> _checkExistingToken() async {
    _token = await _storage.read(key: 'jwt_token');
    if (_token != null) {
      // هنا يفضل التحقق من صلاحية التوكن عبر طلب بسيط للباك اند
      _status = AuthStatus.authenticated;
      _userName = await _storage.read(key: 'user_name') ?? 'مستخدم';
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _status = AuthStatus.authenticating;
    notifyListeners();

    try {
      // ملاحظة: هذا الكود يفترض وجود Endpoint في جانجو باسم /login/
      // ويعيد بيانات تحتوي على access token
      /*
      final response = await _apiClient.post('/login/', data: {
        'username': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final token = response.data['access'];
        final user = response.data['user_display_name'];
        
        await _storage.write(key: 'jwt_token', value: token);
        await _storage.write(key: 'user_name', value: user);
        
        _token = token;
        _userName = user;
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      }
      */

      // حالياً سنبقي على المحاكاة لضمان عمل التطبيق حتى تجهيز الباك اند
      await Future.delayed(const Duration(seconds: 1));
      if (email.isNotEmpty && password.length >= 6) {
        const mockToken = 'mock_jwt_token_for_itqan';
        const mockUser = 'مدير الأكاديمية';
        
        await _storage.write(key: 'jwt_token', value: mockToken);
        await _storage.write(key: 'user_name', value: mockUser);
        
        _token = mockToken;
        _userName = mockUser;
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Login error: $e');
    }

    _status = AuthStatus.unauthenticated;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    await _storage.deleteAll();
    _token = null;
    _userName = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
