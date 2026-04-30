import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/data/services/api_service.dart';
import 'package:my_app/data/services/token_storage.dart';

final authProvider = ChangeNotifierProvider<AuthNotifier>((ref) {
  return AuthNotifier(
    ref.read(apiServiceProvider),
    ref.read(tokenStorageProvider),
  );
});

enum AuthStatus { unauthenticated, verifying, authenticated }

class AuthNotifier extends ChangeNotifier {
  final ApiService _api;
  final TokenStorage _storage;

  AuthNotifier(this._api, this._storage);

  AuthStatus _status = AuthStatus.unauthenticated;
  String? _phone;
  String? _role;
  String? _error;

  AuthStatus get status => _status;
  String? get phone => _phone;
  String? get role => _role;
  String? get error => _error;
  bool get isAdmin => _role == 'admin';
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  /// Called on cold start — restores session from secure storage.
  Future<void> restoreSession() async {
    final token = await _storage.read();
    if (token != null) {
      // Token exists; treat as authenticated until the server says otherwise.
      _status = AuthStatus.authenticated;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    String? phone,
    required String password,
  }) async {
    _error = null;
    notifyListeners();
    try {
      await _api.register(name: name, email: email, phone: phone, password: password);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> login({
    required String identifier,
    required String password,
  }) async {
    _error = null;
    _status = AuthStatus.verifying;
    notifyListeners();
    try {
      final res = await _api.login(identifier: identifier, password: password);
      await _storage.save(res['token'] as String);
      _role = res['role'] as String?;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<void> requestOtp(String phone) async {
    _error = null;
    _phone = phone;
    _status = AuthStatus.verifying;
    notifyListeners();
    try {
      await _api.requestOtp(phone);
    } catch (e) {
      _error = e.toString();
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }
  }

  Future<bool> verifyOtp(String code) async {
    _error = null;
    notifyListeners();
    try {
      final res = await _api.verifyOtp(_phone!, code);
      await _storage.save(res['token'] as String);
      _role = res['role'] as String?;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _storage.clear();
    _status = AuthStatus.unauthenticated;
    _phone = null;
    _role = null;
    notifyListeners();
  }
}
