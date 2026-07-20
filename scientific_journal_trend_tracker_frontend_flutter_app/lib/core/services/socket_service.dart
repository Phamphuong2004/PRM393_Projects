import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_constants.dart';

/// Singleton Socket.IO service for real-time features.
/// Usage:
///   await SocketService.instance.connect();
///   SocketService.instance.joinWorkspace('workspaceId');
///   SocketService.instance.onChatMessage((msg) { ... });
class SocketService {
  SocketService._();
  static final SocketService instance = SocketService._();

  io.Socket? _socket;
  final _storage = const FlutterSecureStorage();
  String? _currentWorkspaceId;

  bool get isConnected => _socket?.connected ?? false;

  /// Connect and authenticate with the backend Socket.IO server.
  Future<void> connect() async {
    if (_socket != null) {
      if (!_socket!.connected) {
        _socket!.connect();
      }
      return;
    }

    final token = await _storage.read(key: 'jwt_token');
    if (token == null) return;

    // Use interaction-service port directly for Socket.IO (5003)
    // because the API gateway may not proxy WebSocket upgrades for all routes.
    final socketUrl = ApiConstants.socketUrl;

    _socket = io.io(
      socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(5)
          .setReconnectionDelay(2000)
          .build(),
    );

    _socket!.connect();

    _socket!.onConnect((_) {
      debugPrint('[Socket] Connected: ${_socket!.id}');
      // Authenticate immediately after connecting
      _socket!.emit('authenticate', token);
    });

    _socket!.on('authenticated', (data) {
      debugPrint('[Socket] Authenticated successfully');
      if (_currentWorkspaceId != null) {
        _socket!.emit('join_workspace', _currentWorkspaceId);
        debugPrint('[Socket] Re-joining workspace room: $_currentWorkspaceId');
      }
    });

    _socket!.on('auth_error', (data) {
      debugPrint('[Socket] Auth error: $data');
    });

    _socket!.onDisconnect((_) {
      debugPrint('[Socket] Disconnected');
    });

    _socket!.onError((err) {
      debugPrint('[Socket] Error: $err');
    });
  }

  /// Disconnect from Socket.IO server.
  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }

  /// Join a workspace room to receive real-time chat messages.
  void joinWorkspace(String workspaceId) {
    _currentWorkspaceId = workspaceId;
    if (_socket?.connected == true) {
      _socket!.emit('join_workspace', workspaceId);
      debugPrint('[Socket] Joining workspace room: $workspaceId');
    }
  }

  /// Leave a workspace room.
  void leaveWorkspace(String workspaceId) {
    if (_currentWorkspaceId == workspaceId) {
      _currentWorkspaceId = null;
    }
    if (_socket?.connected == true) {
      _socket!.emit('leave_workspace', workspaceId);
      debugPrint('[Socket] Leaving workspace room: $workspaceId');
    }
  }

  /// Listen for new chat messages in the current workspace room.
  /// Call this ONCE per screen and save the callback ref to remove it later.
  void onChatMessage(void Function(Map<String, dynamic> message) callback) {
    _socket?.on('new_chat_message', (data) {
      try {
        final msg = Map<String, dynamic>.from(data as Map);
        callback(msg);
      } catch (e) {
        debugPrint('[Socket] Failed to parse chat message: $e');
      }
    });
  }

  /// Remove ALL listeners for 'new_chat_message'.
  /// Call this in dispose() of the chat screen.
  void offChatMessage() {
    _socket?.off('new_chat_message');
  }

  /// Listen for new notifications.
  void onNotification(void Function(Map<String, dynamic> data) callback) {
    _socket?.on('new_notification', (data) {
      try {
        callback(Map<String, dynamic>.from(data as Map));
      } catch (e) {
        debugPrint('[Socket] Failed to parse notification: $e');
      }
    });
  }

  void offNotification() {
    _socket?.off('new_notification');
  }
}
