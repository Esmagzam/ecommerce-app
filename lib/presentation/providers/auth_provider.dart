import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/failures.dart';
import '../../data/models/user_model.dart';
import 'core_providers.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;
  final Failure? failure;

  const AuthState({
    required this.status,
    this.user,
    this.errorMessage,
    this.failure,
  });

  factory AuthState.initial() => const AuthState(status: AuthStatus.initial);
  factory AuthState.loading() => const AuthState(status: AuthStatus.loading);
  factory AuthState.authenticated(UserModel user) =>
      AuthState(status: AuthStatus.authenticated, user: user);
  factory AuthState.unauthenticated() =>
      const AuthState(status: AuthStatus.unauthenticated);
  factory AuthState.error(String message, [Failure? failure]) => AuthState(
    status: AuthStatus.error,
    errorMessage: message,
    failure: failure,
  );

  bool get isAuthenticated =>
      status == AuthStatus.authenticated && user != null;
  bool get isLoading => status == AuthStatus.loading;
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    return AuthState.initial();
  }

  Future<void> checkAuth() async {
    final authRepo = ref.read(authRepositoryProvider);
    final hasToken = await authRepo.hasSavedToken();
    if (!hasToken) {
      state = AuthState.unauthenticated();
      return;
    }

    try {
      final user = await authRepo.getMe();
      state = AuthState.authenticated(user);
    } catch (_) {
      state = AuthState.unauthenticated();
    }
  }

  Future<bool> login({required String email, required String password}) async {
    state = AuthState.loading();
    try {
      final authRepo = ref.read(authRepositoryProvider);
      final user = await authRepo.login(email: email, password: password);
      state = AuthState.authenticated(user);
      return true;
    } on Failure catch (f) {
      state = AuthState.error(f.message, f);
      return false;
    } catch (e) {
      state = AuthState.error(e.toString());
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    state = AuthState.loading();
    try {
      final authRepo = ref.read(authRepositoryProvider);
      final user = await authRepo.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      state = AuthState.authenticated(user);
      return true;
    } on Failure catch (f) {
      state = AuthState.error(f.message, f);
      return false;
    } catch (e) {
      state = AuthState.error(e.toString());
      return false;
    }
  }

  Future<bool> updateProfile({
    required String name,
    required String email,
  }) async {
    try {
      final authRepo = ref.read(authRepositoryProvider);
      final updated = await authRepo.updateProfile(name: name, email: email);
      state = AuthState.authenticated(updated);
      return true;
    } on Failure catch (f) {
      state = AuthState.error(f.message, f);
      return false;
    } catch (e) {
      state = AuthState.error(e.toString());
      return false;
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.changePassword(
        currentPassword: currentPassword,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      return true;
    } on Failure catch (f) {
      state = AuthState.error(f.message, f);
      return false;
    } catch (e) {
      state = AuthState.error(e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    final authRepo = ref.read(authRepositoryProvider);
    await authRepo.logout();
    state = AuthState.unauthenticated();
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
