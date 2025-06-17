import 'package:flutter/material.dart';
import '../models/trading_models.dart';

class AccountOverview extends StatelessWidget {
  final AccountInfo? accountInfo;

  const AccountOverview({
    Key? key,
    required this.accountInfo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (accountInfo == null) {
      return const Center(
        child: Text('No account information available'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            title: 'Account Summary',
            children: [
              _buildInfoRow('Account ID', accountInfo!.accountId),
              _buildInfoRow(
                  'Balance', '\$${accountInfo!.balance.toStringAsFixed(2)}'),
              _buildInfoRow(
                  'Equity', '\$${accountInfo!.equity.toStringAsFixed(2)}'),
              _buildInfoRow(
                  'Margin', '\$${accountInfo!.margin.toStringAsFixed(2)}'),
              _buildInfoRow('Free Margin',
                  '\$${accountInfo!.freeMargin.toStringAsFixed(2)}'),
              _buildInfoRow('Margin Level',
                  '${accountInfo!.marginLevel.toStringAsFixed(2)}%'),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            title: 'Account Details',
            children: [
              _buildInfoRow('Currency', accountInfo!.currency),
              _buildInfoRow(
                  'Leverage', '1:${accountInfo!.leverage.toStringAsFixed(0)}'),
              _buildInfoRow(
                  'Last Updated', _formatDateTime(accountInfo!.updatedAt)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
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
}
