import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/bookmark.dart';
import '../providers/network_provider.dart';
import '../constants/api_constants.dart';

final bookmarkRepositoryProvider = Provider<BookmarkRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return BookmarkRepository(dio);
});

class BookmarkRepository {
  final Dio _dio;

  BookmarkRepository(this._dio);

  Future<List<Bookmark>> getBookmarks() async {
    try {
      final response = await _dio.get(ApiConstants.bookmarks);
      final data = (response.data['data'] as List?) ?? [];
      return data.map((e) => Bookmark.fromJson(e as Map<String, dynamic>)).toList();
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
