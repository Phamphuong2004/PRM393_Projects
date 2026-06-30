import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
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

  factory ApiService() {
    return _instance;
  }

  ApiService._internal();

  Future<Map<String, String>> _getHeaders([
    Map<String, String>? customHeaders,
  ]) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final headers = {'Content-Type': 'application/json', ...?customHeaders};

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  dynamic _processResponse(http.Response response) {
    dynamic data;
    try {
      if (response.body.isNotEmpty) {
        data = json.decode(response.body);
      }
    } catch (_) {
      data = {'message': response.body};
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      String message = data is Map && data['message'] != null
          ? data['message']
          : 'Error ${response.statusCode}';
      throw ApiException(message, statusCode: response.statusCode);
    }
  }

  Future<dynamic> get(String endpoint) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    final headers = await _getHeaders();
    final response = await http.get(uri, headers: headers);
    return _processResponse(response);
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    final headers = await _getHeaders();
    final response = await http.post(
      uri,
      headers: headers,
      body: json.encode(body),
    );
    return _processResponse(response);
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    final headers = await _getHeaders();
    final response = await http.put(
      uri,
      headers: headers,
      body: json.encode(body),
    );
    return _processResponse(response);
  }

  Future<dynamic> patch(String endpoint, Map<String, dynamic> body) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    final headers = await _getHeaders();
    final response = await http.patch(
      uri,
      headers: headers,
      body: json.encode(body),
    );
    return _processResponse(response);
  }

  Future<dynamic> delete(String endpoint) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    final headers = await _getHeaders();
    final response = await http.delete(uri, headers: headers);
    return _processResponse(response);
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
  static Future<dynamic> updateUserStatus(String id, String status) {
    return api.patch('${ApiConstants.adminUsers}/$id/status', {'status': status});
  }

  static Future<dynamic> updateUserRole(String id, String role) {
    return api.patch('${ApiConstants.adminUsers}/$id/role', {'role': role});
  }

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

