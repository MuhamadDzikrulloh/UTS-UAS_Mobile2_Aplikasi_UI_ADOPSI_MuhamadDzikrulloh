import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';

class AuthState {
  final bool authenticated;
  final String? role;
  final String? email;
  final String? error;
  final bool loading;

  const AuthState({
    required this.authenticated,
    this.role,
    this.email,
    this.error,
    this.loading = false,
  });

  AuthState copyWith({
    bool? authenticated,
    String? role,
    String? email,
    String? error,
    bool? loading,
  }) => AuthState(
        authenticated: authenticated ?? this.authenticated,
        role: role ?? this.role,
        email: email ?? this.email,
        error: error,
        loading: loading ?? this.loading,
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState(authenticated: false));
  final _service = AuthService();

  Future<void> login(String email, String password) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final user = await _service.login(email, password);
      state = AuthState(
        authenticated: true,
        role: user['role'] as String?,
        email: user['email'] as String?,
        loading: false,
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> logout() async {
    await _service.logout();
    state = const AuthState(authenticated: false);
  }

  Future<void> register(String name, String email, String password) async {
    state = state.copyWith(loading: true, error: null);
    try {
      await _service.register(name, email, password);
      state = state.copyWith(
        loading: false,
        error: 'Registrasi berhasil! Silakan login dengan akun baru Anda.',
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }
  
  Future<void> resetPassword(String email, String password) async {
    state = state.copyWith(loading: true, error: null);
    try {
      await _service.resetPassword(email, password);
      state = state.copyWith(loading: false);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
