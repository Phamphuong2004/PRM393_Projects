import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../repositories/auth_repository.dart';
import 'package:dio/dio.dart';

class AuthState {
  final String? token;
  final Map<String, dynamic>? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.token,
    this.user,
    this.isLoading = true,
    this.error,
  });

  bool get isAuthenticated => token != null;
  String get role => user?['role'] ?? 'User';
  bool get isAdmin => role.toLowerCase() == 'admin';
  bool get isResearcher => role.toLowerCase() == 'researcher';

  AuthState copyWith({
    String? token,
    Map<String, dynamic>? user,
    bool? isLoading,
    String? error,
    bool clearToken = false,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      token: clearToken ? null : (token ?? this.token),
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});

class AuthNotifier extends Notifier<AuthState> {
  final _storage = const FlutterSecureStorage();

  @override
  AuthState build() {
    _loadUser();
    return const AuthState();
  }

  Future<void> _loadUser() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final token = await _storage.read(key: 'jwt_token');

      if (token != null && token.isNotEmpty) {
        final authRepo = ref.read(authRepositoryProvider);
        final userData = await authRepo.me();
        state = state.copyWith(token: token, user: userData, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      bool isUnauthorized = false;
      if (e is DioException && e.response?.statusCode == 401) {
        isUnauthorized = true;
      } else if (e.toString().toLowerCase().contains('unauthorized') || e.toString().contains('401')) {
        isUnauthorized = true;
      }

      if (isUnauthorized) {
        await _storage.delete(key: 'jwt_token');
        state = state.copyWith(
          clearToken: true,
          clearUser: true,
          isLoading: false,
        );
      } else {
        // If network timeout or backend sleep, keep the token so user stays logged in
        final token = await _storage.read(key: 'jwt_token');
        state = state.copyWith(token: token, isLoading: false);
      }
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final authRepo = ref.read(authRepositoryProvider);
      final response = await authRepo.login(email, password);
      final token = response['token'];
      
      await _storage.write(key: 'jwt_token', value: token);
      state = state.copyWith(
        token: token,
        user: response['user'],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      rethrow;
    }
  }

  Future<void> loginWithGoogle() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: kIsWeb ? '673014775519-rju4plaf4dc5bjqc7h7dprhtjv61i5h0.apps.googleusercontent.com' : null,
        serverClientId: kIsWeb ? null : '673014775519-rju4plaf4dc5bjqc7h7dprhtjv61i5h0.apps.googleusercontent.com',
        scopes: ['email', 'profile'],
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        state = state.copyWith(isLoading: false);
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken ?? googleAuth.accessToken;

      if (idToken == null) {
        throw Exception("Failed to get ID Token from Google");
      }

      final authRepo = ref.read(authRepositoryProvider);
      final response = await authRepo.googleLogin(idToken);
      final token = response['token'];

      await _storage.write(key: 'jwt_token', value: token);
      state = state.copyWith(
        token: token,
        user: response['user'],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      rethrow;
    }
  }

  Future<void> register(String email, String password, String fullName, {String role = 'researcher', String? institution}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.register(email, password, fullName, role: role, institution: institution);
      await login(email, password);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      rethrow;
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
    state = state.copyWith(
      clearToken: true,
      clearUser: true,
      isLoading: false,
    );
  }
}
