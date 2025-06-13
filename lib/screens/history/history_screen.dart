import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

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
                  onPressed: () {},
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
            child: const TabBar(
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
          Expanded(
            child: TabBarView(
              children: [
                // POSITIONS TAB
                _positionsTab(),
                // ORDERS TAB (empty)
                Container(color: Color(0xFF232A34)),
                // DEALS TAB (empty)
                Container(color: Color(0xFF232A34)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _positionsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: const Color(0xFF232A34),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              _summaryRow('Profit:', '0.00', valueColor: Colors.blue),
              _summaryRow('Deposit', '100 000.00'),
              _summaryRow('Swap:', '0.00'),
              _summaryRow('Commission:', '0.00'),
              _summaryRow('Balance:', '100 000.00'),
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '2025.06.11 13:06:41',
                style: const TextStyle(color: Color(0xFF7A8597), fontSize: 13),
              ),
              Text(
                '100 000.00',
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ],
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
