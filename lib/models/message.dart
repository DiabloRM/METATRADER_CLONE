class Message {
  final String id;
  final String title;
  final String content;
  final String sender;
  final DateTime timestamp;
  final bool isRead;
  final String type; // 'system', 'news', 'notification', etc.

  Message({
    required this.id,
    required this.title,
    required this.content,
    required this.sender,
    required this.timestamp,
    this.isRead = false,
    this.type = 'system',
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      sender: json['sender'] ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      isRead: json['is_read'] ?? false,
      type: json['type'] ?? 'system',
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
    };
  }

  Message copyWith({
    String? id,
    String? title,
    String? content,
    String? sender,
    DateTime? timestamp,
    bool? isRead,
    String? type,
  }) {
    return Message(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      sender: sender ?? this.sender,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
    );
  }
}
