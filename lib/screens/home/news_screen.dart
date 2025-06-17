import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/news_model.dart';
import '../../services/api_service.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({Key? key}) : super(key: key);

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final MetaQuotesApiService _apiService = MetaQuotesApiService();

  bool _isLoading = true;
  bool _isConnected = false;
  bool _usingMockData = false;
  String? _error;
  List<NewsArticle> _newsArticles = [];
  String? _note;

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  Future<void> _loadNews() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final newsResponse = await _apiService.getNews();

      setState(() {
        _newsArticles = newsResponse.articles;
        _isLoading = false;
        _isConnected = newsResponse.connected;
        _usingMockData = newsResponse.source == 'mock';
        _note = newsResponse.note;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
        _usingMockData = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181C23),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181C23),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Market News',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isLoading ? Icons.refresh : Icons.refresh,
              color: _isLoading ? Colors.grey : Colors.white,
            ),
            onPressed: _isLoading ? null : _loadNews,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_usingMockData) _buildDemoModeBanner(),
          Expanded(
            child: _buildNewsContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoModeBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.orange.withOpacity(0.1),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.orange, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _note ?? 'Showing demo news data. Server connection unavailable.',
              style: const TextStyle(
                color: Colors.orange,
                fontSize: 12,
              ),
            ),
          ),
          TextButton(
            onPressed: _loadNews,
            child: const Text(
              'Retry',
              style: TextStyle(color: Colors.orange, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.blue),
            SizedBox(height: 16),
            Text(
              'Loading news...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              'Error: $_error',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadNews,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_newsArticles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.article_outlined,
              size: 120,
              color: Colors.white24,
            ),
            SizedBox(height: 24),
            Text(
              'No news available',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _newsArticles.length,
      itemBuilder: (context, index) {
        final article = _newsArticles[index];
        return _buildNewsCard(article);
      },
    );
  }

  Widget _buildNewsCard(NewsArticle article) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: const Color(0xFF2A2E35),
      elevation: 4,
      child: InkWell(
        onTap: () => _showNewsDetail(article),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildPriorityBadge(article.priority),
                  const SizedBox(width: 8),
                  _buildCategoryChip(article.category),
                  const Spacer(),
                  _buildTimeAgo(article.timestamp),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                article.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                article.summary,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.person_outline,
                    color: Colors.white54,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    article.author,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  if (article.tags.isNotEmpty) ...[
                    const Icon(
                      Icons.label_outline,
                      color: Colors.white54,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      article.tags.first,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(String priority) {
    Color color;
    IconData icon;

    switch (priority.toLowerCase()) {
      case 'high':
        color = Colors.red;
        icon = Icons.priority_high;
        break;
      case 'medium':
        color = Colors.orange;
        icon = Icons.remove;
        break;
      case 'low':
        color = Colors.green;
        icon = Icons.keyboard_arrow_down;
        break;
      default:
        color = Colors.grey;
        icon = Icons.remove;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 2),
          Text(
            priority.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        category,
        style: const TextStyle(
          color: Colors.blue,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    String timeAgo;
    if (difference.inDays > 0) {
      timeAgo = '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      timeAgo = '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      timeAgo = '${difference.inMinutes}m ago';
    } else {
      timeAgo = 'Just now';
    }

    return Text(
      timeAgo,
      style: const TextStyle(
        color: Colors.white54,
        fontSize: 12,
      ),
    );
  }

  void _showNewsDetail(NewsArticle article) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF2A2E35),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Header
              Row(
                children: [
                  _buildPriorityBadge(article.priority),
                  const SizedBox(width: 8),
                  _buildCategoryChip(article.category),
                  const Spacer(),
                  _buildTimeAgo(article.timestamp),
                ],
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                article.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Author and date
              Row(
                children: [
                  const Icon(
                    Icons.person_outline,
                    color: Colors.white54,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    article.author,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(
                    Icons.access_time,
                    color: Colors.white54,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('MMM dd, yyyy HH:mm').format(article.timestamp),
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Tags
              if (article.tags.isNotEmpty) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: article.tags
                      .map((tag) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              tag,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 20),
              ],

              // Content
              Text(
                article.content,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
