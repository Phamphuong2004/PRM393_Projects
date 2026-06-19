import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/network_provider.dart';
import '../constants/api_constants.dart';

final analysisRunRepositoryProvider = Provider<AnalysisRunRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return AnalysisRunRepository(dio);
});

class AnalysisRunRepository {
  final Dio _dio;

  AnalysisRunRepository(this._dio);

  Future<Map<String, dynamic>> getAnalysisRuns({int page = 1, int limit = 10}) async {
    try {
      final response = await _dio.get(
        ApiConstants.analysisRuns,
        queryParameters: {'page': page, 'limit': limit},
      );
      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getAnalysisRunById(String id) async {
    try {
      final response = await _dio.get('${ApiConstants.analysisRuns}/$id');
      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createAnalysisRun(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(ApiConstants.analysisRuns, data: data);
      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAnalysisRun(String id) async {
    try {
      await _dio.delete('${ApiConstants.analysisRuns}/$id');
    } catch (e) {
      rethrow;
    }
  }
}
