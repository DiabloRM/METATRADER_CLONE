import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/mt5_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/message.dart';
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({Key? key}) : super(key: key);

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  List<Message> _messages = [];
  bool _loading = true;
  String? _error;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchMessages();
  }

  Future<void> _fetchMessages() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final mt5Provider = Provider.of<MT5Provider>(context, listen: false);

    // Check if user is authenticated
    if (!authProvider.isAuthenticated) {
      print('Debug: User not authenticated, showing empty state');
      setState(() {
        _messages = [];
        _unreadCount = 0;
        _loading = false;
      });
      return;
    }

    // Load MT5 settings if not already loaded
    if (mt5Provider.settings == null) {
      await mt5Provider.loadSettings();
    }

    final login = mt5Provider.settings?.login;
    print('Debug: Fetching messages for login: $login');

    if (login == null || login.isEmpty) {
      print('Debug: No login found, showing mock data');
      setState(() {
        _messages = [
          Message(
            id: '1',
            title: 'Welcome to MetaTrader 5',
            content:
                'Thank you for choosing MetaTrader 5. Your account has been successfully activated.',
            sender: 'System',
            timestamp: DateTime.now().subtract(Duration(days: 1)),
            isRead: false,
            type: 'system',
          ),
          Message(
            id: '2',
            title: 'Market Update',
            content:
                'Important market news: EUR/USD showing strong volatility. Check your positions.',
            sender: 'Market News',
            timestamp: DateTime.now().subtract(Duration(hours: 6)),
            isRead: true,
            type: 'news',
          ),
        ];
        _unreadCount = 1;
        _error = 'No login found. This is mock data.';
        _loading = false;
      });
      return;
    }

    try {
      final result = await mt5Provider.getMessages(login);
      print('Debug: Messages result: $result');

      if (result['success'] == true && result['data'] != null) {
        final messagesData = result['data']['messages'] as List<dynamic>;
        final messages =
            messagesData.map((json) => Message.fromJson(json)).toList();

        setState(() {
          _messages = messages;
          _unreadCount = result['data']['unread_count'] ?? 0;
          _loading = false;
        });
      } else {
        setState(() {
          _error = result['error'] ?? 'Failed to fetch messages.';
          _loading = false;
        });
      }
    } catch (e) {
      print('Debug: Messages API error: $e');
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Column(
      children: [
        Container(
          color: const Color(0xFF232A34),
          padding: const EdgeInsets.only(top: 36, left: 8, right: 8, bottom: 8),
          child: Row(
            children: [
              Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Messages',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF23262B),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'MQID',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(Icons.search, color: Colors.white),
                      onPressed: () {},
                    ),
                    if (authProvider.isAuthenticated)
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        onPressed: _fetchMessages,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (_error != null && _error!.contains('mock data'))
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _error!,
                    style: const TextStyle(
                      color: Colors.orange,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white))
              : authProvider.isAuthenticated
                  ? _buildMessagesList()
                  : _buildUnauthenticatedState(),
        ),
        if (!authProvider.isAuthenticated ||
            (authProvider.isAuthenticated &&
                (_messages.isEmpty &&
                    _error != null &&
                    _error!.contains('mock data'))))
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'REGISTER',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 100,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white24),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'SIGN IN',
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildMessagesList() {
    if (_messages.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 120,
              color: Colors.white24,
            ),
            SizedBox(height: 16),
            Text(
              'No messages',
              style: TextStyle(color: Colors.white60, fontSize: 18),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return _buildMessageTile(message);
      },
    );
  }

  Widget _buildMessageTile(Message message) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color:
            message.isRead ? const Color(0xFF2E3742) : const Color(0xFF3A4750),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: _getMessageTypeColor(message.type),
          child: Icon(
            _getMessageTypeIcon(message.type),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          message.title,
          style: TextStyle(
            color: Colors.white,
            fontWeight: message.isRead ? FontWeight.normal : FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              message.content,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  message.sender,
                  style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(
                  _formatTimestamp(message.timestamp),
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: () {
          // TODO: Navigate to message detail screen
          print('Tapped message: ${message.id}');
        },
      ),
    );
  }

  Widget _buildUnauthenticatedState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 120,
            color: Colors.white24,
          ),
          SizedBox(height: 16),
          Text(
            'No messages',
            style: TextStyle(color: Colors.white60, fontSize: 18),
          ),
          SizedBox(height: 8),
          Text(
            'Sign in to view your messages',
            style: TextStyle(color: Colors.white38, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Color _getMessageTypeColor(String type) {
    switch (type) {
      case 'system':
        return Colors.blue;
      case 'news':
        return Colors.green;
      case 'notification':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getMessageTypeIcon(String type) {
    switch (type) {
      case 'system':
        return Icons.settings;
      case 'news':
        return Icons.newspaper;
      case 'notification':
        return Icons.notifications;
      default:
        return Icons.message;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
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
}
