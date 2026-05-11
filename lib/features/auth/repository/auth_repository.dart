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
    final response = await _api.dio.post('v1/auth/login', data: {
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

      log("FULL RESPONSE: ", response.data);

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
      await _api.dio.post('v1/auth/logout');
    } catch (e) {
      log('Logout API call failed, still clearing local token.');
    } finally {
      await _storage.delete(key: 'auth_token');
    }
  }
}

  // Custom exception for auth errors
  const String tokenKey = 'auth_token';
  const String rememberMeKey = 'remember_me';

  /// Login with email and password
  /// Returns UserModel on success, throws AuthException on failure
  Future<UserModel> login(
    String email,
    String password, {
    bool rememberMe = false,
  }) async {
    log('Attempting login for: $email');

    try {
      final response = await _api.dio.post(
        '/v1/auth/login',
        data: {
          'email': email,
          'password': password,
          'device_name': 'mobile_app',
        },
      );

      log('Login response status: ${response.statusCode}');
      log('Login response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;

        // Validate response structure
        if (data == null) {
          throw AuthException('Invalid response from server');
        }

        // Laravel format: data.token, data.user
        // Also handle: token, user (direct format)
        final responseData = data['data'] ?? data;
        final token = responseData['token'] ?? responseData['access_token'];
        if (token == null) {
          throw AuthException('No token received from server');
        }

        // Store token
        await _storage.write(key: tokenKey, value: token.toString());

        // Store remember me preference
        await _storage.write(key: rememberMeKey, value: rememberMe.toString());

        log('Token stored successfully');

        // Extract user data - handle Laravel format: data.data.user or data.user
        final userData =
            responseData['user'] ?? responseData['user_data'] ?? responseData;
        if (userData == null) {
          throw AuthException('No user data received from server');
        }

        return UserModel.fromJson(userData);
      }

      throw AuthException('Login failed with status: ${response.statusCode}');
    } on DioException catch (e) {
      log('Login DioException: ${e.type} - ${e.response?.statusCode}');
      log('Login error response: ${e.response?.data}');

      // Handle specific error cases
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final errorData = e.response!.data;

        // Laravel format: data.message or errors
        final message =
            errorData?['message'] ??
            errorData?['error'] ??
            errorData?['error_description'];

        // Extract validation errors if present
        String errorMessage = 'Login failed';
        if (message != null) {
          errorMessage = message.toString();
        } else if (errorData?['errors'] != null) {
          final errors = errorData['errors'] as Map<String, dynamic>;
          if (errors.isNotEmpty) {
            final firstField = errors.keys.first;
            final firstError = errors[firstField];
            if (firstError is List && firstError.isNotEmpty) {
              errorMessage = firstError[0].toString();
            }
          }
        }

        if (statusCode == 401) {
          throw AuthException(
            'Email atau password salah',
            isInvalidCredentials: true,
          );
        } else if (statusCode == 422) {
          throw AuthException(errorMessage, isValidationError: true);
        } else if (statusCode == 403) {
          throw AuthException('Akun Anda dinonaktifkan', isForbidden: true);
        }

        throw AuthException(errorMessage);
      }

      // Network errors
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw AuthException(
          'Koneksi timeout. Periksa koneksi internet Anda.',
          isNetworkError: true,
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw AuthException(
          'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
          isNetworkError: true,
        );
      }

      throw AuthException(
        'Terjadi kesalahan. Silakan coba lagi.',
        isNetworkError: true,
      );
    } catch (e) {
      if (e is AuthException) rethrow;
      log('Login unexpected error: $e');
      throw AuthException('Terjadi kesalahan yang tidak terduga');
    }
  }

  /// Get current user from stored token
  /// Returns UserModel if token is valid, null if not authenticated
  Future<UserModel?> getMe() async {
    try {
      final token = await _storage.read(key: tokenKey);
      if (token == null || token.isEmpty) {
        log('No token found in storage');
        return null;
      }

      log('Fetching user data with token...');
      final response = await _api.dio.get('/v1/auth/me');

      log('getMe response status: ${response.statusCode}');
      log('getMe response data: ${response.data}');

      if (response.statusCode == 200) {
        // Laravel format: data.data.user or data.user
        final data = response.data;
        final responseData = data['data'] ?? data;
        final userData = responseData['user'] ?? responseData;
        return UserModel.fromJson(userData);
      }

      return null;
    } on DioException catch (e) {
      log('getMe DioException: ${e.type} - ${e.response?.statusCode}');

      // Note: Token clearing moved to ApiClient interceptor for non-auth endpoints
      // For auth endpoints, let getMe() handle gracefully without auto-logout
      return null;
    } catch (e) {
      log('getMe unexpected error: $e');
      return null;
    }
  }

  /// Logout and clear stored token
  Future<void> logout() async {
    log('Logging out...');

    try {
      // Try to notify server (non-blocking)
      await _api.dio.post('/v1/auth/logout');
    } catch (e) {
      log('Logout API call failed (non-critical): $e');
    } finally {
      // Always clear local token
      await _storage.delete(key: tokenKey);
      await _storage.delete(key: rememberMeKey);
      log('Local tokens cleared');
    }
  }

  /// Check if user is logged in (has valid token)
  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: tokenKey);
    return token != null && token.isNotEmpty;
  }

  /// Get remember me preference
  Future<bool> getRememberMe() async {
    final value = await _storage.read(key: rememberMeKey);
    return value == 'true';
  }

  /// Register new user account
  /// Returns UserModel on success, throws AuthException on failure
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    log('Attempting registration for: $email');

    try {
      final response = await _api.dio.post(
        '/v1/auth/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password,
        },
      );

      log('Register response status: ${response.statusCode}');
      log('Register response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;

        if (data == null) {
          throw AuthException('Invalid response from server');
        }

        // Laravel format: data.token, data.user
        final responseData = data['data'] ?? data;
        final token = responseData['token'] ?? responseData['access_token'];
        if (token != null) {
          await _storage.write(key: tokenKey, value: token.toString());
          log('Token stored successfully');
        }

        // Extract user data
        final userData =
            responseData['user'] ?? responseData['user_data'] ?? responseData;
        if (userData == null) {
          throw AuthException('No user data received from server');
        }

        return UserModel.fromJson(userData);
      }

      throw AuthException(
        'Registration failed with status: ${response.statusCode}',
      );
    } on DioException catch (e) {
      log('Register DioException: ${e.type} - ${e.response?.statusCode}');
      log('Register error response: ${e.response?.data}');

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final errorData = e.response!.data;

        // Laravel format: data.message or errors
        String errorMessage = 'Registration failed';

        final message = errorData?['message'] ?? errorData?['error'];
        if (message != null) {
          errorMessage = message.toString();
        } else if (errorData?['errors'] != null) {
          final errors = errorData['errors'] as Map<String, dynamic>;
          if (errors.isNotEmpty) {
            final firstField = errors.keys.first;
            final firstError = errors[firstField];
            if (firstError is List && firstError.isNotEmpty) {
              errorMessage = firstError[0].toString();
            }
          }
        }

        // Handle validation errors (422)
        if (statusCode == 422) {
          throw AuthException(errorMessage, isValidationError: true);
        }

        throw AuthException(errorMessage);
      }

      // Network errors
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw AuthException(
          'Koneksi timeout. Periksa koneksi internet Anda.',
          isNetworkError: true,
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw AuthException(
          'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
          isNetworkError: true,
        );
      }

      throw AuthException(
        'Terjadi kesalahan. Silakan coba lagi.',
        isNetworkError: true,
      );
    } catch (e) {
      if (e is AuthException) rethrow;
      log('Register unexpected error: $e');
      throw AuthException('Terjadi kesalahan yang tidak terduga');
    }
  }
}

/// Custom exception for authentication errors
class AuthException implements Exception {
  final String message;
  final bool isInvalidCredentials;
  final bool isValidationError;
  final bool isForbidden;
  final bool isNetworkError;

  AuthException(
    this.message, {
    this.isInvalidCredentials = false,
    this.isValidationError = false,
    this.isForbidden = false,
    this.isNetworkError = false,
  });

  @override
  String toString() => message;
}

