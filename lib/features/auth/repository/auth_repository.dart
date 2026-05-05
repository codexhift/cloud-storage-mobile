import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/api_client.dart';
import '../models/user_model.dart';
import 'dart:developer';

class AuthRepository {
  final ApiClient _api = ApiClient();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Use the Web Client ID as serverClientId so google_sign_in can generate
  // tokens that the backend (Laravel Socialite) can verify.
  late final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    clientId: dotenv.env['GOOGLE_WEB_CLIENT_ID'], // Required for Flutter Web
    serverClientId: dotenv.env['GOOGLE_WEB_CLIENT_ID'],
  );

  static const String tokenKey = 'auth_token';

  /// Sign in with Google natively, then exchange the token with the backend
  /// for a Sanctum bearer token.
  ///
  /// IMPORTANT: Laravel Socialite's `userFromToken()` expects a Google
  /// **access_token** (it calls the userinfo endpoint with Bearer auth).
  /// The API parameter is named `id_token` but we send the access_token
  /// because that is what the backend actually processes.
  Future<UserModel> signInWithGoogle() async {
    log('AuthRepository: Starting Google Sign-In flow...');

    // 1. Trigger native Google Sign-In
    final GoogleSignInAccount? googleAccount = await _googleSignIn.signIn();
    if (googleAccount == null) {
      throw AuthException(
        'Google Sign-In dibatalkan.',
        isCancelled: true,
      );
    }

    log('AuthRepository: Google account selected: ${googleAccount.email}');

    // 2. Obtain tokens from Google
    final GoogleSignInAuthentication googleAuth =
        await googleAccount.authentication;

    // The backend's Socialite::userFromToken() needs the ACCESS token,
    // not the id_token, because it calls Google's userinfo endpoint.
    final String? accessToken = googleAuth.accessToken;

    if (accessToken == null || accessToken.isEmpty) {
      throw AuthException(
        'Gagal mendapatkan token dari Google. Silakan coba lagi.',
      );
    }

    log('AuthRepository: Google access_token obtained, exchanging with backend...');

    // 3. Send the access_token to the backend via the `id_token` field
    //    (the backend parameter name is id_token, but it processes it
    //    as an access_token through Socialite::userFromToken)
    try {
      final response = await _api.dio.post(
        '/v1/auth/google',
        data: {'id_token': accessToken},
      );

      log('AuthRepository: Backend response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;

        if (data == null || data['success'] != true) {
          throw AuthException('Server menolak autentikasi Google.');
        }

        final responseData = data['data'];
        final token = responseData['token'];
        if (token == null) {
          throw AuthException('Tidak ada token dari server.');
        }

        // Store the Sanctum token securely
        await _storage.write(key: tokenKey, value: token.toString());
        log('AuthRepository: Sanctum token stored successfully');

        // Parse user data
        final userData = responseData['user'];
        if (userData == null) {
          throw AuthException('Tidak ada data pengguna dari server.');
        }

        return UserModel.fromJson(userData);
      }

      throw AuthException(
        'Login gagal dengan status: ${response.statusCode}',
      );
    } on DioException catch (e) {
      log('AuthRepository: DioException: ${e.type} - ${e.response?.statusCode}');
      log('AuthRepository: Error response: ${e.response?.data}');

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final errorData = e.response!.data;
        final message = errorData?['message'] ?? errorData?['error'];

        if (statusCode == 401) {
          throw AuthException(
            message?.toString() ?? 'Token Google tidak valid.',
            isInvalidCredentials: true,
          );
        } else if (statusCode == 422) {
          throw AuthException(
            message?.toString() ?? 'Data tidak valid.',
            isValidationError: true,
          );
        }

        throw AuthException(message?.toString() ?? 'Autentikasi gagal.');
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
    }
  }

  /// Get current user from stored token (validates session)
  Future<UserModel?> getMe() async {
    try {
      final token = await _storage.read(key: tokenKey);
      if (token == null || token.isEmpty) {
        log('AuthRepository: No token found in storage');
        return null;
      }

      log('AuthRepository: Fetching user data with stored token...');
      final response = await _api.dio.get('/v1/auth/me');

      log('AuthRepository: getMe response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;
        final responseData = data['data'] ?? data;
        final userData = responseData['user'] ?? responseData;
        return UserModel.fromJson(userData);
      }

      return null;
    } on DioException catch (e) {
      log('AuthRepository: getMe DioException: ${e.type} - ${e.response?.statusCode}');
      return null;
    } catch (e) {
      log('AuthRepository: getMe unexpected error: $e');
      return null;
    }
  }

  /// Logout: revoke server token, sign out of Google, clear local storage
  Future<void> logout() async {
    log('AuthRepository: Logging out...');

    try {
      await _api.dio.post('/v1/auth/logout');
    } catch (e) {
      log('AuthRepository: Logout API call failed (non-critical): $e');
    }

    // Sign out of Google as well
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      log('AuthRepository: Google sign out failed (non-critical): $e');
    }

    // Always clear local token
    await _storage.delete(key: tokenKey);
    log('AuthRepository: Local token cleared');
  }

  /// Check if user has a stored token
  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: tokenKey);
    return token != null && token.isNotEmpty;
  }
}

/// Custom exception for authentication errors
class AuthException implements Exception {
  final String message;
  final bool isInvalidCredentials;
  final bool isValidationError;
  final bool isForbidden;
  final bool isNetworkError;
  final bool isCancelled;

  AuthException(
    this.message, {
    this.isInvalidCredentials = false,
    this.isValidationError = false,
    this.isForbidden = false,
    this.isNetworkError = false,
    this.isCancelled = false,
  });

  @override
  String toString() => message;
}
