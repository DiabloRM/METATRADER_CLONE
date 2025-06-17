import 'package:flutter/material.dart';
import '../models/trading_models.dart';

class PositionsList extends StatelessWidget {
  final List<Position> positions;
  final Function(String) onClosePosition;
  final Function(String, ModifyOrderRequest) onModifyPosition;

  const PositionsList({
    Key? key,
    required this.positions,
    required this.onClosePosition,
    required this.onModifyPosition,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (positions.isEmpty) {
      return const Center(
        child: Text('No open positions'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: positions.length,
      itemBuilder: (context, index) {
        final position = positions[index];
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
                      position.symbol,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _buildPositionTypeChip(position.side),
                  ],
                ),
                const Divider(),
                _buildInfoRow('Position ID', position.positionId),
                _buildInfoRow('Volume', position.volume.toString()),
                _buildInfoRow(
                    'Open Price', position.openPrice.toStringAsFixed(5)),
                _buildInfoRow(
                    'Current Price', position.currentPrice.toStringAsFixed(5)),
                _buildInfoRow('Stop Loss',
                    position.stopLoss?.toStringAsFixed(5) ?? 'None'),
                _buildInfoRow('Take Profit',
                    position.takeProfit?.toStringAsFixed(5) ?? 'None'),
                _buildInfoRow(
                    'Profit', '\$${position.profit.toStringAsFixed(2)}'),
                _buildInfoRow('Swap', '\$${position.swap.toStringAsFixed(2)}'),
                _buildInfoRow('Opened At', _formatDateTime(position.openedAt)),
                if (position.comment != null)
                  _buildInfoRow('Comment', position.comment!),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () =>
                          _showModifyPositionDialog(context, position),
                      child: const Text('Modify'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () =>
                          _showClosePositionDialog(context, position),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPositionTypeChip(OrderSide side) {
    return Chip(
      label: Text(
        side == OrderSide.buy ? 'BUY' : 'SELL',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: side == OrderSide.buy ? Colors.green : Colors.red,
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

  void _showClosePositionDialog(BuildContext context, Position position) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Close Position'),
        content: Text(
            'Are you sure you want to close this ${position.symbol} position?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onClosePosition(position.positionId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showModifyPositionDialog(BuildContext context, Position position) {
    final stopLossController = TextEditingController(
      text: position.stopLoss?.toString() ?? '',
    );
    final takeProfitController = TextEditingController(
      text: position.takeProfit?.toString() ?? '',
    );
    final commentController = TextEditingController(
      text: position.comment ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modify Position'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                  hintText: 'Enter position comment',
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
                stopLoss: double.tryParse(stopLossController.text),
                takeProfit: double.tryParse(takeProfitController.text),
                comment: commentController.text.isEmpty
                    ? null
                    : commentController.text,
              );
              Navigator.pop(context);
              onModifyPosition(position.positionId, request);
            },
            child: const Text('Modify'),
          ),
        ],
      ),
    );
  }
}
