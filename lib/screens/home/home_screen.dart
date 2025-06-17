import 'package:flutter/material.dart';
import '../chart/chart_screen.dart';
import '../quotes/quotes_screen.dart';
import '../trade/trade_screen.dart';
import '../history/history_screen.dart';
import '../message/message_screen.dart';
import '../home/side_drawer.dart';

class HomeScreen extends StatefulWidget {
  final int? initialIndex;
  const HomeScreen({Key? key, this.initialIndex}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex ?? 0;
  }

  final _screens = [
    const QuotesScreen(),
    const ChartScreen(),
    const TradeScreen(),
    const HistoryScreen(),
    const MessageScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0F11),
      drawer: SideDrawer(
        onItemSelected: (index) {
          setState(() => _currentIndex = index);
        },
      ), // 👈 Drawer here
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: const Color(0xFF1E1F23),
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.white60,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.import_export),
            label: "Quotes",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.candlestick_chart),
            label: "Charts",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: "Trade"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: "Messages"),
        ],
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
      ),
    );
  }
}
