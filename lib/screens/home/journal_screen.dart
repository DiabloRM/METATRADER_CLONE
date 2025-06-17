import 'package:flutter/material.dart';
import '../../models/journal_model.dart';
import '../../services/api_service.dart';
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({Key? key}) : super(key: key);

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final MetaQuotesApiService _apiService = MetaQuotesApiService();
  bool _isLoading = true;
  bool _usingMockData = false;
  String? _error;
  List<JournalEntry> _logs = [];
  String? _note;
  String _date = '';

  @override
  void initState() {
    super.initState();
    _loadJournalLogs();
  }

  Future<void> _loadJournalLogs() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final response = await _apiService.getJournalLogs();
      setState(() {
        _logs = response.logs;
        _isLoading = false;
        _usingMockData = response.source == 'mock';
        _note = response.note;
        _date = response.date;
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Journal',
                style: TextStyle(color: Colors.white, fontSize: 20)),
            const SizedBox(height: 2),
            Text(_date.isNotEmpty ? _date : 'Today',
                style: const TextStyle(color: Colors.white54, fontSize: 14)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(_isLoading ? Icons.refresh : Icons.refresh,
                color: _isLoading ? Colors.grey : Colors.white70),
            onPressed: _isLoading ? null : _loadJournalLogs,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_usingMockData) _buildDemoModeBanner(),
          Expanded(child: _buildJournalContent()),
          if (_usingMockData) _buildAuthButtons(),
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
                  'Showing demo journal data. Server connection unavailable.',
              style: const TextStyle(color: Colors.orange, fontSize: 12),
            ),
          ),
          TextButton(
            onPressed: _loadJournalLogs,
            child: const Text('Retry',
                style: TextStyle(color: Colors.orange, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildJournalContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.blue),
            SizedBox(height: 16),
            Text('Loading journal...', style: TextStyle(color: Colors.white)),
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
            Text('Error: $_error',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
                onPressed: _loadJournalLogs, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (_logs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.article_outlined, size: 120, color: Colors.white24),
            SizedBox(height: 24),
            Text('No journal logs',
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                    fontWeight: FontWeight.w400)),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      itemCount: _logs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final log = _logs[index];
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 90,
              child: Text(
                log.time,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${log.type}  ',
                      style: TextStyle(
                        color: _getTypeColor(log.type),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    TextSpan(
                      text: log.message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'terminal':
        return Colors.blue;
      case 'activity':
        return Colors.green;
      case 'keystore':
        return Colors.orange;
      case 'chat':
        return Colors.purple;
      case 'time':
        return Colors.teal;
      case 'favorites':
        return Colors.pink;
      case 'whitelabel':
        return Colors.cyan;
      case 'gcm':
        return Colors.amber;
      case 'accounts':
        return Colors.indigo;
      case 'connection':
        return Colors.deepOrange;
      case 'auth':
        return Colors.red;
      case 'trading':
        return Colors.deepPurple;
      case 'system':
        return Colors.grey;
      default:
        return Colors.white;
    }
  }

  Widget _buildAuthButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
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
    );
  }
}
