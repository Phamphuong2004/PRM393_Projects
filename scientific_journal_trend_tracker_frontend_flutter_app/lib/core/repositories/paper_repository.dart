import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/paper.dart';
import '../providers/network_provider.dart';
import '../constants/api_constants.dart';

final paperRepositoryProvider = Provider<PaperRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return PaperRepository(dio);
});

class PaperRepository {
  final Dio _dio;

  PaperRepository(this._dio);

  Future<Map<String, dynamic>> getPapers({int page = 1, int limit = 10}) async {
    try {
      final response = await _dio.get(
        ApiConstants.papers,
        queryParameters: {'page': page, 'limit': limit},
      );
      
      final papersJson = (response.data['papers'] as List?) ?? (response.data['data'] as List?) ?? [];
      final papers = papersJson.map((e) => Paper.fromJson(e as Map<String, dynamic>)).toList();
      
      return {
        'papers': papers,
        'pagination': response.data['pagination'],
      };
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> searchPapers(String query, {int? year, String? journalId}) async {
    try {
      final queryParams = <String, dynamic>{'q': query};
      if (year != null) queryParams['year'] = year;
      if (journalId != null) queryParams['journalId'] = journalId;

      final response = await _dio.get(
        ApiConstants.searchPapers,
        queryParameters: queryParams,
      );
      
      final papersJson = (response.data['papers'] as List?) ?? (response.data['data'] as List?) ?? [];
      final papers = papersJson.map((e) => Paper.fromJson(e as Map<String, dynamic>)).toList();
      
      return {
        'papers': papers,
        'pagination': response.data['pagination'],
      };
    } catch (e) {
      rethrow;
    }
  }

  Future<Paper> getPaperById(String id) async {
    try {
      final response = await _dio.get('${ApiConstants.papers}/$id');
      return Paper.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
