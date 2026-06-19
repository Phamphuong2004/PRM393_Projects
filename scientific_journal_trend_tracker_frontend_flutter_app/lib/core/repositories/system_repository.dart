import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/network_provider.dart';
import '../constants/api_constants.dart';

final systemRepositoryProvider = Provider<SystemRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return SystemRepository(dio);
});

class SystemRepository {
  final Dio _dio;

  SystemRepository(this._dio);

  Future<void> triggerSync() async {
    try {
      await _dio.post(ApiConstants.adminSync);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getApiSources() async {
    try {
      final response = await _dio.get(ApiConstants.adminSources);
      final list = (response.data as List?) ?? [];
      return list.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createApiSource(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(ApiConstants.adminSources, data: data);
      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateApiSource(String id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('${ApiConstants.adminSources}/$id', data: data);
      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteApiSource(String id) async {
    try {
      await _dio.delete('${ApiConstants.adminSources}/$id');
    } catch (e) {
      rethrow;
    }
  }
}
