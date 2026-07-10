import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../data/services/api_client.dart';

enum AuthStatus {
  checking,
  unauthenticated,
  authenticating,
  authenticated,
}

class AuthProvider extends ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  final _apiClient = ApiClient();

  AuthStatus _status = AuthStatus.checking;
  String? _userName;
  String? _token;

  AuthStatus get status => _status;
  String? get userName => _userName;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  AuthProvider() {
    _apiClient.onSessionExpired = () {
      logout();
    };
    _checkExistingToken();
  }

  Future<void> _checkExistingToken() async {
    try {
      _token = await _storage.read(key: 'jwt_token');
      if (_token != null) {
        _status = AuthStatus.authenticated;
        _userName = await _storage.read(key: 'user_name') ?? 'مستخدم';
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      debugPrint('Error checking existing token: $e');
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _status = AuthStatus.authenticating;
    notifyListeners();

    try {
      // الاتصال الحقيقي بسيرفر جانجو لجلب التوكن
      final response = await _apiClient.post('/login/', data: {
        'username': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final token = response.data['access'];
        final refreshToken = response.data['refresh'];
        final userDisplayName = response.data['name'] ?? 'مستخدم';
        
        await _storage.write(key: 'jwt_token', value: token);
        await _storage.write(key: 'refresh_token', value: refreshToken);
        await _storage.write(key: 'user_name', value: userDisplayName);
        
        _token = token;
        _userName = userDisplayName;
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
    await _storage.delete(key: 'jwt_token');
    await _storage.delete(key: 'refresh_token');
    await _storage.delete(key: 'user_name');
    _token = null;
    _userName = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
