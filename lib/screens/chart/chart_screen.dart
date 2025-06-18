import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../models/trading_models.dart';
import 'package:provider/provider.dart';
import 'package:metatrader_clone/providers/trading_provider.dart';
import 'package:metatrader_clone/providers/mt5_provider.dart';
import 'package:metatrader_clone/services/quotes_websocket_service.dart';

// --- UI Color and Style Constants ---
const Color kBackgroundColor = Color(0xFF131722);
const Color kAppBarColor = Color(0xFF131722);
const Color kBullishColor = Color(0xFF26a69a); // Teal for bullish
const Color kBearishColor = Color(0xFFef5350); // Red for bearish
const Color kBuyButtonColor = Color(0xFF0277BD);
const Color kGridLineColor = Color(0x33888888);
const Color kAxisLabelColor = Color(0xff888888);
const Color kCurrentPriceColor = Colors.cyanAccent;
const Color kLoadingColor = Color(0xFF4CAF50);
const Color kErrorColor = Color(0xFFF44336);

// Timeframe options
enum Timeframe { M1, M5, M15, M30, H1, H4, D1, W1, MN1 }

// --- ChartScreen Widget ---
class ChartScreen extends StatefulWidget {
  const ChartScreen({super.key});

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  final MetaQuotesApiService _apiService = MetaQuotesApiService();

  // State variables
  double _volume = 0.01;
  late List<CandleData> _candleData;
  bool _isLoading = true;
  bool _usingMockData = false;
  String? _error;
  String _selectedSymbol = 'EURUSD';
  Timeframe _selectedTimeframe = Timeframe.D1;
  MarketData? _currentQuote;

  // Syncfusion chart tooltip behavior
  late TooltipBehavior _tooltipBehavior;

  // Available symbols
  final List<String> _availableSymbols = [
    'EURUSD',
    'GBPUSD',
    'USDJPY',
    'AUDUSD',
    'USDCAD',
    'NZDUSD',
    'USDCHF',
    'EURGBP'
  ];

  @override
  void initState() {
    super.initState();
    _tooltipBehavior = TooltipBehavior(enable: true);
    _initializeChart();
    _loadChartData();
  }

  void _initializeChart() {
    _candleData = _generateMockCandlestickData();
  }

  Future<void> _loadChartData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Try to get real chart data from API
      final chartResponse = await _apiService.getChartData(
        symbol: _selectedSymbol,
        timeframe: _getTimeframeString(_selectedTimeframe),
        count: 100,
      );

      if (chartResponse['success'] && chartResponse['data'] != null) {
        // Convert API data to candle data
        final candleData = _convertApiDataToCandles(chartResponse['data']);

        setState(() {
          _candleData = candleData;
          _isLoading = false;
          _usingMockData = chartResponse['source'] == 'mock';
          _currentQuote = _generateQuoteFromChartData(chartResponse['data']);
        });
      } else {
        _loadMockData();
      }
    } catch (e) {
      print('Failed to load chart data: $e');
      _loadMockData();
    }
  }

  List<CandleData> _convertApiDataToCandles(List<dynamic> apiData) {
    return apiData.map<CandleData>((item) {
      return CandleData(
        date: DateTime.fromMillisecondsSinceEpoch(item['timestamp'] * 1000),
        open: (item['open'] as num).toDouble(),
        high: (item['high'] as num).toDouble(),
        low: (item['low'] as num).toDouble(),
        close: (item['close'] as num).toDouble(),
        volume: (item['volume'] as num).toDouble(),
      );
    }).toList();
  }

  MarketData _generateQuoteFromChartData(List<dynamic> chartData) {
    if (chartData.isEmpty) {
      return _generateMockQuote();
    }

    final latestCandle = chartData.last;
    return MarketData(
      symbol: _selectedSymbol,
      bid: (latestCandle['close'] as num).toDouble() - 0.0001,
      ask: (latestCandle['close'] as num).toDouble() + 0.0001,
      last: (latestCandle['close'] as num).toDouble(),
      volume: (latestCandle['volume'] as num).toDouble(),
      timestamp:
          DateTime.fromMillisecondsSinceEpoch(latestCandle['timestamp'] * 1000),
    );
  }

  void _loadMockData() {
    setState(() {
      _candleData = _generateMockCandlestickData();
      _isLoading = false;
      _usingMockData = true;
      _currentQuote = _generateMockQuote();
    });
  }

  List<CandleData> _generateMockCandlestickData() {
    final random = Random();
    final data = <CandleData>[];
    final baseDate = DateTime.now().subtract(const Duration(days: 100));
    double lastClose = 1.14000;

    for (int i = 0; i < 100; i++) {
      final date = baseDate.add(Duration(days: i));
      final open = lastClose;
      final change = (random.nextDouble() - 0.48) * 0.015;
      final close = open + change;
      final high = max(open, close) + random.nextDouble() * 0.005;
      final low = min(open, close) - random.nextDouble() * 0.005;
      final volume = random.nextDouble() * 10000 + 1000;

      data.add(CandleData(
        date: date,
        open: open,
        high: high,
        low: low,
        close: close,
        volume: volume,
      ));
      lastClose = close;
    }
    return data;
  }

  MarketData _generateMockQuote() {
    return MarketData(
      symbol: _selectedSymbol,
      bid: 1.1428,
      ask: 1.1429,
      last: 1.14284,
      volume: 1250,
      timestamp: DateTime.now(),
    );
  }

  void _onSymbolChanged(String symbol) {
    setState(() {
      _selectedSymbol = symbol;
    });
    _loadChartData();
  }

  void _onTimeframeChanged(Timeframe timeframe) {
    setState(() {
      _selectedTimeframe = timeframe;
    });
    _loadChartData();
  }

  String _getTimeframeString(Timeframe timeframe) {
    switch (timeframe) {
      case Timeframe.M1:
        return 'M1';
      case Timeframe.M5:
        return 'M5';
      case Timeframe.M15:
        return 'M15';
      case Timeframe.M30:
        return 'M30';
      case Timeframe.H1:
        return 'H1';
      case Timeframe.H4:
        return 'H4';
      case Timeframe.D1:
        return 'D1';
      case Timeframe.W1:
        return 'W1';
      case Timeframe.MN1:
        return 'MN1';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Set status bar to light
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    return Column(
      children: [
        _buildAppBar(),
        if (_usingMockData) _buildDemoModeBanner(),
        _buildTopTradeBar(),
        _buildSymbolInfo(),
        Expanded(
          child: _buildChart(),
        ),
      ],
    );
  }

  Widget _buildAppBar() {
    return Container(
      color: kAppBarColor,
      padding: const EdgeInsets.only(top: 36, bottom: 8),
      child: Row(
        children: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.show_chart, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                _buildTimeframeSelector(),
                const SizedBox(width: 8),
                _buildSymbolSelector(),
                const SizedBox(width: 8),
                const Icon(Icons.draw_outlined, color: Colors.white, size: 20),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              _isLoading ? Icons.refresh : Icons.refresh,
              color: _isLoading ? kLoadingColor : Colors.white,
            ),
            onPressed: _isLoading ? null : _loadChartData,
          ),
        ],
      ),
    );
  }

  Widget _buildDemoModeBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.orange.withOpacity(0.1),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.orange, size: 16),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Showing demo chart data. Server connection unavailable.',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 12,
              ),
            ),
          ),
          TextButton(
            onPressed: _loadChartData,
            child: const Text(
              'Retry',
              style: TextStyle(color: Colors.orange, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeframeSelector() {
    return PopupMenuButton<Timeframe>(
      initialValue: _selectedTimeframe,
      onSelected: _onTimeframeChanged,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _getTimeframeString(_selectedTimeframe),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, color: Colors.white, size: 16),
          ],
        ),
      ),
      itemBuilder: (context) => Timeframe.values.map((timeframe) {
        return PopupMenuItem<Timeframe>(
          value: timeframe,
          child: Text(_getTimeframeString(timeframe)),
        );
      }).toList(),
    );
  }

  Widget _buildSymbolSelector() {
    return PopupMenuButton<String>(
      initialValue: _selectedSymbol,
      onSelected: _onSymbolChanged,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _selectedSymbol,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, color: Colors.white, size: 16),
          ],
        ),
      ),
      itemBuilder: (context) => _availableSymbols.map((symbol) {
        return PopupMenuItem<String>(
          value: symbol,
          child: Text(symbol),
        );
      }).toList(),
    );
  }

  Widget _buildChart() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: kLoadingColor),
            SizedBox(height: 16),
            Text(
              'Loading chart data...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: kErrorColor, size: 48),
            const SizedBox(height: 16),
            Text(
              'Error: $_error',
              style: const TextStyle(color: kErrorColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadChartData,
              child: const Text('Retry'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _loadMockData,
              child: const Text('Use Demo Data'),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Column(
        children: [
          // Main candlestick chart (70% of height)
          Expanded(
            flex: 7,
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
              series: <CartesianSeries>[
                // Candlestick series
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
                // Moving Average (SMA 20)
                LineSeries<CandleData, DateTime>(
                  dataSource: _candleData,
                  xValueMapper: (CandleData data, _) => data.date,
                  yValueMapper: (CandleData data, _) => _calculateSMA(20),
                  color: Colors.yellow,
                  width: 1,
                  name: 'SMA 20',
                ),
              ],
              trackballBehavior: TrackballBehavior(
                enable: true,
                activationMode: ActivationMode.singleTap,
                tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
              ),
              tooltipBehavior: _tooltipBehavior,
              legend: Legend(
                isVisible: true,
                position: LegendPosition.top,
                textStyle: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
          // Volume chart (30% of height)
          Expanded(
            flex: 3,
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
                  fontSize: 8,
                ),
              ),
              primaryYAxis: NumericAxis(
                majorGridLines: const MajorGridLines(
                  width: 0.2,
                  color: kGridLineColor,
                ),
                axisLine: const AxisLine(width: 0.5, color: kAxisLabelColor),
                labelStyle: const TextStyle(
                  color: kAxisLabelColor,
                  fontSize: 8,
                ),
              ),
              series: <CartesianSeries>[
                // Volume bars
                ColumnSeries<CandleData, DateTime>(
                  dataSource: _candleData,
                  xValueMapper: (CandleData data, _) => data.date,
                  yValueMapper: (CandleData data, _) => data.volume,
                  color: Colors.grey.withOpacity(0.7),
                  width: 0.8,
                  name: 'Volume',
                ),
              ],
              tooltipBehavior: TooltipBehavior(
                enable: true,
                format: 'point.x : Volume: point.y',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to calculate Simple Moving Average
  double _calculateSMA(int period) {
    if (_candleData.length < period) return 0;

    double sum = 0;
    for (int i = _candleData.length - period; i < _candleData.length; i++) {
      sum += _candleData[i].close;
    }
    return sum / period;
  }

  /// Builds the SELL/BUY buttons and volume control bar.
  Widget _buildTopTradeBar() {
    final currentPrice = _currentQuote?.last ?? 1.14284;
    final bid = _currentQuote?.bid ?? currentPrice - 0.0001;
    final ask = _currentQuote?.ask ?? currentPrice + 0.0001;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: _buildTradeButton(
                'SELL', bid.toStringAsFixed(5), '4', kBearishColor),
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
            child: _buildTradeButton(
                'BUY', ask.toStringAsFixed(5), '7', kBuyButtonColor),
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
    final currentPrice = _currentQuote?.last ?? 1.14284;
    final timestamp = _currentQuote?.timestamp ?? DateTime.now();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Text(
            _selectedSymbol,
            style: const TextStyle(
              color: kCurrentPriceColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 4),
          Text(_getTimeframeString(_selectedTimeframe),
              style: const TextStyle(color: Colors.white, fontSize: 16)),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                currentPrice.toStringAsFixed(5),
                style: GoogleFonts.robotoMono(
                  color: kCurrentPriceColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                DateFormat('HH:mm:ss').format(timestamp),
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
}

class CandleData {
  final DateTime date;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;

  CandleData({
    required this.date,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });
}
