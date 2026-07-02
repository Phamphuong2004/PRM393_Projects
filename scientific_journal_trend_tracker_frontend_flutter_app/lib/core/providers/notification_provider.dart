import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/notification_api.dart';
import '../constants/api_constants.dart';

class NotificationProvider with ChangeNotifier {
  List<dynamic> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  io.Socket? _socket;

  List<dynamic> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;

  NotificationProvider() {
    _init();
  }

  Future<void> _init() async {
    await fetchUnreadCount();
    await fetchNotifications();
    _connectSocket();
  }

  void _connectSocket() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) return;

    _socket = io.io(ApiConstants.baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    _socket?.onConnect((_) {
      debugPrint('Socket connected');
      _socket?.emit('authenticate', token);
    });

    _socket?.on('new_notification', (data) {
      debugPrint('New notification received via socket: $data');
      _notifications.insert(0, data);
      _unreadCount++;
      notifyListeners();
    });

    _socket?.onDisconnect((_) => debugPrint('Socket disconnected'));
  }

  void disconnectSocket() {
    _socket?.disconnect();
  }

  Future<void> fetchNotifications({int page = 1}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await NotificationApi.getNotifications(page: page);
      if (page == 1) {
        _notifications = data['notifications'] ?? [];
      } else {
        _notifications.addAll(data['notifications'] ?? []);
      }
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUnreadCount() async {
    try {
      _unreadCount = await NotificationApi.getUnreadCount();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching unread count: $e');
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await NotificationApi.markAsRead(id);
      
      final index = _notifications.indexWhere((n) => n['_id'] == id);
      if (index != -1 && _notifications[index]['isRead'] == false) {
        _notifications[index]['isRead'] = true;
        _unreadCount = _unreadCount > 0 ? _unreadCount - 1 : 0;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error marking as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await NotificationApi.markAllAsRead();
      for (var n in _notifications) {
        n['isRead'] = true;
      }
      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      debugPrint('Error marking all as read: $e');
    }
  }

  Future<void> clearAll() async {
    try {
      await NotificationApi.clearAllNotifications();
      _notifications.clear();
      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing notifications: $e');
    }
  }
}
