import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/mt5_provider.dart';

class TradeScreen extends StatefulWidget {
  const TradeScreen({Key? key}) : super(key: key);

  @override
  State<TradeScreen> createState() => _TradeScreenState();
}

class _TradeScreenState extends State<TradeScreen> {
  Map<String, dynamic>? _accountInfo;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchAccountInfo();
  }

  Future<void> _fetchAccountInfo() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final mt5Provider = Provider.of<MT5Provider>(context, listen: false);

    // Load settings first if not already loaded
    if (mt5Provider.settings == null) {
      await mt5Provider.loadSettings();
    }

    final login = mt5Provider.settings?.login;
    print('Debug: Login found: $login'); // Debug log

    if (login == null || login.isEmpty) {
      print('Debug: No login found, showing mock data'); // Debug log
      setState(() {
        _accountInfo = {
          'balance': '100,000.00',
          'equity': '100,000.00',
          'free_margin': '100,000.00',
        };
        _error = 'No login found. This is mock data.';
        _loading = false;
      });
      return;
    }

    try {
      final result = await mt5Provider.getMT5AccountInfo(login);
      print('Debug: API result: $result'); // Debug log
      if (result['success'] == true && result['data'] != null) {
        setState(() {
          _accountInfo = result['data'];
          _loading = false;
        });
      } else {
        setState(() {
          _error = result['error'] ?? 'Failed to fetch account info.';
          _loading = false;
        });
      }
    } catch (e) {
      print('Debug: API error: $e'); // Debug log
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: const Color(0xFF232A34),
          padding: const EdgeInsets.only(top: 36, left: 8, right: 8, bottom: 8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
              const SizedBox(width: 8),
              const Text(
                'Trade',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.import_export, color: Colors.white),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.add_box_outlined, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
        ),
        Container(
          color: const Color(0xFF232A34),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white))
              : Column(
                  children: [
                    if (_error != null && _error!.contains('mock data'))
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 12),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border:
                              Border.all(color: Colors.orange.withOpacity(0.5)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline,
                                color: Colors.orange, size: 16),
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
                    _summaryRow('Balance:',
                        _accountInfo?['balance']?.toString() ?? '-'),
                    _summaryRow(
                        'Equity:', _accountInfo?['equity']?.toString() ?? '-'),
                    _summaryRow('Free margin:',
                        _accountInfo?['free_margin']?.toString() ?? '-'),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
