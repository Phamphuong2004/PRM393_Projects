import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/chat_controller.dart';
import '../models/chat_message.dart';
import '../../../core/constants/theme.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<PlatformFile> _selectedFiles = [];

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
        withData: true,
      );

      if (result != null) {
        setState(() {
          // Limit total files to avoid memory overload
          for (var file in result.files) {
            // Max size 10MB
            if (file.size <= 10 * 1024 * 1024 && _selectedFiles.length < 3) {
              _selectedFiles.add(file);
            }
          }
        });
      }
    } catch (e) {
      debugPrint("Error picking file: $e");
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('AI Assistant', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      endDrawer: Drawer(
        backgroundColor: AppColors.surface,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  onPressed: () {
                    ref.read(chatControllerProvider.notifier).startNewSession();
                    Navigator.pop(context); // Close drawer
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('New Chat'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const Divider(),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text('Chat History', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textLight)),
              ),
              Expanded(
                child: chatState.sessions.isEmpty
                    ? const Center(child: Text('No history yet.', style: TextStyle(color: AppColors.textLight)))
                    : ListView.builder(
                        itemCount: chatState.sessions.length,
                        itemBuilder: (context, index) {
                          final session = chatState.sessions[index];
                          final isSelected = session.id == chatState.currentSessionId;
                          return ListTile(
                            leading: Icon(Icons.chat_bubble_outline, color: isSelected ? AppColors.primary : AppColors.textLight),
                            title: Text(
                              session.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.textLight),
                              onPressed: () {
                                ref.read(chatControllerProvider.notifier).deleteSession(session.id);
                              },
                            ),
                            selected: isSelected,
                            selectedTileColor: AppColors.primary.withValues(alpha: 0.1),
                            onTap: () {
                              ref.read(chatControllerProvider.notifier).loadSessionMessages(session.id);
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          if (chatState.error != null)
            Container(
              padding: const EdgeInsets.all(8),
              color: AppColors.error.withValues(alpha: 0.1),
              width: double.infinity,
              child: Text(
                chatState.error!,
                style: const TextStyle(color: AppColors.error),
                textAlign: TextAlign.center,
              ),
            ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: chatState.messages.length,
              itemBuilder: (context, index) {
                final msg = chatState.messages[index];
                return _buildChatBubble(msg);
              },
            ),
          ),
          if (chatState.isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage msg) {
    final isUser = msg.isUser;
    final text = msg.text;
    final timeStr = "${msg.createdAt.hour.toString().padLeft(2, '0')}:${msg.createdAt.minute.toString().padLeft(2, '0')} ${msg.createdAt.hour >= 12 ? 'pm' : 'am'}";

    Widget bubble = Container(
      margin: const EdgeInsets.only(bottom: 4),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: isUser ? AppColors.primary : AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(20),
          bottomLeft: Radius.circular(isUser ? 20 : 4),
          bottomRight: Radius.circular(isUser ? 4 : 20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (msg.attachments != null && msg.attachments!.isNotEmpty)
            ...msg.attachments!.map((file) {
              final isImage = file['mime_type']?.startsWith('image/') ?? false;
              if (isImage && file['base64_data'] != null) {
                try {
                  final imgBytes = base64Decode(file['base64_data']!);
                  return GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => Dialog(
                          backgroundColor: Colors.transparent,
                          insetPadding: EdgeInsets.zero,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              InteractiveViewer(
                                panEnabled: true,
                                minScale: 1,
                                maxScale: 4,
                                child: Image.memory(imgBytes, fit: BoxFit.contain),
                              ),
                              Positioned(
                                top: 40,
                                right: 20,
                                child: IconButton(
                                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    child: Image.memory(
                      imgBytes, 
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  );
                } catch (e) {
                  return const SizedBox.shrink();
                }
              } else {
                return Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 12),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8.0),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (isUser ? Colors.white : AppColors.primary).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.insert_drive_file, color: isUser ? Colors.white : AppColors.primary, size: 16),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            file['filename'] ?? 'Attachment',
                            style: TextStyle(color: isUser ? Colors.white : AppColors.textPrimary, fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            }),
          if (text.isNotEmpty && text != "Please analyze the attached file(s).")
            Padding(
              padding: EdgeInsets.only(
                left: 16, 
                right: 16, 
                top: (msg.attachments != null && msg.attachments!.any((f) => f['mime_type']?.startsWith('image/') ?? false)) ? 8 : 12,
                bottom: 12,
              ),
              child: MarkdownBody(
                data: text,
                selectable: true,
                onTapLink: (text, href, title) async {
                  if (href != null) {
                    final url = Uri.parse(href);
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    }
                  }
                },
                styleSheet: MarkdownStyleSheet(
                  p: TextStyle(color: isUser ? Colors.white : AppColors.textPrimary, fontSize: 15),
                  listBullet: TextStyle(color: isUser ? Colors.white : AppColors.textPrimary, fontSize: 15),
                  strong: TextStyle(color: isUser ? Colors.white : AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );

    Widget avatar = Container(
      margin: EdgeInsets.only(
        left: isUser ? 8 : 0,
        right: isUser ? 0 : 8,
      ),
      child: CircleAvatar(
        radius: 16,
        backgroundColor: isUser ? AppColors.primary.withValues(alpha: 0.1) : AppColors.secondary.withValues(alpha: 0.1),
        child: Icon(
          isUser ? Icons.person : Icons.smart_toy,
          size: 20,
          color: isUser ? AppColors.primary : AppColors.secondary,
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) avatar,
          Column(
            crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              bubble,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(timeStr, style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
                    if (!isUser) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: msg.text));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Copied to clipboard'), duration: Duration(seconds: 2)),
                          );
                        },
                        child: const Icon(Icons.copy, size: 12, color: AppColors.textLight),
                      ),
                    ],
                  ],
                ),
              )
            ],
          ),
          if (isUser) avatar,
        ],
      ),
    );
  }

  Widget _buildSelectedFiles() {
    if (_selectedFiles.isEmpty) return const SizedBox.shrink();
    return Container(
      height: 60,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedFiles.length,
        itemBuilder: (context, index) {
          final file = _selectedFiles[index];
          final isImage = file.extension?.toLowerCase() == 'jpg' || 
                          file.extension?.toLowerCase() == 'png' || 
                          file.extension?.toLowerCase() == 'jpeg';
          return Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isImage ? Icons.image : Icons.picture_as_pdf,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  file.name.length > 15 ? '${file.name.substring(0, 12)}...' : file.name,
                  style: const TextStyle(fontSize: 12, color: AppColors.primary),
                ),
                const SizedBox(width: 4),
                InkWell(
                  onTap: () => _removeFile(index),
                  child: const Icon(Icons.close, size: 16, color: AppColors.primary),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSelectedFiles(),
            Container(
              decoration: BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.circular(28),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.attach_file, color: AppColors.textLight),
                    onPressed: _pickFiles,
                  ),
                  const Text("|", style: TextStyle(color: AppColors.border, fontSize: 18)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: const InputDecoration(
                        hintText: 'Message',
                        hintStyle: TextStyle(color: AppColors.textLight),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 12),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.sentiment_satisfied, color: AppColors.textLight),
                    onPressed: () {},
                  ),
                  CircleAvatar(
                    backgroundColor: AppColors.primary,
                    radius: 20,
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage() {
    final text = _textController.text;
    if (text.trim().isEmpty && _selectedFiles.isEmpty) return;

    List<Map<String, String>> base64Files = [];
    for (var file in _selectedFiles) {
      if (file.bytes != null) {
        String mimeType = 'application/octet-stream';
        final ext = file.extension?.toLowerCase();
        if (ext == 'pdf') mimeType = 'application/pdf';
        if (ext == 'png') mimeType = 'image/png';
        if (ext == 'jpg' || ext == 'jpeg') mimeType = 'image/jpeg';
        
        base64Files.add({
          'filename': file.name,
          'mime_type': mimeType,
          'base64_data': base64Encode(file.bytes!),
        });
      }
    }

    ref.read(chatControllerProvider.notifier).sendMessage(
      text,
      files: base64Files,
    );
    
    setState(() {
      _selectedFiles.clear();
      _textController.clear();
    });
    
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }
}
