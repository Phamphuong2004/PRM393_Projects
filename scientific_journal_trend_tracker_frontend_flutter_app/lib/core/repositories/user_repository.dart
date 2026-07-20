import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../providers/network_provider.dart';
import '../constants/api_constants.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return UserRepository(dio);
});

class UserRepository {
  final Dio _dio;

  UserRepository(this._dio);

  Future<User> updateProfile(String id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('${ApiConstants.users}/$id', data: data);
      // Backend might return the user directly or nested under 'data' or 'user'
      final userData = response.data['data'] ?? response.data['user'] ?? response.data;
      return User.fromJson(userData);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> changePassword(String id, String currentPassword, String newPassword) async {
    try {
      await _dio.post('${ApiConstants.users}/$id/change-password', data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getAllUsers({int page = 1, int limit = 10}) async {
    try {
      final response = await _dio.get(
        ApiConstants.users,
        queryParameters: {'page': page, 'limit': limit},
      );
      final list = (response.data['users'] as List?) ?? (response.data['data'] as List?) ?? [];
      final users = list.map((e) => User.fromJson(e as Map<String, dynamic>)).toList();
      return {
        'users': users,
        'pagination': response.data['pagination'],
      };
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUserStatus(String id, bool isActive) async {
    try {
      await _dio.put(
        '${ApiConstants.users}/$id',
        data: {'isActive': isActive},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUserRole(String id, String role) async {
    try {
      await _dio.put(
        '${ApiConstants.users}/$id',
        data: {'role': role},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteUser(String id) async {
    try {
      await _dio.delete('${ApiConstants.users}/$id');
    } catch (e) {
      rethrow;
    }
  }
}
