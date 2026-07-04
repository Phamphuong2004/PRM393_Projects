import 'package:flutter/foundation.dart';

class ApiConstants {
  // Đặt là true nếu chạy Local Backend, đặt là false nếu chạy Railway Backend (Production)
  static const bool useLocal = false;

  static String get baseUrl {
    if (!useLocal) {
      return 'https://prm393-projects-journal-tracking.up.railway.app';
    }

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) return 'http://10.0.2.2:5000';
    return 'http://localhost:5000';
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
  static const String adminUsers = '/api/admin/users';
  static const String adminSources = '/api/admin/sources';
  static const String adminSync = '/api/admin/sync';

  // Authors
  static const String authors = '/api/authors';

  // Sync Logs
  static const String syncLogs = '/api/sync-logs';

  // Workspaces
  static const String workspaces = '/api/workspaces';
}
