import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/api_service.dart';
import '../../services/quotes_websocket_service.dart';
import '../../models/trading_models.dart';

class QuotesScreen extends StatefulWidget {
  const QuotesScreen({Key? key}) : super(key: key);

  @override
  State<QuotesScreen> createState() => _QuotesScreenState();
}

class _QuotesScreenState extends State<QuotesScreen> {
  final MetaQuotesApiService _apiService = MetaQuotesApiService();
  late QuotesWebSocketService _wsService;
  List<MarketData> _quotes = [];
  bool _isLoading = true;
  bool _isConnected = false;
  String? _error;
  bool _usingMockData = false;

  // Mock data for fallback
  final List<MarketData> _mockQuotes = [
    MarketData(
      symbol: 'EURUSD',
      bid: 1.0850,
      ask: 1.0852,
      last: 1.0851,
      volume: 1250,
      timestamp: DateTime.now(),
    ),
    MarketData(
      symbol: 'GBPUSD',
      bid: 1.2650,
      ask: 1.2653,
      last: 1.2652,
      volume: 980,
      timestamp: DateTime.now(),
    ),
    MarketData(
      symbol: 'USDJPY',
      bid: 148.50,
      ask: 148.53,
      last: 148.52,
      volume: 2100,
      timestamp: DateTime.now(),
    ),
    MarketData(
      symbol: 'AUDUSD',
      bid: 0.6650,
      ask: 0.6653,
      last: 0.6651,
      volume: 750,
      timestamp: DateTime.now(),
    ),
    MarketData(
      symbol: 'USDCAD',
      bid: 1.3550,
      ask: 1.3553,
      last: 1.3552,
      volume: 890,
      timestamp: DateTime.now(),
    ),
    MarketData(
      symbol: 'NZDUSD',
      bid: 0.6150,
      ask: 0.6153,
      last: 0.6151,
      volume: 420,
      timestamp: DateTime.now(),
    ),
    MarketData(
      symbol: 'USDCHF',
      bid: 0.8750,
      ask: 0.8753,
      last: 0.8751,
      volume: 680,
      timestamp: DateTime.now(),
    ),
    MarketData(
      symbol: 'EURGBP',
      bid: 0.8580,
      ask: 0.8583,
      last: 0.8581,
      volume: 320,
      timestamp: DateTime.now(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeWebSocket();
    _loadQuotes();
  }

  void _initializeWebSocket() {
    _wsService = QuotesWebSocketService(
      onQuotesReceived: (quotes) {
        setState(() {
          _quotes = quotes;
          _isLoading = false;
          _error = null;
          _isConnected = true;
          _usingMockData = false;
        });
      },
      onQuoteUpdate: (quote) {
        setState(() {
          final index = _quotes.indexWhere((q) => q.symbol == quote.symbol);
          if (index != -1) {
            _quotes[index] = quote;
          }
        });
      },
    );

    _wsService.connect().catchError((error) {
      print('WebSocket connection failed: $error');
      // Don't set error here, let the API call handle it
    });
  }

  Future<void> _loadQuotes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // First try to get symbols from the API
      final symbols = await _apiService.getMarketSymbols();

      if (symbols.isNotEmpty) {
        // Try to get real quotes for each symbol
        final quotes = await Future.wait(
          symbols.map((symbol) async {
            try {
              final quote = await _apiService.getSymbolQuote(symbol['symbol']);
              return MarketData(
                symbol: symbol['symbol'],
                bid: quote['bid'].toDouble(),
                ask: quote['ask'].toDouble(),
                last: quote['last'].toDouble(),
                volume: quote['volume'].toInt(),
                timestamp: DateTime.parse(quote['timestamp']),
              );
            } catch (e) {
              // If individual quote fails, return null
              print('Failed to get quote for ${symbol['symbol']}: $e');
              return null;
            }
          }),
        );

        // Filter out null quotes
        final validQuotes =
            quotes.where((quote) => quote != null).cast<MarketData>().toList();

        if (validQuotes.isNotEmpty) {
          setState(() {
            _quotes = validQuotes;
            _isLoading = false;
            _error = null;
            _isConnected = true;
            _usingMockData = false;
          });
          return;
        }
      }
    } catch (e) {
      print('API call failed: $e');
    }

    // If API fails or returns no data, use mock data
    _loadMockData();
  }

  void _loadMockData() {
    setState(() {
      _quotes = _mockQuotes;
      _isLoading = false;
      _error = null;
      _isConnected = false;
      _usingMockData = true;
    });
  }

  void _updateMockData() {
    if (_usingMockData) {
      setState(() {
        _quotes = _quotes.map((quote) {
          // Simulate price changes
          final random = (DateTime.now().millisecondsSinceEpoch % 100) / 1000;
          final change = (random - 0.5) * 0.001; // Small random change

          return MarketData(
            symbol: quote.symbol,
            bid: (quote.bid + change).clamp(0.1, 999.999),
            ask: (quote.ask + change).clamp(0.1, 999.999),
            last: (quote.last + change).clamp(0.1, 999.999),
            volume:
                quote.volume + (DateTime.now().millisecondsSinceEpoch % 100),
            timestamp: DateTime.now(),
          );
        }).toList();
      });
    }
  }

  @override
  void dispose() {
    _wsService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Set status bar to light
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quotes',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                      ),
                    ),
                    if (_usingMockData)
                      const Text(
                        'Demo Mode',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: _loadQuotes,
              ),
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
        if (_isLoading)
          const Expanded(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        else if (_error != null)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: $_error',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadQuotes,
                    child: const Text('Retry'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _loadMockData,
                    child: const Text('Use Demo Data'),
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: Column(
              children: [
                if (_usingMockData)
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    color: Colors.orange.withOpacity(0.1),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline,
                            color: Colors.orange, size: 16),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Showing demo data. Server connection unavailable.',
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: _loadQuotes,
                          child: const Text(
                            'Retry',
                            style:
                                TextStyle(color: Colors.orange, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _quotes.length,
                    separatorBuilder: (_, __) =>
                        const Divider(color: Color(0xFF2E3742), height: 1),
                    itemBuilder: (context, index) {
                      final quote = _quotes[index];
                      final isPositive = quote.last > quote.bid;
                      final changeColor =
                          isPositive ? Colors.green : Colors.red;

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        '${quote.last - quote.bid > 0 ? '+' : ''}${(quote.last - quote.bid).toStringAsFixed(5)}',
                                        style: TextStyle(
                                          color: changeColor,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${((quote.last - quote.bid) / quote.bid * 100).toStringAsFixed(2)}%',
                                        style: TextStyle(
                                          color: changeColor,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    quote.symbol,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        quote.timestamp
                                            .toString()
                                            .substring(11, 19),
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
                                        quote.volume.toString(),
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
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      _priceWithSup(
                                        quote.bid.toStringAsFixed(5),
                                        '2',
                                        changeColor,
                                      ),
                                      const SizedBox(width: 8),
                                      _priceWithSup(
                                        quote.ask.toStringAsFixed(5),
                                        '5',
                                        changeColor,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        'L: ${quote.last.toStringAsFixed(5)}',
                                        style: const TextStyle(
                                          color: Color(0xFF7A8597),
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'H: ${quote.last.toStringAsFixed(5)}',
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
