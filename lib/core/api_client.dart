import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late final Dio dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Callback for 401 unauthorized - used for auto-logout
  static Function()? onUnauthorized;

  factory ApiClient() {
    return _instance;
  }

  ApiClient._internal() {
    // Select API URL based on platform
    // Mobile (Android/iOS emulator) -> API_KEY_MOBILE
    // Web -> API_KEY_WEB
    // Note: Base URL is /api (without /v1)
    // - Auth endpoints use /v1/auth/... (handled in repository)
    // - File/Folder endpoints use /files/..., /folders/... (without v1)
    String baseUrl;
    if (kIsWeb) {
      baseUrl = dotenv.env['API_KEY_WEB'] ?? 'http://localhost:8000/api';
      log('Running on Web, using API: $baseUrl');
    } else {
      baseUrl = dotenv.env['API_KEY_MOBILE'] ?? 'http://10.0.2.2:8000/api';
      log('Running on Mobile, using API: $baseUrl');
    }

    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Accept': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          log('API Request: ${options.method} ${options.path}');
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          final statusCode = e.response?.statusCode;
          final path = e.requestOptions.path;

          log('API Error: $statusCode - $path - ${e.message}');

          // Handle 401 Unauthorized - token expired or invalid
          if (statusCode == 401) {
            log('Token expired or invalid, clearing stored token');
            await _storage.delete(key: 'auth_token');

            // Trigger callback for auto-logout
            if (onUnauthorized != null) {
              onUnauthorized!();
            }
          }

          // Note: Retry logic removed due to type inference issues
          // Network errors will be handled by the calling code

          return handler.next(e);
        },
      ),
    );
  }

  // Method to manually clear token (for logout)
  Future<void> clearToken() async {
    await _storage.delete(key: 'auth_token');
  }

  // Method to check if token exists
  Future<bool> hasToken() async {
    final token = await _storage.read(key: 'auth_token');
    return token != null && token.isNotEmpty;
  }
}
