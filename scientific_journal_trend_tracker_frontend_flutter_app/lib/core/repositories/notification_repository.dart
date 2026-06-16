import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification.dart';
import '../providers/network_provider.dart';
import '../constants/api_constants.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return NotificationRepository(dio);
});

class NotificationRepository {
  final Dio _dio;

  NotificationRepository(this._dio);

  Future<Map<String, dynamic>> getNotifications({int page = 1, int limit = 20}) async {
    try {
      final response = await _dio.get(
        ApiConstants.notifications,
        queryParameters: {'page': page, 'limit': limit},
      );
      final notificationsJson = (response.data['data'] as List?) ?? [];
      final notifications = notificationsJson.map((e) => NotificationModel.fromJson(e as Map<String, dynamic>)).toList();
      return {
        'notifications': notifications,
        'pagination': response.data['pagination'],
      };
    } catch (e) {
      rethrow;
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final response = await _dio.get('${ApiConstants.notifications}/unread/count');
      return response.data['count'] ?? 0;
    } catch (e) {
      return 0;
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _dio.put('${ApiConstants.notifications}/$id/read');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _dio.put('${ApiConstants.notifications}/all/read');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      await _dio.delete('${ApiConstants.notifications}/$id');
    } catch (e) {
      rethrow;
    }
  }
}
