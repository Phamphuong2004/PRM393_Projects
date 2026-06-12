import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/keyword.dart';
import '../providers/network_provider.dart';
import '../constants/api_constants.dart';

final keywordRepositoryProvider = Provider<KeywordRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return KeywordRepository(dio);
});

class KeywordRepository {
  final Dio _dio;

  KeywordRepository(this._dio);

  Future<List<Keyword>> getTrendingKeywords({int limit = 10}) async {
    try {
      final response = await _dio.get(
        ApiConstants.trendingKeywords,
        queryParameters: {'limit': limit},
      );
      
      final data = response.data as List;
      return data.map((e) => Keyword.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getKeywords({int page = 1, int limit = 20, String sort = '-trendScore'}) async {
    try {
      final response = await _dio.get(
        ApiConstants.keywords,
        queryParameters: {'page': page, 'limit': limit, 'sort': sort},
      );
      
      final keywordsJson = (response.data['keywords'] as List?) ?? [];
      final keywords = keywordsJson.map((e) => Keyword.fromJson(e as Map<String, dynamic>)).toList();
      
      return {
        'keywords': keywords,
        'pagination': response.data['pagination'],
      };
    } catch (e) {
      rethrow;
    }
  }
}
