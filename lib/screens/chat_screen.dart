// lib/screens/chat_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../models/ticket.dart';
import '../providers/app_providers.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final Ticket ticket;
  const ChatScreen({super.key, required this.ticket});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _textController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  Future<void> _handleAttachment() async {
    // 1. Pick Image
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    // 2. Mock Upload (In real app, upload to Firebase Storage here)
    // String downloadUrl = await uploadFile(File(image.path));
    String mockUrl = "https://via.placeholder.com/150";

    _sendMessage(imageUrl: mockUrl, attachmentName: image.name);
  }

  void _sendMessage({String? imageUrl, String? attachmentName}) {
    if (_textController.text.isEmpty && imageUrl == null) return;

    final role = ref.read(currentUserRoleProvider);
    final msg = ChatMessage(
      id: '',
      senderName: role == 'Customer'
          ? widget.ticket.customerName
          : 'Support Agent',
      role: role,
      text: _textController.text,
      timestamp: DateTime.now(),
      imageUrl: imageUrl,
      attachmentName: attachmentName,
    );

    ref
        .read(chatControllerProvider.notifier)
        .sendMessage(widget.ticket.id, msg);
    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(chatMessagesProvider(widget.ticket.id));
    final currentUserRole = ref.watch(currentUserRoleProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.ticket.title),
        actions: [
          // Staff can close tickets
          if (currentUserRole == 'Staff')
            PopupMenuButton<String>(
              onSelected: (status) {
                ref
                    .read(ticketControllerProvider.notifier)
                    .updateStatus(widget.ticket.id, status);
              },
              itemBuilder: (context) => [
                'Open',
                'Pending',
                'Closed',
              ].map((s) => PopupMenuItem(value: s, child: Text(s))).toList(),
            ),
        ],
      ),
      body: Column(
        children: [
          // 1. Ticket Details Header
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.grey[200],
            width: double.infinity,
            child: Text(
              widget.ticket.content,
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
          ),

          // 2. Chat List
          Expanded(
            child: messagesAsync.when(
              data: (messages) => ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  final isMe = msg.role == currentUserRole;
                  return _buildMessageBubble(msg, isMe);
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text("Error: $e")),
            ),
          ),

          // 3. Input Area
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: _handleAttachment,
                ),
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _sendMessage(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 250),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue[100] : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              msg.senderName,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
            if (msg.imageUrl != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Image.network(
                  msg.imageUrl!,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
            if (msg.text.isNotEmpty) Text(msg.text),
            if (msg.attachmentName != null)
              Chip(
                label: Text("📎 ${msg.attachmentName}"),
                backgroundColor: Colors.white,
              ),
          ],
        ),
      ),
    );
  }
}
