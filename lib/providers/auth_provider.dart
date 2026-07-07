import 'package:flutter/material.dart';

enum AuthStatus {
  unauthenticated,
  authenticating,
  authenticated,
}

class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.unauthenticated;
  String? _userName;

  AuthStatus get status => _status;
  String? get userName => _userName;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  Future<bool> login(String email, String password) async {
    _status = AuthStatus.authenticating;
    notifyListeners();

    // محاكاة عملية الاتصال بالباك اند
    await Future.delayed(const Duration(seconds: 2));

    // تجربة: الدخول ناجح دائماً حالياً لأي بيانات
    if (email.isNotEmpty && password.length >= 6) {
      _status = AuthStatus.authenticated;
      _userName = 'مدير الأكاديمية';
      notifyListeners();
      return true;
    }

    _status = AuthStatus.unauthenticated;
    notifyListeners();
    return false;
  }

  void logout() {
    _status = AuthStatus.unauthenticated;
    _userName = null;
    notifyListeners();
  }
}
