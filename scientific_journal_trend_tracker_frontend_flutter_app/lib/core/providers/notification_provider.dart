import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../repositories/notification_repository.dart';
import '../constants/api_constants.dart';

class NotificationState {
  final List<dynamic> notifications;
  final int unreadCount;
  final bool isLoading;

  const NotificationState({
    this.notifications = const [],
    this.unreadCount = 0,
    this.isLoading = false,
  });

  NotificationState copyWith({
    List<dynamic>? notifications,
    int? unreadCount,
    bool? isLoading,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final notificationProvider = NotifierProvider<NotificationNotifier, NotificationState>(() {
  return NotificationNotifier();
});

class NotificationNotifier extends Notifier<NotificationState> {
  io.Socket? _socket;
  final _storage = const FlutterSecureStorage();

  @override
  NotificationState build() {
    _init();
    
    ref.onDispose(() {
      _socket?.disconnect();
    });
    
    return const NotificationState();
  }

  Future<void> _init() async {
    await fetchUnreadCount();
    await fetchNotifications();
    _connectSocket();
  }

  void _connectSocket() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) return;

    _socket = io.io(
      ApiConstants.baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .enableAutoConnect()
          .build(),
    );

    _socket?.onConnect((_) {
      debugPrint('Socket connected');
      _socket?.emit('authenticate', token);
    });

    _socket?.on('new_notification', (data) {
      debugPrint('New notification received via socket: $data');
      state = state.copyWith(
        notifications: [data, ...state.notifications],
        unreadCount: state.unreadCount + 1,
      );
    });

    _socket?.onDisconnect((_) => debugPrint('Socket disconnected'));
  }

  void disconnectSocket() {
    _socket?.disconnect();
  }

  Future<void> fetchNotifications({int page = 1}) async {
    state = state.copyWith(isLoading: true);

    try {
      final repo = ref.read(notificationRepositoryProvider);
      final data = await repo.getNotifications(page: page);
      
      if (page == 1) {
        state = state.copyWith(
          notifications: data['notifications'] ?? [],
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          notifications: [...state.notifications, ...(data['notifications'] ?? [])],
          isLoading: false,
        );
      }
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> fetchUnreadCount() async {
    try {
      final repo = ref.read(notificationRepositoryProvider);
      final count = await repo.getUnreadCount();
      state = state.copyWith(unreadCount: count);
    } catch (e) {
      debugPrint('Error fetching unread count: $e');
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      final repo = ref.read(notificationRepositoryProvider);
      await repo.markAsRead(id);
      
      final notifications = List<dynamic>.from(state.notifications);
      final index = notifications.indexWhere((n) {
        // Handle both Map and Model if possible. Our repository returns models but old api returned maps.
        // Assuming notifications are converted to Map or we handle model properties.
        // In the old code it was n['_id'], if we use models it will be n.id
        if (n is Map) return n['_id'] == id;
        return (n as dynamic).id == id;
      });

      if (index != -1) {
        final n = notifications[index];
        bool isRead = n is Map ? (n['isRead'] == true) : ((n as dynamic).isRead == true);
        
        if (!isRead) {
          if (n is Map) {
            notifications[index] = {...n, 'isRead': true};
          } else {
            // Need a copyWith on model ideally, for now just decrement count 
            // since we might not be able to mutate the model directly
            notifications[index] = (n as dynamic).copyWith(isRead: true);
          }
          
          state = state.copyWith(
            notifications: notifications,
            unreadCount: state.unreadCount > 0 ? state.unreadCount - 1 : 0,
          );
        }
      }
    } catch (e) {
      debugPrint('Error marking as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final repo = ref.read(notificationRepositoryProvider);
      await repo.markAllAsRead();
      
      final notifications = state.notifications.map((n) {
        if (n is Map) return {...n, 'isRead': true};
        return (n as dynamic).copyWith(isRead: true);
      }).toList();

      state = state.copyWith(
        notifications: notifications,
        unreadCount: 0,
      );
    } catch (e) {
      debugPrint('Error marking all as read: $e');
    }
  }

  Future<void> clearAll() async {
    try {
      final repo = ref.read(notificationRepositoryProvider);
      await repo.clearAll();
      state = state.copyWith(
        notifications: [],
        unreadCount: 0,
      );
    } catch (e) {
      debugPrint('Error clearing notifications: $e');
    }
  }
}
