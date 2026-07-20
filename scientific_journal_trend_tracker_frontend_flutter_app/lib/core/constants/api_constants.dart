import 'package:flutter/foundation.dart';

class ApiConstants {
  // Đặt là true để dùng hệ thống Microservices backend mới đang chạy local
  static const bool useLocal = true;

  static String get baseUrl {
    if (!useLocal) {
      return 'https://api-gateway-production-db98.up.railway.app';
    }

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5000';
    }
    return 'http://localhost:5000';
  }

  /// Socket.IO connects directly to interaction-service (port 5003)
  /// because the API gateway may not proxy WebSocket upgrades.
  static String get socketUrl {
    if (!useLocal) {
      // In production, Socket.IO is proxied through the API gateway
      return 'https://api-gateway-production-db98.up.railway.app';
    }
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5003';
    }
    return 'http://localhost:5003';
  }


  // Auth
  static const String login = '/api/auth/login';
  static const String googleLogin = '/api/auth/google-login';
  static const String register = '/api/auth/register';
  static const String me = '/api/auth/me';

  // Papers
  static const String papers = '/api/papers';
  static const String searchPapers = '/api/papers/search/query';
  static const String searchExternalPapers = '/api/papers/external/search';
  static const String importPaper = '/api/papers/import';

  // Keywords
  static const String keywords = '/api/keywords';
  static const String trendingKeywords = '/api/keywords/trends/trending';

  // Journals
  static const String journals = '/api/journals';

  // Institutions
  static const String institutions = '/api/institutions';

  // Topics
  static const String topics = '/api/topics';
  static const String emergingTopics = '/api/topics/emerging/list';

  // Publication Trends
  static const String publicationTrends = '/api/publication-trends';
  static const String trendingPublications =
      '/api/publication-trends/trending/list';

  // Notifications
  static const String notifications = '/api/notifications';

  // Bookmarks
  static const String bookmarks = '/api/bookmarks';

  // Follows
  static const String follows = '/api/follows';

  // Users
  static const String users = '/api/users';
  static const String adminStats = '/api/users/admin/stats';

  // Dashboard
  static const String dashboardStats = '/api/dashboard/stats';

  // Analysis Runs
  static const String analysisRuns = '/api/analysis-runs';

  // Admin

  static const String adminSources = '/api/admin/sources';
  static const String adminSync = '/api/admin/sync';

  // Authors
  static const String authors = '/api/authors';

  // Sync Logs
  static const String syncLogs = '/api/sync-logs';

  // Workspaces
  static const String workspaces = '/api/workspaces';

  // Chat
  static const String chatSessions = '/api/chat/sessions';
  static const String chatAsk = '/api/chat/ask';
}
