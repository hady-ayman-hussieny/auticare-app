import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:auticare/data/models/user.dart';
import 'package:auticare/data/services/api_client.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();

  Future<AuthResponse> login(String email, String password) async {
    final res = await api.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    final auth = AuthResponse.fromJson(res.data!);
    await _persist(auth);
    return auth;
  }

  Future<AuthResponse> signup(Map<String, dynamic> payload) async {
    final res = await api.post<Map<String, dynamic>>(
      '/auth/register',
      data: payload,
    );
    final auth = AuthResponse.fromJson(res.data!);
    if (auth.token.isNotEmpty) await _persist(auth);
    return auth;
  }

  Future<void> forgotPassword(String email) async {
    await api.post('/auth/forgot-password', data: {'email': email});
  }

  Future<void> logout() async {
    try {
      await api.post('/auth/logout');
    } catch (_) {}
    await _storage.delete(key: 'token');
    await _storage.delete(key: 'user');
    await _storage.delete(key: 'role');
  }

  Future<UserModel?> getProfile() async {
    try {
      final res = await api.get<Map<String, dynamic>>('/profile');
      return UserModel.fromJson(res.data!);
    } catch (_) {
      return null;
    }
  }

  Future<UserModel?> loadCachedUser() async {
    final raw = await _storage.read(key: 'user');
    if (raw == null || raw.isEmpty) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return UserModel.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  Future<void> _persist(AuthResponse auth) async {
    await _storage.write(key: 'token', value: auth.token);
    await _storage.write(key: 'user', value: jsonEncode(auth.user.toJson()));
    await _storage.write(key: 'role', value: auth.user.role);
  }
}

final authService = AuthService();
