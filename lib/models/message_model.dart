class Message {
  final String id;
  final String title;
  final String content;
  final String sender;
  final DateTime timestamp;
  final bool isRead;
  final String type;
  final String priority;

  Message({
    required this.id,
    required this.title,
    required this.content,
    required this.sender,
    required this.timestamp,
    required this.isRead,
    required this.type,
    required this.priority,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      sender: json['sender'] ?? '',
      timestamp:
          DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      isRead: json['is_read'] ?? false,
      type: json['type'] ?? 'system',
      priority: json['priority'] ?? 'medium',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'sender': sender,
      'timestamp': timestamp.toIso8601String(),
      'is_read': isRead,
      'type': type,
      'priority': priority,
    };
  }
}

class MessagesResponse {
  final bool success;
  final List<Message> messages;
  final int unreadCount;
  final int totalCount;
  final String source;
  final String? note;
  final bool connected;
  final String? error;

  MessagesResponse({
    required this.success,
    required this.messages,
    required this.unreadCount,
    required this.totalCount,
    required this.source,
    this.note,
    required this.connected,
    this.error,
  });

  factory MessagesResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return MessagesResponse(
      success: json['success'] ?? false,
      messages: (data['messages'] as List<dynamic>?)
              ?.map((item) => Message.fromJson(item))
              .toList() ??
          [],
      unreadCount: data['unread_count'] ?? 0,
      totalCount: data['total_count'] ?? 0,
      source: json['source'] ?? 'mock',
      note: json['note'],
      connected: json['connected'] ?? false,
      error: json['error'],
    );
  }
}
