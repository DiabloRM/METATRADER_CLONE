import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QuotesScreen extends StatelessWidget {
  const QuotesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Set status bar to light
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    final quotes = [
      {
        'symbol': 'EURUSD',
        'change': '+49',
        'percent': '0.04%',
        'changeColor': Colors.blue,
        'time': '14:41:10',
        'trades': '13',
        'bid': '1.14292',
        'ask': '1.14305',
        'bidSup': '2',
        'askSup': '5',
        'low': '1.14048',
        'high': '1.14453',
        'priceColor': Colors.blue,
      },
      {
        'symbol': 'GBPUSD',
        'change': '-45',
        'percent': '-0.03%',
        'changeColor': Colors.red,
        'time': '14:41:09',
        'trades': '21',
        'bid': '1.34926',
        'ask': '1.34947',
        'bidSup': '6',
        'askSup': '7',
        'low': '1.34633',
        'high': '1.35092',
        'priceColor': Colors.red,
      },
      {
        'symbol': 'USDCHF',
        'change': '-25',
        'percent': '-0.03%',
        'changeColor': Colors.red,
        'time': '14:41:11',
        'trades': '25',
        'bid': '0.82228',
        'ask': '0.82253',
        'bidSup': '8',
        'askSup': '3',
        'low': '0.82113',
        'high': '0.82335',
        'priceColor': Colors.red,
      },
      {
        'symbol': 'USDJPY',
        'change': '+298',
        'percent': '0.21%',
        'changeColor': Colors.blue,
        'time': '14:41:10',
        'trades': '22',
        'bid': '145.186',
        'ask': '145.208',
        'bidSup': '6',
        'askSup': '8',
        'low': '144.646',
        'high': '145.236',
        'priceColor': Colors.red,
      },
      {
        'symbol': 'USDCNH',
        'change': '+81',
        'percent': '0.01%',
        'changeColor': Colors.blue,
        'time': '14:41:11',
        'trades': '218',
        'bid': '7.18863',
        'ask': '7.19081',
        'bidSup': '3',
        'askSup': '1',
        'low': '7.17994',
        'high': '7.18916',
        'priceColor': Colors.blue,
      },
    ];

    return Column(
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
                'Quotes',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.add, color: Colors.white),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: quotes.length,
            separatorBuilder: (_, __) =>
                const Divider(color: Color(0xFF2E3742), height: 1),
            itemBuilder: (context, index) {
              final q = quotes[index];
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left: Symbol and info
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                q['change'] as String,
                                style: TextStyle(
                                  color: q['changeColor'] as Color?,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                q['percent'] as String,
                                style: TextStyle(
                                  color: q['changeColor'] as Color?,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            q['symbol'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                q['time'] as String,
                                style: const TextStyle(
                                  color: Color(0xFF7A8597),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.keyboard_tab,
                                size: 14,
                                color: Color(0xFF7A8597),
                              ),
                              const SizedBox(width: 2),
                              Text(
                                q['trades'] as String,
                                style: const TextStyle(
                                  color: Color(0xFF7A8597),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Right: Prices
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              _priceWithSup(
                                q['bid'] as String,
                                q['bidSup'] as String,
                                q['priceColor'] as Color,
                              ),
                              const SizedBox(width: 8),
                              _priceWithSup(
                                q['ask'] as String,
                                q['askSup'] as String,
                                q['priceColor'] as Color,
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'L: ${q['low']}',
                                style: const TextStyle(
                                  color: Color(0xFF7A8597),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'H: ${q['high']}',
                                style: const TextStyle(
                                  color: Color(0xFF7A8597),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _priceWithSup(String price, String sup, Color color) {
    final main = price.substring(0, price.length - 1);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          main,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        Transform.translate(
          offset: const Offset(0, -6),
          child: Text(
            sup,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
