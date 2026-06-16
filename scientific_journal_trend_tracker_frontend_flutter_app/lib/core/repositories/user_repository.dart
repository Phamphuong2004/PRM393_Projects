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
      return User.fromJson(response.data['data']);
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
}
