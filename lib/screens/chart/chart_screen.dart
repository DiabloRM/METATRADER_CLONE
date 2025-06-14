import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

// --- UI Color and Style Constants ---
const Color kBackgroundColor = Color(0xFF131722);
const Color kAppBarColor = Color(0xFF131722);
const Color kBullishColor = Color(0xFF26a69a); // Teal for bullish
const Color kBearishColor = Color(0xFFef5350); // Red for bearish
const Color kBuyButtonColor = Color(0xFF0277BD);
const Color kGridLineColor = Color(0x33888888);
const Color kAxisLabelColor = Color(0xff888888);
const Color kCurrentPriceColor = Colors.cyanAccent;

// --- ChartScreen Widget ---
class ChartScreen extends StatefulWidget {
  const ChartScreen({super.key});

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  double _volume = 0.01;
  late List<CandleData> _candleData;
  late TooltipBehavior _tooltipBehavior;

  @override
  void initState() {
    super.initState();
    _candleData = _generateCandlestickData();
    _tooltipBehavior = TooltipBehavior(
      enable: true,
      color: Colors.black87,
      format:
          'point.x :\nOpen: point.open\nHigh: point.high\nLow: point.low\nClose: point.close',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: _buildCustomAppBar(),
      body: Column(
        children: [
          _buildTopTradeBar(),
          _buildSymbolInfo(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 8.0,
              ),
              child: SfCartesianChart(
                backgroundColor: kBackgroundColor,
                plotAreaBorderWidth: 0,
                primaryXAxis: DateTimeAxis(
                  majorGridLines: const MajorGridLines(
                    width: 0.2,
                    color: kGridLineColor,
                  ),
                  axisLine: const AxisLine(width: 0.5, color: kAxisLabelColor),
                  dateFormat: DateFormat.MMMd(),
                  labelStyle: const TextStyle(
                    color: kAxisLabelColor,
                    fontSize: 10,
                  ),
                ),
                primaryYAxis: NumericAxis(
                  opposedPosition: true,
                  majorGridLines: const MajorGridLines(
                    width: 0.2,
                    color: kGridLineColor,
                  ),
                  axisLine: const AxisLine(width: 0.5, color: kAxisLabelColor),
                  labelStyle: const TextStyle(
                    color: kAxisLabelColor,
                    fontSize: 10,
                  ),
                ),
                series: <CandleSeries<CandleData, DateTime>>[
                  CandleSeries<CandleData, DateTime>(
                    dataSource: _candleData,
                    xValueMapper: (CandleData data, _) => data.date,
                    lowValueMapper: (CandleData data, _) => data.low,
                    highValueMapper: (CandleData data, _) => data.high,
                    openValueMapper: (CandleData data, _) => data.open,
                    closeValueMapper: (CandleData data, _) => data.close,
                    bearColor: kBearishColor,
                    bullColor: kBullishColor,
                  ),
                ],
                trackballBehavior: TrackballBehavior(
                  enable: true,
                  activationMode: ActivationMode.singleTap,
                ),
                tooltipBehavior: _tooltipBehavior,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the top app bar with timeframe selection.
  AppBar _buildCustomAppBar() {
    return AppBar(
      backgroundColor: kAppBarColor,
      elevation: 0,
      centerTitle: true,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.show_chart, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
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
          const Icon(Icons.draw_outlined, color: Colors.white, size: 20),
        ],
      ),
    );
  }

  /// Builds the SELL/BUY buttons and volume control bar.
  Widget _buildTopTradeBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: _buildTradeButton('SELL', '1.1428', '4', kBearishColor),
          ),
          Expanded(
            flex: 4,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, color: Colors.white, size: 20),
                  onPressed: () => setState(
                    () => _volume = (_volume - 0.01).clamp(0.01, 100.0),
                  ),
                ),
                Text(
                  _volume.toStringAsFixed(2),
                  style: GoogleFonts.robotoMono(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.white, size: 20),
                  onPressed: () => setState(
                    () => _volume = (_volume + 0.01).clamp(0.01, 100.0),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: _buildTradeButton('BUY', '1.1429', '7', kBuyButtonColor),
          ),
        ],
      ),
    );
  }

  /// A helper to create the styled SELL and BUY buttons.
  Widget _buildTradeButton(
    String label,
    String price,
    String sup,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
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
              Text(
                sup,
                style: GoogleFonts.robotoMono(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds the section displaying symbol info and the current price.
  Widget _buildSymbolInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          const Text(
            "EURUSD",
            style: TextStyle(
              color: kCurrentPriceColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 4),
          const Text("D1", style: TextStyle(color: Colors.white, fontSize: 16)),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "1.14284",
                style: GoogleFonts.robotoMono(
                  color: kCurrentPriceColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                "09:18:35",
                style: GoogleFonts.robotoMono(
                  color: kCurrentPriceColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<CandleData> _generateCandlestickData() {
    final random = Random();
    final data = <CandleData>[];
    final baseDate = DateTime(2025, 4, 15);
    double lastClose = 1.14000;

    for (int i = 0; i < 100; i++) {
      final date = baseDate.add(Duration(days: i));
      final open = lastClose;
      final change = (random.nextDouble() - 0.48) * 0.015;
      final close = open + change;
      final high = max(open, close) + random.nextDouble() * 0.005;
      final low = min(open, close) - random.nextDouble() * 0.005;
      data.add(
        CandleData(date: date, open: open, high: high, low: low, close: close),
      );
      lastClose = close;
    }
    return data;
  }
}

class CandleData {
  final DateTime date;
  final double open;
  final double high;
  final double low;
  final double close;

  CandleData({
    required this.date,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
  });
}
