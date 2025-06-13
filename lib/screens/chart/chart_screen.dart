import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

class ChartScreen extends StatefulWidget {
  const ChartScreen({super.key});

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  String timeframe = 'D1';
  double volume = 0.01;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0F11),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: _buildCustomAppBar(context),
      ),
      body: Column(
        children: [
          _buildTopTradeBar(),
          _buildSymbolInfo(),
          Expanded(child: _buildChart()),
        ],
      ),
    );
  }

  Widget _buildCustomAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF232A34),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: Colors.white),
        onPressed: () => Scaffold.of(context).openDrawer(),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.show_chart, color: Colors.white),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'D1',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.access_time, color: Colors.white),
            onPressed: () {},
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.crop_square, color: Colors.blue),
            onPressed: () {},
          ),
        ],
      ),
      actions: const [],
    );
  }

  Widget _buildTopTradeBar() {
    return Container(
      color: const Color(0xFF232A34),
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: _priceBoxWithSup(
              'SELL',
              '1.1428',
              '4',
              Colors.red,
              alignLeft: true,
            ),
          ),
          Expanded(
            flex: 4,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.white,
                  ),
                  onPressed: () => setState(
                    () => volume = (volume - 0.01).clamp(0.01, 100.0),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF232A34),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    volume.toStringAsFixed(2),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.keyboard_arrow_up,
                    color: Colors.white,
                  ),
                  onPressed: () => setState(
                    () => volume = (volume + 0.01).clamp(0.01, 100.0),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: _priceBoxWithSup(
              'BUY',
              '1.1429',
              '7',
              Colors.red,
              alignLeft: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceBoxWithSup(
    String label,
    String price,
    String sup,
    Color color, {
    bool alignLeft = true,
  }) {
    return Container(
      alignment: alignLeft ? Alignment.centerLeft : Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Column(
        crossAxisAlignment: alignLeft
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          Text(
            label,
            style: GoogleFonts.robotoMono(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                price,
                style: GoogleFonts.robotoMono(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -6),
                child: Text(
                  sup,
                  style: GoogleFonts.robotoMono(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSymbolInfo() {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "EURUSD • D1",
            style: TextStyle(
              color: Colors.blueAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text("Euro vs US Dollar", style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildChart() {
    // Placeholder: line chart. Replace with candlestick chart for full accuracy.
    final now = DateTime.now();
    final spots = List.generate(20, (i) {
      return FlSpot(
        now.subtract(Duration(days: 20 - i)).millisecondsSinceEpoch.toDouble(),
        1.12 + i * 0.001,
      );
    });

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: LineChart(
        LineChartData(
          backgroundColor: const Color(0xFF0E0F11),
          gridData: FlGridData(
            show: true,
            drawHorizontalLine: true,
            getDrawingHorizontalLine: (_) => FlLine(color: Colors.white10),
          ),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              isCurved: false,
              spots: spots,
              color: Colors.cyanAccent,
              barWidth: 2,
              dotData: FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}
