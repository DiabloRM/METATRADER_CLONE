class Position {
  final int ticket;
  final String symbol;
  final String type;
  final double volume;
  final double openPrice;
  final double currentPrice;
  final double profit;
  final DateTime openTime;

  Position({
    required this.ticket,
    required this.symbol,
    required this.type,
    required this.volume,
    required this.openPrice,
    required this.currentPrice,
    required this.profit,
    required this.openTime,
  });

  factory Position.fromJson(Map<String, dynamic> json) {
    return Position(
      ticket: json['ticket'] as int,
      symbol: json['symbol'] as String,
      type: json['type'] as String,
      volume: (json['volume'] as num).toDouble(),
      openPrice: (json['openPrice'] as num).toDouble(),
      currentPrice: (json['currentPrice'] as num).toDouble(),
      profit: (json['profit'] as num).toDouble(),
      openTime: DateTime.parse(json['openTime'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ticket': ticket,
      'symbol': symbol,
      'type': type,
      'volume': volume,
      'openPrice': openPrice,
      'currentPrice': currentPrice,
      'profit': profit,
      'openTime': openTime.toIso8601String(),
    };
  }
}
