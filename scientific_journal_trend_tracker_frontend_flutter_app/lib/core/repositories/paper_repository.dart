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

  Future<Map<String, dynamic>> getPapers({int page = 1, int limit = 10, int? year, String? sort}) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page, 
        'limit': limit,
      };
      if (year != null) queryParams['year'] = year;
      if (sort != null) queryParams['sort'] = sort;

      final response = await _dio.get(
        ApiConstants.papers,
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

  Future<Map<String, dynamic>> searchPapers(String query, {int? year, String? journalId, int page = 1, int limit = 10, String sort = '-publicationYear'}) async {
    try {
      final queryParams = <String, dynamic>{
        'q': query,
        'page': page,
        'limit': limit,
        'sort': sort,
      };
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

  Future<Map<String, dynamic>> searchExternalPapers(String query, {int limit = 10, String? source, int page = 1, int? year, String? sort}) async {
    try {
      final queryParams = <String, dynamic>{'q': query, 'limit': limit, 'source': source, 'page': page};
      if (year != null) queryParams['year'] = year;
      if (sort != null) queryParams['sort'] = sort;

      final response = await _dio.get(
        ApiConstants.searchExternalPapers,
        queryParameters: queryParams,
      );
      
      final papersJson = (response.data['papers'] as List?) ?? (response.data['data'] as List?) ?? [];
      final papers = papersJson.map((e) => Paper.fromJson(e as Map<String, dynamic>)).toList();
      
      return {
        'papers': papers,
        'pagination': {
          'page': page,
          'limit': limit,
          'total': response.data['total'] ?? papers.length,
          'pages': response.data['pages'] ?? 1,
        },
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
