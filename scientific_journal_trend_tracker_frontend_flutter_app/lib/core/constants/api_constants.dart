class ApiConstants {
  // Thay đổi URL này tùy theo môi trường bạn đang chạy:
  static const String baseUrl =
      'https://prm393-projects-journal-tracking.up.railway.app'; // Dùng cho production (Railway)
  // static const String baseUrl = 'http://localhost:5000'; // Dùng cho chạy Web hoặc Windows Desktop
  // static const String baseUrl = 'http://10.0.2.2:5000'; // Dùng cho máy ảo Android Emulator

  // Auth
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';
  static const String me = '/api/auth/me';

  // Papers
  static const String papers = '/api/papers';
  static const String searchPapers = '/api/papers/search/query';

  // Keywords
  static const String keywords = '/api/keywords';
  static const String trendingKeywords = '/api/keywords/trends/trending';

  // Journals
  static const String journals = '/api/journals';

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
}
