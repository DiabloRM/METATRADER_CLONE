import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/trading_provider.dart';
import '../models/trading_models.dart';
import '../widgets/account_overview.dart';
import '../widgets/positions_list.dart';
import '../widgets/orders_list.dart';
import '../widgets/trading_form.dart';

class TradingScreen extends StatefulWidget {
  const TradingScreen({Key? key}) : super(key: key);

  @override
  State<TradingScreen> createState() => _TradingScreenState();
}

class _TradingScreenState extends State<TradingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['Account', 'Positions', 'Orders', 'Trade'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    // Initialize trading data when the screen is first loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TradingProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trading'),
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
          isScrollable: true,
        ),
      ),
      body: Consumer<TradingProvider>(
        builder: (context, tradingProvider, child) {
          if (tradingProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (tradingProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${tradingProvider.error}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      tradingProvider.clearError();
                      tradingProvider.initialize();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              // Account Overview Tab
              AccountOverview(accountInfo: tradingProvider.accountInfo),

              // Positions Tab
              PositionsList(
                positions: tradingProvider.openPositions,
                onClosePosition: (positionId) async {
                  try {
                    await tradingProvider.closePosition(positionId);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Position closed successfully')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to close position: $e')),
                    );
                  }
                },
                onModifyPosition: (positionId, request) async {
                  try {
                    await tradingProvider.modifyPosition(positionId, request);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Position modified successfully')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to modify position: $e')),
                    );
                  }
                },
              ),

              // Orders Tab
              OrdersList(
                openOrders: tradingProvider.openOrders,
                orderHistory: tradingProvider.orderHistory,
                onCancelOrder: (orderId) async {
                  try {
                    await tradingProvider.cancelOrder(orderId);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Order cancelled successfully')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to cancel order: $e')),
                    );
                  }
                },
                onModifyOrder: (orderId, request) async {
                  try {
                    await tradingProvider.modifyOrder(orderId, request);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Order modified successfully')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to modify order: $e')),
                    );
                  }
                },
              ),

              // Trading Form Tab
              TradingForm(
                onCreateOrder: (request) async {
                  try {
                    await tradingProvider.createOrder(request);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Order created successfully')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to create order: $e')),
                    );
                  }
                },
                symbolPrices: tradingProvider.symbolPrices,
                onGetSymbolPrice: (symbol) async {
                  try {
                    await tradingProvider.getSymbolPrice(symbol);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to get symbol price: $e')),
                    );
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
