import 'package:flutter/material.dart';
import '../models/trading_models.dart';

class OrdersList extends StatefulWidget {
  final List<Order> openOrders;
  final List<Order> orderHistory;
  final Function(String) onCancelOrder;
  final Function(String, ModifyOrderRequest) onModifyOrder;

  const OrdersList({
    Key? key,
    required this.openOrders,
    required this.orderHistory,
    required this.onCancelOrder,
    required this.onModifyOrder,
  }) : super(key: key);

  @override
  State<OrdersList> createState() => _OrdersListState();
}

class _OrdersListState extends State<OrdersList>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Open Orders'),
            Tab(text: 'Order History'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildOrdersList(widget.openOrders, true),
              _buildOrdersList(widget.orderHistory, false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrdersList(List<Order> orders, bool isOpenOrders) {
    if (orders.isEmpty) {
      return Center(
        child: Text(
          isOpenOrders ? 'No open orders' : 'No order history',
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      order.symbol,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _buildOrderTypeChip(order),
                  ],
                ),
                const Divider(),
                _buildInfoRow('Order ID', order.orderId),
                _buildInfoRow('Type', order.type.toString().split('.').last),
                _buildInfoRow('Side', order.side.toString().split('.').last),
                _buildInfoRow('Volume', order.volume.toString()),
                _buildInfoRow('Price', order.price.toStringAsFixed(5)),
                _buildInfoRow(
                    'Stop Loss', order.stopLoss?.toStringAsFixed(5) ?? 'None'),
                _buildInfoRow('Take Profit',
                    order.takeProfit?.toStringAsFixed(5) ?? 'None'),
                _buildInfoRow(
                    'Status', order.status.toString().split('.').last),
                _buildInfoRow('Created At', _formatDateTime(order.createdAt)),
                if (order.filledAt != null)
                  _buildInfoRow('Filled At', _formatDateTime(order.filledAt!)),
                if (order.comment != null)
                  _buildInfoRow('Comment', order.comment!),
                if (isOpenOrders && order.status == OrderStatus.pending)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () =>
                              _showModifyOrderDialog(context, order),
                          child: const Text('Modify'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () =>
                              _showCancelOrderDialog(context, order),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text('Cancel'),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrderTypeChip(Order order) {
    Color backgroundColor;
    String label;

    switch (order.type) {
      case OrderType.market:
        backgroundColor = Colors.blue;
        label = 'MARKET';
        break;
      case OrderType.limit:
        backgroundColor = Colors.orange;
        label = 'LIMIT';
        break;
      case OrderType.stop:
        backgroundColor = Colors.purple;
        label = 'STOP';
        break;
      case OrderType.stopLimit:
        backgroundColor = Colors.teal;
        label = 'STOP LIMIT';
        break;
    }

    return Row(
      children: [
        Chip(
          label: Text(
            order.side == OrderSide.buy ? 'BUY' : 'SELL',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor:
              order.side == OrderSide.buy ? Colors.green : Colors.red,
        ),
        const SizedBox(width: 8),
        Chip(
          label: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: backgroundColor,
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }

  void _showCancelOrderDialog(BuildContext context, Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order'),
        content:
            Text('Are you sure you want to cancel this ${order.symbol} order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onCancelOrder(order.orderId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  void _showModifyOrderDialog(BuildContext context, Order order) {
    final priceController = TextEditingController(
      text: order.price.toString(),
    );
    final stopLossController = TextEditingController(
      text: order.stopLoss?.toString() ?? '',
    );
    final takeProfitController = TextEditingController(
      text: order.takeProfit?.toString() ?? '',
    );
    final commentController = TextEditingController(
      text: order.comment ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modify Order'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (order.type != OrderType.market)
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(
                    labelText: 'Price',
                    hintText: 'Enter order price',
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
              if (order.type != OrderType.market) const SizedBox(height: 16),
              TextField(
                controller: stopLossController,
                decoration: const InputDecoration(
                  labelText: 'Stop Loss',
                  hintText: 'Enter stop loss price',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: takeProfitController,
                decoration: const InputDecoration(
                  labelText: 'Take Profit',
                  hintText: 'Enter take profit price',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: commentController,
                decoration: const InputDecoration(
                  labelText: 'Comment',
                  hintText: 'Enter order comment',
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final request = ModifyOrderRequest(
                price: order.type != OrderType.market
                    ? double.tryParse(priceController.text)
                    : null,
                stopLoss: double.tryParse(stopLossController.text),
                takeProfit: double.tryParse(takeProfitController.text),
                comment: commentController.text.isEmpty
                    ? null
                    : commentController.text,
              );
              Navigator.pop(context);
              widget.onModifyOrder(order.orderId, request);
            },
            child: const Text('Modify'),
          ),
        ],
      ),
    );
  }
}
