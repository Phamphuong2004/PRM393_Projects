import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  Map<String, dynamic>? _user;
  bool _isLoading = true;
  String? _error;

  String? get token => _token;
  Map<String, dynamic>? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _token != null;
  
  String get role => _user?['role'] ?? 'User';
  bool get isAdmin => role.toLowerCase() == 'admin';
  bool get isResearcher => role.toLowerCase() == 'researcher';

  AuthProvider() {
    _loadUser();
  }

  Future<void> _loadUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('token');

      if (_token != null) {
        final userData = await AuthApi.me();
        _user = userData;
      }
    } catch (e) {
      bool isUnauthorized = false;
      if (e is ApiException && e.statusCode == 401) {
        isUnauthorized = true;
      } else if (e.toString().toLowerCase().contains('unauthorized') || e.toString().contains('401')) {
        isUnauthorized = true;
      }

      if (isUnauthorized) {
        _token = null;
        _user = null;
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');
      }
      // If network timeout or backend sleep, keep the token so user stays logged in
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await AuthApi.login(email, password);
      _token = response['token'];
      _user = response['user'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String email, String password, String fullName, {String role = 'researcher', String? institution}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await AuthApi.register(email, password, fullName, role: role, institution: institution);
      await login(email, password);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    notifyListeners();
  }
}
