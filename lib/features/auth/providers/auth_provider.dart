import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../repository/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

class AuthNotifier extends Notifier<AsyncValue<UserModel?>> {
  @override
  AsyncValue<UserModel?> build() {
    // Initial state is loading
    Future.microtask(() => checkAuthStatus());
    return const AsyncValue.loading();
  }

  Future<void> checkAuthStatus() async {
    try {
      final repo = ref.read(authRepositoryProvider);
      final user = await repo.getMe();
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(authRepositoryProvider);
      final user = await repo.login(email, password);
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.logout();
    } catch (e) {
      // ignore
    } finally {
      state = const AsyncValue.data(null);
    }
  }
}

final authStateProvider = NotifierProvider<AuthNotifier, AsyncValue<UserModel?>>(() {
  return AuthNotifier();
});
