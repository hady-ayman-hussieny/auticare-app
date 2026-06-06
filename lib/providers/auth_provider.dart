import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  AuthStatus _status = AuthStatus.unknown;
  bool _loading = false;
  String? _error;

  UserModel? get user => _user;
  AuthStatus get status => _status;
  bool get loading => _loading;
  String? get error => _error;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    try {
      // Try to restore session from secure storage
      final cached = await authService.loadCachedUser();
      if (cached != null) {
        _user = cached;
        _status = AuthStatus.authenticated;
        notifyListeners();
        // Refresh from backend in background
        final fresh = await authService.getProfile();
        if (fresh != null) {
          _user = fresh;
          notifyListeners();
        }
      } else {
        _status = AuthStatus.unauthenticated;
        notifyListeners();
      }
    } catch (_) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    _setLoading(true);
    _error = null;
    try {
      final auth = await authService.login(email, password);
      _user = auth.user;
      _status = AuthStatus.authenticated;
    } catch (e) {
      _error = _extractMessage(e);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signup(Map<String, dynamic> payload) async {
    _setLoading(true);
    _error = null;
    try {
      final auth = await authService.signup(payload);
      _user = auth.user;
      _status = AuthStatus.authenticated;
    } catch (e) {
      _error = _extractMessage(e);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> forgotPassword(String email) async {
    _setLoading(true);
    _error = null;
    try {
      await authService.forgotPassword(email);
    } catch (e) {
      _error = _extractMessage(e);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await authService.logout();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void updateUser(UserModel updated) {
    _user = updated;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  String _extractMessage(Object e) {
    if (e is Exception) return e.toString().replaceAll('Exception: ', '');
    return e.toString();
  }
}
