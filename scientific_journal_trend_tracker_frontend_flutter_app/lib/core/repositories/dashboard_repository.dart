import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/network_provider.dart';
import '../constants/api_constants.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return DashboardRepository(dio);
});

class DashboardRepository {
  final Dio _dio;

  DashboardRepository(this._dio);

  Future<Map<String, dynamic>> getDashboardStats({int? year}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (year != null) queryParams['year'] = year;

      final response = await _dio.get(
        ApiConstants.dashboardStats,
        queryParameters: queryParams,
      );
      
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }
}
