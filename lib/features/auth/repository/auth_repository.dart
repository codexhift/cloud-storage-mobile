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

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['token'] != null) {
          await _storage.write(key: 'auth_token', value: data['token']);
        }
        return UserModel.fromJson(data['user']);
      }
      return null;
    } on DioException catch (e) {
      log('Login failed: ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? 'Failed to login');
    }
  }

  Future<UserModel?> getMe() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) return null;

      final response = await _api.dio.get('/auth/me');
      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data['user']);
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await logout(); // Token expired or invalid
      }
      log('GetMe failed: ${e.response?.data}');
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
