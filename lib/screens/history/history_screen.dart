import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/mt5_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? _positionsData;
  Map<String, dynamic>? _ordersData;
  Map<String, dynamic>? _dealsData;
  bool _loading = true;
  String? _error;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });
    _fetchHistoryData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchHistoryData() async {
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
    print('Debug: Fetching history for login: $login');

    if (login == null || login.isEmpty) {
      print('Debug: No login found, showing mock data');
      setState(() {
        _positionsData = {
          'summary': {
            'profit': '0.00',
            'deposit': '100,000.00',
            'swap': '0.00',
            'commission': '0.00',
            'balance': '100,000.00',
          },
          'history': [
            {
              'date': '2025.06.11 13:06:41',
              'balance': '100,000.00',
              'type': 'balance',
            }
          ]
        };
        _ordersData = {'orders': []};
        _dealsData = {'deals': []};
        _error = 'No login found. This is mock data.';
        _loading = false;
      });
      return;
    }

    try {
      // Fetch positions history
      final positionsResult = await mt5Provider.getMT5Positions(login);
      print('Debug: Positions result: $positionsResult');

      // Fetch orders history
      final ordersResult = await mt5Provider.getMT5Orders(login);
      print('Debug: Orders result: $ordersResult');

      setState(() {
        if (positionsResult['success'] == true) {
          _positionsData = positionsResult['data'];
        } else {
          _positionsData = {
            'summary': {
              'profit': '0.00',
              'deposit': '100,000.00',
              'swap': '0.00',
              'commission': '0.00',
              'balance': '100,000.00',
            },
            'history': []
          };
        }

        if (ordersResult['success'] == true) {
          _ordersData = ordersResult['data'];
        } else {
          _ordersData = {'orders': []};
        }

        _dealsData = {'deals': []}; // Deals not implemented yet
        _loading = false;
      });
    } catch (e) {
      print('Debug: History API error: $e');
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            color: const Color(0xFF232A34),
            padding: const EdgeInsets.only(
              top: 36,
              left: 8,
              right: 8,
              bottom: 0,
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
                const SizedBox(width: 8),
                const Text(
                  'History',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'All symbols',
                  style: TextStyle(
                    color: Color(0xFF7A8597),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.sync, color: Colors.white),
                  onPressed: _fetchHistoryData,
                ),
                IconButton(
                  icon: const Icon(Icons.import_export, color: Colors.white),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(
                    Icons.calendar_today,
                    color: Colors.white,
                    size: 22,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          Container(
            color: const Color(0xFF232A34),
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.blue,
              labelColor: Colors.white,
              unselectedLabelColor: Color(0xFF7A8597),
              labelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
              tabs: [
                Tab(text: 'POSITIONS'),
                Tab(text: 'ORDERS'),
                Tab(text: 'DEALS'),
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
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _positionsTab(),
                      _ordersTab(),
                      _dealsTab(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _positionsTab() {
    if (_positionsData == null) {
      return const Center(
        child: Text(
          'No data available',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    final summary = _positionsData!['summary'] as Map<String, dynamic>? ?? {};
    final history = _positionsData!['history'] as List<dynamic>? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: const Color(0xFF232A34),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              _summaryRow('Profit:', summary['profit']?.toString() ?? '0.00',
                  valueColor: Colors.blue),
              _summaryRow(
                  'Deposit', summary['deposit']?.toString() ?? '100,000.00'),
              _summaryRow('Swap:', summary['swap']?.toString() ?? '0.00'),
              _summaryRow(
                  'Commission:', summary['commission']?.toString() ?? '0.00'),
              _summaryRow(
                  'Balance:', summary['balance']?.toString() ?? '100,000.00'),
            ],
          ),
        ),
        const Divider(color: Color(0xFF2E3742), height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: const Text(
            'Balance',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        if (history.isNotEmpty)
          ...history
              .map((item) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item['date']?.toString() ?? 'Unknown',
                          style: const TextStyle(
                              color: Color(0xFF7A8597), fontSize: 13),
                        ),
                        Text(
                          item['balance']?.toString() ?? '0.00',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList()
        else
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'No history available',
              style: TextStyle(color: Color(0xFF7A8597), fontSize: 13),
            ),
          ),
      ],
    );
  }

  Widget _ordersTab() {
    if (_ordersData == null) {
      return const Center(
        child: Text(
          'No data available',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    final orders = _ordersData!['orders'] as List<dynamic>? ?? [];

    if (orders.isEmpty) {
      return const Center(
        child: Text(
          'No orders history available',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return ListTile(
          title: Text(
            order['symbol']?.toString() ?? 'Unknown',
            style: const TextStyle(color: Colors.white),
          ),
          subtitle: Text(
            order['date']?.toString() ?? 'Unknown date',
            style: const TextStyle(color: Color(0xFF7A8597)),
          ),
          trailing: Text(
            order['volume']?.toString() ?? '0',
            style: const TextStyle(color: Colors.blue),
          ),
        );
      },
    );
  }

  Widget _dealsTab() {
    if (_dealsData == null) {
      return const Center(
        child: Text(
          'No data available',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    final deals = _dealsData!['deals'] as List<dynamic>? ?? [];

    if (deals.isEmpty) {
      return const Center(
        child: Text(
          'No deals history available',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return ListView.builder(
      itemCount: deals.length,
      itemBuilder: (context, index) {
        final deal = deals[index];
        return ListTile(
          title: Text(
            deal['symbol']?.toString() ?? 'Unknown',
            style: const TextStyle(color: Colors.white),
          ),
          subtitle: Text(
            deal['date']?.toString() ?? 'Unknown date',
            style: const TextStyle(color: Color(0xFF7A8597)),
          ),
          trailing: Text(
            deal['profit']?.toString() ?? '0',
            style: const TextStyle(color: Colors.blue),
          ),
        );
      },
    );
  }

  Widget _summaryRow(
    String label,
    String value, {
    Color valueColor = Colors.white,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 15),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
