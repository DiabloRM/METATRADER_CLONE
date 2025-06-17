class NewsArticle {
  final String id;
  final String title;
  final String summary;
  final String content;
  final String category;
  final String priority;
  final String author;
  final DateTime timestamp;
  final List<String> tags;
  final String? imageUrl;

  NewsArticle({
    required this.id,
    required this.title,
    required this.summary,
    required this.content,
    required this.category,
    required this.priority,
    required this.author,
    required this.timestamp,
    required this.tags,
    this.imageUrl,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      summary: json['summary'] ?? '',
      content: json['content'] ?? '',
      category: json['category'] ?? '',
      priority: json['priority'] ?? 'medium',
      author: json['author'] ?? '',
      timestamp:
          DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      tags: List<String>.from(json['tags'] ?? []),
      imageUrl: json['image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      'content': content,
      'category': category,
      'priority': priority,
      'author': author,
      'timestamp': timestamp.toIso8601String(),
      'tags': tags,
      'image_url': imageUrl,
    };
  }
}

class NewsResponse {
  final bool success;
  final List<NewsArticle> articles;
  final String source;
  final String? note;
  final bool connected;
  final String? error;

  NewsResponse({
    required this.success,
    required this.articles,
    required this.source,
    this.note,
    required this.connected,
    this.error,
  });

  factory NewsResponse.fromJson(Map<String, dynamic> json) {
    return NewsResponse(
      success: json['success'] ?? false,
      articles: (json['data'] as List<dynamic>?)
              ?.map((item) => NewsArticle.fromJson(item))
              .toList() ??
          [],
      source: json['source'] ?? 'mock',
      note: json['note'],
      connected: json['connected'] ?? false,
      error: json['error'],
    );
  }
}
