import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../models/chat_message.dart';
import '../../../core/providers/network_provider.dart';
import '../../../core/constants/api_constants.dart';

import '../models/chat_session.dart';

class ChatState {
  final List<ChatMessage> messages;
  final List<ChatSession> sessions;
  final String? currentSessionId;
  final bool isLoading;
  final String? error;

  ChatState({
    this.messages = const [],
    this.sessions = const [],
    this.currentSessionId,
    this.isLoading = false,
    this.error,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    List<ChatSession>? sessions,
    String? currentSessionId,
    bool? isLoading,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      sessions: sessions ?? this.sessions,
      currentSessionId: currentSessionId ?? this.currentSessionId,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ChatController extends Notifier<ChatState> {
  late final Dio _dio;

  @override
  ChatState build() {
    _dio = ref.watch(dioProvider);
    // Load sessions in the background
    Future.microtask(() => loadSessions());
    return ChatState(
      messages: _getWelcomeMessage(),
    );
  }

  List<ChatMessage> _getWelcomeMessage() {
    return [
      ChatMessage(
        id: DateTime.now().toString(),
        text: 'Hello! I am your AI Research Assistant. How can I help you today?',
        isUser: false,
        createdAt: DateTime.now(),
      )
    ];
  }

  Future<void> loadSessions() async {
    try {
      final response = await _dio.get(ApiConstants.chatSessions);
      final List<dynamic> data = response.data;
      final sessions = data.map((json) => ChatSession.fromJson(json)).toList();
      state = state.copyWith(sessions: sessions);
    } catch (e) {
      debugPrint('Failed to load sessions: $e');
    }
  }

  void startNewSession() {
    state = ChatState(
      messages: _getWelcomeMessage(),
      sessions: state.sessions,
      currentSessionId: null,
      isLoading: false,
    );
  }

  Future<void> loadSessionMessages(String sessionId) async {
    state = state.copyWith(isLoading: true, currentSessionId: sessionId, error: null);
    try {
      final response = await _dio.get('${ApiConstants.chatSessions}/$sessionId');
      final sessionData = response.data;
      final messagesList = (sessionData['messages'] as List).map((m) {
        return ChatMessage(
          id: m['_id'] ?? DateTime.now().toString(),
          text: m['content'],
          isUser: m['role'] == 'user',
          createdAt: DateTime.parse(m['createdAt']),
          attachments: (m['files'] as List?)?.map((f) => Map<String, String>.from(f)).toList(),
        );
      }).toList();
      
      state = state.copyWith(
        messages: [_getWelcomeMessage().first, ...messagesList],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to load session');
    }
  }

  Future<void> deleteSession(String sessionId) async {
    try {
      await _dio.delete('${ApiConstants.chatSessions}/$sessionId');
      final updatedSessions = state.sessions.where((s) => s.id != sessionId).toList();
      state = state.copyWith(sessions: updatedSessions);
      
      if (state.currentSessionId == sessionId) {
        startNewSession();
      }
    } catch (e) {
      debugPrint('Failed to delete session: $e');
    }
  }

  Future<void> sendMessage(String text, {List<Map<String, String>>? files}) async {
    final hasFiles = files != null && files.isNotEmpty;
    if (text.trim().isEmpty && !hasFiles) return;

    final finalQuery = text.trim().isEmpty && hasFiles 
        ? "Please analyze the attached file(s)." 
        : text;

    final userMsg = ChatMessage(
      id: DateTime.now().toString(),
      text: finalQuery,
      isUser: true,
      createdAt: DateTime.now(),
      attachments: files,
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isLoading: true,
      error: null,
    );

    try {
      final response = await _dio.post(ApiConstants.chatAsk, data: {
        'question': finalQuery,
        if (hasFiles) 'files': files,
        if (state.currentSessionId != null) 'sessionId': state.currentSessionId,
      });
      
      final aiText = response.data['answer'] ?? 'No response generated.';
      
      final aiMsg = ChatMessage(
        id: DateTime.now().toString(),
        text: aiText,
        isUser: false,
        createdAt: DateTime.now(),
      );

      final newSessionId = response.data['sessionId'];
      bool shouldReloadSessions = false;
      String? updatedSessionId = state.currentSessionId;
      if (newSessionId != null && state.currentSessionId != newSessionId) {
        updatedSessionId = newSessionId;
        shouldReloadSessions = true;
      }

      state = state.copyWith(
        messages: [...state.messages, aiMsg],
        currentSessionId: updatedSessionId,
        isLoading: false,
      );
      
      if (shouldReloadSessions) {
        loadSessions();
      }
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data['message'] ?? e.message ?? 'An error occurred while fetching AI response.',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

final chatControllerProvider = NotifierProvider<ChatController, ChatState>(() {
  return ChatController();
});
