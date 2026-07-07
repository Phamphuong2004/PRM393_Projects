class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime createdAt;
  final List<Map<String, String>>? attachments;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.createdAt,
    this.attachments,
  });
}
