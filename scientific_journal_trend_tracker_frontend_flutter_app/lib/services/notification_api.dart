import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/api_constants.dart';

class NotificationApi {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    headers: {
      'Content-Type': 'application/json',
    },
  ));

  static Future<void> _addAuthHeader() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  static Future<Map<String, dynamic>> getNotifications({int page = 1, int limit = 20}) async {
    await _addAuthHeader();
    try {
      final response = await _dio.get('${ApiConstants.baseUrl}/api/notifications', queryParameters: {
        'page': page,
        'limit': limit,
      });
      return response.data;
    } catch (e) {
      print('Error getting notifications: $e');
      throw e;
    }
  }

  static Future<int> getUnreadCount() async {
    await _addAuthHeader();
    try {
      final response = await _dio.get('${ApiConstants.baseUrl}/api/notifications/unread-count');
      return response.data['unreadCount'] ?? 0;
    } catch (e) {
      print('Error getting unread count: $e');
      return 0;
    }
  }

  static Future<void> markAsRead(String notificationId) async {
    await _addAuthHeader();
    try {
      await _dio.put('${ApiConstants.baseUrl}/api/notifications/$notificationId/read');
    } catch (e) {
      print('Error marking notification as read: $e');
      throw e;
    }
  }

  static Future<void> markAllAsRead() async {
    await _addAuthHeader();
    try {
      await _dio.put('${ApiConstants.baseUrl}/api/notifications/read-all');
    } catch (e) {
      print('Error marking all notifications as read: $e');
      throw e;
    }
  }

  static Future<void> deleteNotification(String notificationId) async {
    await _addAuthHeader();
    try {
      await _dio.delete('${ApiConstants.baseUrl}/api/notifications/$notificationId');
    } catch (e) {
      print('Error deleting notification: $e');
      throw e;
    }
  }

  static Future<void> clearAllNotifications() async {
    await _addAuthHeader();
    try {
      await _dio.delete('${ApiConstants.baseUrl}/api/notifications/all');
    } catch (e) {
      print('Error clearing all notifications: $e');
      throw e;
    }
  }
}
