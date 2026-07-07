import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/network_provider.dart';
import '../constants/api_constants.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return AuthRepository(dio);
});

class AuthRepository {
  final Dio _dio;

  AuthRepository(this._dio);

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post(ApiConstants.login, data: {
        'email': email,
        'password': password,
      });
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> googleLogin(String idToken) async {
    try {
      final response = await _dio.post(ApiConstants.googleLogin, data: {
        'idToken': idToken,
      });
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> register(
    String email,
    String password,
    String fullName, {
    String role = 'researcher',
    String? institution,
  }) async {
    try {
      final data = <String, dynamic>{
        'email': email,
        'password': password,
        'fullName': fullName,
        'role': role,
      };
      if (institution != null) data['institution'] = institution;

      final response = await _dio.post(ApiConstants.register, data: data);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> me() async {
    try {
      final response = await _dio.get(ApiConstants.me);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}
