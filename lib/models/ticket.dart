// lib/models/ticket.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Ticket {
  final String id;
  final DateTime date;
  final String customerName;
  final String category;
  final String title;
  final String content;
  final String status; // 'Open', 'Pending', 'Closed'

  Ticket({
    required this.id,
    required this.date,
    required this.customerName,
    required this.category,
    required this.title,
    required this.content,
    required this.status,
  });

  factory Ticket.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Ticket(
      id: doc.id,
      date: (data['date'] as Timestamp).toDate(),
      customerName: data['customerName'] ?? '',
      category: data['category'] ?? 'General',
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      status: data['status'] ?? 'Open',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date),
      'customerName': customerName,
      'category': category,
      'title': title,
      'content': content,
      'status': status,
    };
  }
}

class ChatMessage {
  final String id;
  final String senderName;
  final String role; // 'Customer' or 'Staff'
  final String text;
  final String? imageUrl;
  final String? attachmentName;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.senderName,
    required this.role,
    required this.text,
    this.imageUrl,
    this.attachmentName,
    required this.timestamp,
  });

  factory ChatMessage.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      senderName: data['senderName'] ?? 'Unknown',
      role: data['role'] ?? 'Customer',
      text: data['text'] ?? '',
      imageUrl: data['imageUrl'],
      attachmentName: data['attachmentName'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderName': senderName,
      'role': role,
      'text': text,
      'imageUrl': imageUrl,
      'attachmentName': attachmentName,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
