import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/api_client.dart';
import '../models/user_model.dart';
import 'dart:developer';

class AuthRepository {
  final ApiClient _api = ApiClient();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<UserModel?> login(String email, String password) async {
  try {
    final response = await _api.dio.post('/auth/login', data: {
      'email': email,
      'password': password,
      'device_name': 'mobile_app',
    });

    print("LOGIN RESPONSE: ${response.data}");

    if (response.statusCode == 200) {
      final data = response.data;

      // simpan token
      final token =
        data['token'] ??
        data['access_token'] ??
        data['data']?['token'] ??
        data['data']?['access_token'];

      print("TOKEN FROM API: $token");
      if (token != null) {
        await _storage.write(key: 'auth_token', value: token);
      }

      // ambil user (support banyak kemungkinan struktur)
      final userJson =
          data['user'] ??
          data['data']?['user'] ??
          data;

      return UserModel.fromJson(userJson);
    }

    return null;
  } on DioException catch (e) {
    print('Login failed: ${e.response?.data}');
    throw Exception(e.response?.data['message'] ?? 'Failed to login');
  }
}

  Future<UserModel?> getMe() async {
  try {
    final token = await _storage.read(key: 'auth_token');
    print("TOKEN: $token");

    if (token == null) return null;

    final response = await _api.dio.get('/auth/me');

    print("GET ME RESPONSE: ${response.data}");

    if (response.statusCode == 200) {
      final data = response.data;

      final userJson =
          data['user'] ??
          data['data']?['user'] ??
          data;

      return UserModel.fromJson(userJson);
    }

    return null;
  } catch (e) {
    log('Error getting user: $e');
    return null;
  }
}
  Future<void> logout() async {
    try {
      await _api.dio.post('/auth/logout');
    } catch (e) {
      log('Logout API call failed, still clearing local token.');
    } finally {
      await _storage.delete(key: 'auth_token');
    }
  }
}
