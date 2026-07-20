import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_constants.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiService {
  static final ApiService _instance = ApiService._internal();

  late final Dio _dio;
  final _storage = const FlutterSecureStorage();

  factory ApiService() {
    return _instance;
  }

  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'jwt_token');
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        return handler.next(error);
      }
    ));
  }

  dynamic _processResponse(Response response) {
    if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
      return response.data;
    } else {
      String message = response.data is Map && response.data['message'] != null
          ? response.data['message']
          : 'Error ${response.statusCode}';
      throw ApiException(message, statusCode: response.statusCode);
    }
  }

  Future<dynamic> get(String endpoint) async {
    try {
      final response = await _dio.get(endpoint);
      return _processResponse(response);
    } on DioException catch (e) {
      if (e.response != null) return _processResponse(e.response!);
      throw ApiException(e.message ?? 'Unknown Error');
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await _dio.post(endpoint, data: body);
      return _processResponse(response);
    } on DioException catch (e) {
      if (e.response != null) return _processResponse(e.response!);
      throw ApiException(e.message ?? 'Unknown Error');
    }
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await _dio.put(endpoint, data: body);
      return _processResponse(response);
    } on DioException catch (e) {
      if (e.response != null) return _processResponse(e.response!);
      throw ApiException(e.message ?? 'Unknown Error');
    }
  }

  Future<dynamic> patch(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await _dio.patch(endpoint, data: body);
      return _processResponse(response);
    } on DioException catch (e) {
      if (e.response != null) return _processResponse(e.response!);
      throw ApiException(e.message ?? 'Unknown Error');
    }
  }

  Future<dynamic> delete(String endpoint) async {
    try {
      final response = await _dio.delete(endpoint);
      return _processResponse(response);
    } on DioException catch (e) {
      if (e.response != null) return _processResponse(e.response!);
      throw ApiException(e.message ?? 'Unknown Error');
    }
  }
}

final api = ApiService();

// ─────────────────────────────────────────────────────────
// AUTH
// ─────────────────────────────────────────────────────────
class AuthApi {
  static Future<dynamic> register(
    String email,
    String password,
    String fullName, {
    String role = 'researcher',
    String? institution,
  }) {
    final data = <String, dynamic>{
      'email': email,
      'password': password,
      'fullName': fullName,
      'role': role,
    };
    if (institution != null) data['institution'] = institution;
    return api.post(ApiConstants.register, data);
  }

  static Future<dynamic> login(String email, String password) {
    return api.post(ApiConstants.login, {'email': email, 'password': password});
  }

  static Future<dynamic> googleLogin(String idToken) {
    return api.post(ApiConstants.googleLogin, {'idToken': idToken});
  }

  static Future<dynamic> me() {
    return api.get(ApiConstants.me);
  }
}

// ─────────────────────────────────────────────────────────
// PAPERS
// ─────────────────────────────────────────────────────────
class PapersApi {
  static Future<dynamic> list({int page = 1, int limit = 10}) {
    return api.get('${ApiConstants.papers}?page=$page&limit=$limit');
  }

  static Future<dynamic> search(String q, {int? year, String? journalId}) {
    String url = '${ApiConstants.searchPapers}?q=${Uri.encodeComponent(q)}';
    if (year != null) url += '&year=$year';
    if (journalId != null) url += '&journalId=$journalId';
    return api.get(url);
  }

  static Future<dynamic> searchExternal(String q, {int limit = 10}) {
    String url = '${ApiConstants.searchExternalPapers}?q=${Uri.encodeComponent(q)}&limit=$limit';
    return api.get(url);
  }

  static Future<dynamic> getById(String id) {
    return api.get('${ApiConstants.papers}/$id');
  }

  static Future<dynamic> create(Map<String, dynamic> data) {
    return api.post(ApiConstants.papers, data);
  }

  static Future<dynamic> update(String id, Map<String, dynamic> data) {
    return api.put('${ApiConstants.papers}/$id', data);
  }

  static Future<dynamic> delete(String id) {
    return api.delete('${ApiConstants.papers}/$id');
  }
}

// ─────────────────────────────────────────────────────────
// KEYWORDS / TRENDING
// ─────────────────────────────────────────────────────────
class KeywordsApi {
  static Future<dynamic> list({
    int page = 1,
    int limit = 20,
    String sort = '-trendScore',
  }) {
    return api.get(
      '${ApiConstants.keywords}?page=$page&limit=$limit&sort=$sort',
    );
  }

  static Future<dynamic> trending({int limit = 20}) {
    return api.get('${ApiConstants.trendingKeywords}?limit=$limit');
  }

  static Future<dynamic> getById(String id) {
    return api.get('${ApiConstants.keywords}/$id');
  }

  static Future<dynamic> create(Map<String, dynamic> data) {
    return api.post(ApiConstants.keywords, data);
  }

  static Future<dynamic> update(String id, Map<String, dynamic> data) {
    return api.put('${ApiConstants.keywords}/$id', data);
  }

  static Future<dynamic> delete(String id) {
    return api.delete('${ApiConstants.keywords}/$id');
  }
}

// ─────────────────────────────────────────────────────────
// BOOKMARKS
// ─────────────────────────────────────────────────────────
class BookmarksApi {
  static Future<dynamic> list({int page = 1, int limit = 20}) {
    return api.get('${ApiConstants.bookmarks}?page=$page&limit=$limit');
  }

  static Future<dynamic> add(String paperId) {
    return api.post('${ApiConstants.bookmarks}/$paperId', {});
  }

  static Future<dynamic> remove(String paperId) {
    return api.delete('${ApiConstants.bookmarks}/$paperId');
  }

  static Future<dynamic> check(String paperId) {
    return api.get('${ApiConstants.bookmarks}/$paperId/check');
  }
}

// ─────────────────────────────────────────────────────────
// NOTIFICATIONS
// ─────────────────────────────────────────────────────────
class NotificationsApi {
  static Future<dynamic> list({int page = 1, int limit = 20}) {
    return api.get('${ApiConstants.notifications}?page=$page&limit=$limit');
  }

  static Future<dynamic> unreadCount() {
    return api.get('${ApiConstants.notifications}/unread/count');
  }

  static Future<dynamic> markAllRead() {
    return api.put('${ApiConstants.notifications}/all/read', {});
  }

  static Future<dynamic> markRead(String id) {
    return api.put('${ApiConstants.notifications}/$id/read', {});
  }

  static Future<dynamic> delete(String id) {
    return api.delete('${ApiConstants.notifications}/$id');
  }
}

// ─────────────────────────────────────────────────────────
// USERS
// ─────────────────────────────────────────────────────────
class UsersApi {
  static Future<dynamic> list() {
    return api.get(ApiConstants.users);
  }

  static Future<dynamic> remove(String id) {
    return api.delete('${ApiConstants.users}/$id');
  }

  static Future<dynamic> getById(String id) {
    return api.get('${ApiConstants.users}/$id');
  }

  static Future<dynamic> update(String id, Map<String, dynamic> data) {
    return api.put('${ApiConstants.users}/$id', data);
  }

  static Future<dynamic> changePassword(
    String id,
    String currentPassword,
    String newPassword,
  ) {
    return api.post('${ApiConstants.users}/$id/change-password', {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
  }
}

// ─────────────────────────────────────────────────────────
// FOLLOWS
// ─────────────────────────────────────────────────────────
class FollowsApi {
  static Future<dynamic> list() {
    return api.get(ApiConstants.follows);
  }

  static Future<dynamic> follow(
    String targetType,
    String targetId, {
    bool notifyEnabled = true,
  }) {
    return api.post(ApiConstants.follows, {
      'targetType': targetType,
      'targetId': targetId,
      'notifyEnabled': notifyEnabled,
    });
  }

  static Future<dynamic> unfollow(String targetId) {
    return api.delete('${ApiConstants.follows}/$targetId');
  }
}

// ─────────────────────────────────────────────────────────
// JOURNALS
// ─────────────────────────────────────────────────────────
class JournalsApi {
  static Future<dynamic> list({int page = 1, int limit = 10}) {
    return api.get('${ApiConstants.journals}?page=$page&limit=$limit');
  }

  static Future<dynamic> getById(String id) {
    return api.get('${ApiConstants.journals}/$id');
  }

  static Future<dynamic> create(Map<String, dynamic> data) {
    return api.post(ApiConstants.journals, data);
  }

  static Future<dynamic> update(String id, Map<String, dynamic> data) {
    return api.put('${ApiConstants.journals}/$id', data);
  }

  static Future<dynamic> delete(String id) {
    return api.delete('${ApiConstants.journals}/$id');
  }
}

// ─────────────────────────────────────────────────────────
// PUBLICATION TRENDS
// ─────────────────────────────────────────────────────────
class TrendsApi {
  static Future<dynamic> trendingList() {
    return api.get(ApiConstants.trendingPublications);
  }

  static Future<dynamic> byKeyword(String keywordId) {
    return api.get('${ApiConstants.publicationTrends}/keyword/$keywordId');
  }

  static Future<dynamic> analyzeRelated(String keyword, String source, int startYear) {
    return api.get('${ApiConstants.publicationTrends}/analyze-related?keyword=${Uri.encodeComponent(keyword)}&source=${Uri.encodeComponent(source)}&startYear=$startYear');
  }
}

// ─────────────────────────────────────────────────────────
// DASHBOARD STATS
// ─────────────────────────────────────────────────────────
class DashboardApi {
  static Future<dynamic> getDashboardStats() {
    return api.get(ApiConstants.dashboardStats);
  }
}

// ─────────────────────────────────────────────────────────
// TOPICS
// ─────────────────────────────────────────────────────────
class TopicsApi {
  static Future<dynamic> list({int page = 1, int limit = 20}) {
    return api.get('${ApiConstants.topics}?page=$page&limit=$limit');
  }

  static Future<dynamic> emerging({int limit = 10}) {
    return api.get('${ApiConstants.emergingTopics}?limit=$limit');
  }

  static Future<dynamic> getById(String id) {
    return api.get('${ApiConstants.topics}/$id');
  }

  static Future<dynamic> create(Map<String, dynamic> data) {
    return api.post(ApiConstants.topics, data);
  }

  static Future<dynamic> update(String id, Map<String, dynamic> data) {
    return api.put('${ApiConstants.topics}/$id', data);
  }

  static Future<dynamic> delete(String id) {
    return api.delete('${ApiConstants.topics}/$id');
  }
}

// ─────────────────────────────────────────────────────────
// ANALYSIS RUNS
// ─────────────────────────────────────────────────────────
class AnalysisRunsApi {
  static Future<dynamic> list({int page = 1, int limit = 10}) {
    return api.get('${ApiConstants.analysisRuns}?page=$page&limit=$limit');
  }

  static Future<dynamic> create(Map<String, dynamic> data) {
    return api.post(ApiConstants.analysisRuns, data);
  }

  static Future<dynamic> getById(String id) {
    return api.get('${ApiConstants.analysisRuns}/$id');
  }

  static Future<dynamic> delete(String id) {
    return api.delete('${ApiConstants.analysisRuns}/$id');
  }
}

// ─────────────────────────────────────────────────────────
// ADMIN
// ─────────────────────────────────────────────────────────
class AdminApi {
  static Future<dynamic> getSources() {
    return api.get(ApiConstants.adminSources);
  }

  static Future<dynamic> createSource(Map<String, dynamic> data) {
    return api.post(ApiConstants.adminSources, data);
  }

  static Future<dynamic> updateSource(String id, Map<String, dynamic> data) {
    return api.put('${ApiConstants.adminSources}/$id', data);
  }

  static Future<dynamic> deleteSource(String id) {
    return api.delete('${ApiConstants.adminSources}/$id');
  }

  static Future<dynamic> triggerSync() {
    return api.post(ApiConstants.adminSync, {});
  }
}

// ─────────────────────────────────────────────────────────
// AUTHORS
// ─────────────────────────────────────────────────────────
class AuthorsApi {
  static Future<dynamic> list({int page = 1, int limit = 10, String? search}) {
    String url = '${ApiConstants.authors}?page=$page&limit=$limit';
    if (search != null && search.isNotEmpty) {
      url += '&search=${Uri.encodeComponent(search)}';
    }
    return api.get(url);
  }

  static Future<dynamic> getById(String id) {
    return api.get('${ApiConstants.authors}/$id');
  }

  static Future<dynamic> create(Map<String, dynamic> data) {
    return api.post(ApiConstants.authors, data);
  }

  static Future<dynamic> update(String id, Map<String, dynamic> data) {
    return api.put('${ApiConstants.authors}/$id', data);
  }

  static Future<dynamic> delete(String id) {
    return api.delete('${ApiConstants.authors}/$id');
  }
}

// ─────────────────────────────────────────────────────────
// SYNC LOGS
// ─────────────────────────────────────────────────────────
class SyncLogsApi {
  static Future<dynamic> list({int page = 1, int limit = 10, String? status}) {
    String url = '${ApiConstants.syncLogs}?page=$page&limit=$limit';
    if (status != null && status.isNotEmpty) {
      url += '&status=$status';
    }
    return api.get(url);
  }

  static Future<dynamic> getById(String id) {
    return api.get('${ApiConstants.syncLogs}/$id');
  }

  static Future<dynamic> delete(String id) {
    return api.delete('${ApiConstants.syncLogs}/$id');
  }

  static Future<dynamic> clearAll() {
    return api.delete(ApiConstants.syncLogs);
  }
}

