import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api_client.dart';
import '../models/user_model.dart';
import '../repository/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    log('AuthNotifier: Initializing...');

    // Set up 401 callback for auto-logout
    ApiClient.onUnauthorized = () {
      log('AuthNotifier: Received 401 callback, logging out...');
      logout();
    };

    // Check auth status on init
    Future.microtask(() => checkAuthStatus());

    return const AuthState(isLoading: true);
  }

  Future<void> checkAuthStatus() async {
    log('AuthNotifier: Checking auth status...');

    try {
      final repo = ref.read(authRepositoryProvider);
      final user = await repo.getMe();

      if (user != null) {
        log('AuthNotifier: User authenticated: ${user.email}');
        state = AuthState(user: user, isAuthenticated: true, isLoading: false);
      } else {
        log('AuthNotifier: No authenticated user');
        state = const AuthState(isAuthenticated: false, isLoading: false);
      }
    } catch (e) {
      log('AuthNotifier: Error checking auth: $e');
      state = const AuthState(isAuthenticated: false, isLoading: false);
    }
  }

  /// Sign in with Google (the only auth method)
  Future<bool> signInWithGoogle() async {
    log('AuthNotifier: Starting Google Sign-In...');

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final repo = ref.read(authRepositoryProvider);
      final user = await repo.signInWithGoogle();

      log('AuthNotifier: Google Sign-In successful for ${user.email}');

      state = AuthState(user: user, isAuthenticated: true, isLoading: false);

      return true;
    } on AuthException catch (e) {
      log('AuthNotifier: Google Sign-In failed - ${e.message}');

      // Don't show error for user-cancelled sign-in
      if (e.isCancelled) {
        state = state.copyWith(isLoading: false);
        return false;
      }

      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      log('AuthNotifier: Google Sign-In unexpected error: $e');

      state = state.copyWith(
        isLoading: false,
        error: 'Terjadi kesalahan yang tidak terduga. Silakan coba lagi.',
      );

      return false;
    }
  }

  Future<void> logout() async {
    log('AuthNotifier: Logging out...');

    state = state.copyWith(isLoading: true);

    // Disable 401 callback to prevent infinite loop when calling logout API
    final previousCallback = ApiClient.onUnauthorized;
    ApiClient.onUnauthorized = null;

    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.logout();
    } catch (e) {
      log('AuthNotifier: Logout error (non-critical): $e');
    } finally {
      // Restore callback
      ApiClient.onUnauthorized = previousCallback;
      state = const AuthState(isAuthenticated: false, isLoading: false);
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

final authStateProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});

// Convenience providers
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).isAuthenticated;
});

final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authStateProvider).user;
});