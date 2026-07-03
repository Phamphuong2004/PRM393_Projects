import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
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
      debugPrint('Error getting notifications: $e');
      rethrow;
    }
  }

  static Future<int> getUnreadCount() async {
    await _addAuthHeader();
    try {
      final response = await _dio.get('${ApiConstants.baseUrl}/api/notifications/unread-count');
      return response.data['unreadCount'] ?? 0;
    } catch (e) {
      debugPrint('Error getting unread count: $e');
      return 0;
    }
  }

  static Future<void> markAsRead(String notificationId) async {
    await _addAuthHeader();
    try {
      await _dio.put('${ApiConstants.baseUrl}/api/notifications/$notificationId/read');
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
      rethrow;
    }
  }

  static Future<void> markAllAsRead() async {
    await _addAuthHeader();
    try {
      await _dio.put('${ApiConstants.baseUrl}/api/notifications/read-all');
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
      rethrow;
    }
  }

  static Future<void> deleteNotification(String notificationId) async {
    await _addAuthHeader();
    try {
      await _dio.delete('${ApiConstants.baseUrl}/api/notifications/$notificationId');
    } catch (e) {
      debugPrint('Error deleting notification: $e');
      rethrow;
    }
  }

  static Future<void> clearAllNotifications() async {
    await _addAuthHeader();
    try {
      await _dio.delete('${ApiConstants.baseUrl}/api/notifications/all');
    } catch (e) {
      debugPrint('Error clearing all notifications: $e');
      rethrow;
    }
  }
}
