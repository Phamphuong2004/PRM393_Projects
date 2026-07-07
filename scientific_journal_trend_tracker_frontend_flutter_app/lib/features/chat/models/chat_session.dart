class ChatSession {
  final String id;
  final String title;
  final DateTime updatedAt;

  ChatSession({
    required this.id,
    required this.title,
    required this.updatedAt,
  });

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['_id'],
      title: json['title'] ?? 'New Chat',
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
