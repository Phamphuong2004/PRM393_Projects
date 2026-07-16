import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/paper.dart';
import '../providers/network_provider.dart';
import '../constants/api_constants.dart';

final bookmarkRepositoryProvider = Provider<BookmarkRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return BookmarkRepository(dio);
});

class BookmarkRepository {
  final Dio _dio;

  BookmarkRepository(this._dio);

  // BE returns { bookmarks: [ ...Paper ], pagination }. The bookmarks array holds
  // populated Paper documents directly (not a Bookmark wrapper).
  Future<List<Paper>> getBookmarks({String searchQuery = '', String sortOrder = 'newest'}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (searchQuery.isNotEmpty) queryParams['search'] = searchQuery;
      if (sortOrder.isNotEmpty) queryParams['sort'] = sortOrder;

      final response = await _dio.get(ApiConstants.bookmarks, queryParameters: queryParams);
      final data = (response.data['bookmarks'] as List?) ??
          (response.data['data'] as List?) ??
          [];
      return data
          .where((e) => e != null)
          .map((e) => Paper.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addBookmark(String paperId) async {
    try {
      await _dio.post('${ApiConstants.bookmarks}/$paperId');
    } catch (e) {
      rethrow;
    }
  }

  Future<Paper> importBookmark(Map<String, dynamic> paperData) async {
    try {
      final response = await _dio.post(ApiConstants.importPaper, data: paperData);
      return Paper.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeBookmark(String paperId) async {
    try {
      await _dio.delete('${ApiConstants.bookmarks}/$paperId');
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> checkBookmark(String paperId) async {
    try {
      final response = await _dio.get('${ApiConstants.bookmarks}/$paperId/check');
      return response.data['isBookmarked'] ?? false;
    } catch (e) {
      return false; // Assume not bookmarked on error
    }
  }
}
