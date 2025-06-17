class JournalEntry {
  final String id;
  final String timestamp;
  final String time;
  final String type;
  final String message;
  final String level;

  JournalEntry({
    required this.id,
    required this.timestamp,
    required this.time,
    required this.type,
    required this.message,
    required this.level,
  });

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id'] ?? '',
      timestamp: json['timestamp'] ?? '',
      time: json['time'] ?? '',
      type: json['type'] ?? '',
      message: json['message'] ?? '',
      level: json['level'] ?? 'info',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp,
      'time': time,
      'type': type,
      'message': message,
      'level': level,
    };
  }
}

class JournalResponse {
  final bool success;
  final List<JournalEntry> logs;
  final int totalCount;
  final String date;
  final String startTime;
  final String endTime;
  final String source;
  final String? note;
  final bool connected;
  final String? error;

  JournalResponse({
    required this.success,
    required this.logs,
    required this.totalCount,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.source,
    this.note,
    required this.connected,
    this.error,
  });

  factory JournalResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return JournalResponse(
      success: json['success'] ?? false,
      logs: (data['logs'] as List<dynamic>?)
              ?.map((item) => JournalEntry.fromJson(item))
              .toList() ??
          [],
      totalCount: data['total_count'] ?? 0,
      date: data['date'] ?? '',
      startTime: data['start_time'] ?? '',
      endTime: data['end_time'] ?? '',
      source: json['source'] ?? 'mock',
      note: json['note'],
      connected: json['connected'] ?? false,
      error: json['error'],
    );
  }
}
