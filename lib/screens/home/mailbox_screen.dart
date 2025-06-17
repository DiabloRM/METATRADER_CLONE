import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/message_model.dart';
import '../../services/api_service.dart';

class MailboxScreen extends StatefulWidget {
  const MailboxScreen({Key? key}) : super(key: key);

  @override
  State<MailboxScreen> createState() => _MailboxScreenState();
}

class _MailboxScreenState extends State<MailboxScreen> {
  final MetaQuotesApiService _apiService = MetaQuotesApiService();

  bool _isLoading = true;
  bool _isConnected = false;
  bool _usingMockData = false;
  String? _error;
  List<Message> _messages = [];
  int _unreadCount = 0;
  int _totalCount = 0;
  String? _note;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final messagesResponse = await _apiService.getMessages();

      setState(() {
        _messages = messagesResponse.messages;
        _isLoading = false;
        _isConnected = messagesResponse.connected;
        _usingMockData = messagesResponse.source == 'mock';
        _note = messagesResponse.note;
        _unreadCount = messagesResponse.unreadCount;
        _totalCount = messagesResponse.totalCount;
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
        title: Row(
          children: [
            const Text(
              'Mailbox',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            if (_unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$_unreadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isLoading ? Icons.refresh : Icons.refresh,
              color: _isLoading ? Colors.grey : Colors.white,
            ),
            onPressed: _isLoading ? null : _loadMessages,
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white70, size: 28),
            onPressed: () => _showComposeDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_usingMockData) _buildDemoModeBanner(),
          Expanded(
            child: _buildMessagesContent(),
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
              _note ??
                  'Showing demo message data. Server connection unavailable.',
              style: const TextStyle(
                color: Colors.orange,
                fontSize: 12,
              ),
            ),
          ),
          TextButton(
            onPressed: _loadMessages,
            child: const Text(
              'Retry',
              style: TextStyle(color: Colors.orange, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.blue),
            SizedBox(height: 16),
            Text(
              'Loading messages...',
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
              onPressed: _loadMessages,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.mail_outline,
              size: 120,
              color: Colors.white24,
            ),
            SizedBox(height: 24),
            Text(
              'No messages',
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

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _messages.length,
      separatorBuilder: (context, index) => Divider(
        color: Colors.white12,
        height: 1,
        indent: 72,
      ),
      itemBuilder: (context, index) {
        final message = _messages[index];
        return _buildMessageTile(message);
      },
    );
  }

  Widget _buildMessageTile(Message message) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _getMessageTypeColor(message.type).withOpacity(0.2),
          border: Border.all(
            color: _getMessageTypeColor(message.type),
            width: 1,
          ),
        ),
        child: Center(
          child: Icon(
            _getMessageTypeIcon(message.type),
            color: _getMessageTypeColor(message.type),
            size: 20,
          ),
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              message.sender,
              style: TextStyle(
                color: Colors.white,
                fontWeight:
                    message.isRead ? FontWeight.normal : FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          if (!message.isRead)
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue,
              ),
            ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            message.title,
            style: TextStyle(
              color: message.isRead ? Colors.white70 : Colors.white,
              fontSize: 14,
              fontWeight: message.isRead ? FontWeight.normal : FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              _buildPriorityBadge(message.priority),
              const SizedBox(width: 8),
              _buildTypeChip(message.type),
              const Spacer(),
              Text(
                _getTimeAgo(message.timestamp),
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      minLeadingWidth: 0,
      onTap: () => _showMessageDetail(message),
    );
  }

  Color _getMessageTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'system':
        return Colors.blue;
      case 'notification':
        return Colors.orange;
      case 'promotion':
        return Colors.purple;
      case 'educational':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getMessageTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'system':
        return Icons.settings;
      case 'notification':
        return Icons.notifications;
      case 'promotion':
        return Icons.local_offer;
      case 'educational':
        return Icons.school;
      default:
        return Icons.mail;
    }
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
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 10),
          const SizedBox(width: 2),
          Text(
            priority.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 8,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(String type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _getMessageTypeColor(type).withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        type.toUpperCase(),
        style: TextStyle(
          color: _getMessageTypeColor(type),
          fontSize: 8,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _showMessageDetail(Message message) {
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
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          _getMessageTypeColor(message.type).withOpacity(0.2),
                      border: Border.all(
                        color: _getMessageTypeColor(message.type),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        _getMessageTypeIcon(message.type),
                        color: _getMessageTypeColor(message.type),
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message.sender,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('MMM dd, yyyy HH:mm')
                              .format(message.timestamp),
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      _buildPriorityBadge(message.priority),
                      const SizedBox(height: 8),
                      _buildTypeChip(message.type),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                message.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Content
              Text(
                message.content,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 20),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _markAsRead(message),
                      icon: const Icon(Icons.mark_email_read),
                      label: const Text('Mark as Read'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _replyToMessage(message),
                      icon: const Icon(Icons.reply),
                      label: const Text('Reply'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComposeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2E35),
        title: const Text(
          'Compose Message',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'To',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white30),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Subject',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white30),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextField(
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Message',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white30),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement send message
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Message sent!')),
              );
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  void _markAsRead(Message message) {
    // TODO: Implement mark as read functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Message marked as read')),
    );
    Navigator.of(context).pop();
  }

  void _replyToMessage(Message message) {
    // TODO: Implement reply functionality
    Navigator.of(context).pop();
    _showComposeDialog();
  }
}
