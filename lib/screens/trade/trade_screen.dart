import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TradeScreen extends StatelessWidget {
  const TradeScreen({Key? key}) : super(key: key);

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
          child: Column(
            children: [
              _summaryRow('Balance:', '100 000.00'),
              _summaryRow('Equity:', '100 000.00'),
              _summaryRow('Free margin:', '100 000.00'),
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
