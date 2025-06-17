enum OrderType {
  market,
  limit,
  stop,
  stopLimit;

  String toJson() => name;
  static OrderType fromJson(String json) => OrderType.values.firstWhere(
        (e) => e.name == json,
        orElse: () => OrderType.market,
      );
}

enum OrderSide {
  buy,
  sell;

  String toJson() => name;
  static OrderSide fromJson(String json) => OrderSide.values.firstWhere(
        (e) => e.name == json,
        orElse: () => OrderSide.buy,
      );
}

enum OrderStatus {
  pending,
  filled,
  cancelled,
  rejected,
  expired;

  String toJson() => name;
  static OrderStatus fromJson(String json) => OrderStatus.values.firstWhere(
        (e) => e.name == json,
        orElse: () => OrderStatus.pending,
      );
}

class Order {
  final String orderId;
  final String symbol;
  final OrderType type;
  final OrderSide side;
  final double volume;
  final double price;
  final double? stopLoss;
  final double? takeProfit;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? filledAt;
  final String? comment;

  Order({
    required this.orderId,
    required this.symbol,
    required this.type,
    required this.side,
    required this.volume,
    required this.price,
    this.stopLoss,
    this.takeProfit,
    required this.status,
    required this.createdAt,
    this.filledAt,
    this.comment,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        orderId: json['orderId'] as String,
        symbol: json['symbol'] as String,
        type: OrderType.fromJson(json['type'] as String),
        side: OrderSide.fromJson(json['side'] as String),
        volume: (json['volume'] as num).toDouble(),
        price: (json['price'] as num).toDouble(),
        stopLoss: json['stopLoss'] != null
            ? (json['stopLoss'] as num).toDouble()
            : null,
        takeProfit: json['takeProfit'] != null
            ? (json['takeProfit'] as num).toDouble()
            : null,
        status: OrderStatus.fromJson(json['status'] as String),
        createdAt: DateTime.parse(json['createdAt'] as String),
        filledAt: json['filledAt'] != null
            ? DateTime.parse(json['filledAt'] as String)
            : null,
        comment: json['comment'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'orderId': orderId,
        'symbol': symbol,
        'type': type.toJson(),
        'side': side.toJson(),
        'volume': volume,
        'price': price,
        'stopLoss': stopLoss,
        'takeProfit': takeProfit,
        'status': status.toJson(),
        'createdAt': createdAt.toIso8601String(),
        'filledAt': filledAt?.toIso8601String(),
        'comment': comment,
      };
}

class Position {
  final String positionId;
  final String symbol;
  final OrderSide side;
  final double volume;
  final double openPrice;
  final double currentPrice;
  final double? stopLoss;
  final double? takeProfit;
  final double profit;
  final double swap;
  final DateTime openedAt;
  final String? comment;

  Position({
    required this.positionId,
    required this.symbol,
    required this.side,
    required this.volume,
    required this.openPrice,
    required this.currentPrice,
    this.stopLoss,
    this.takeProfit,
    required this.profit,
    required this.swap,
    required this.openedAt,
    this.comment,
  });

  factory Position.fromJson(Map<String, dynamic> json) => Position(
        positionId: json['positionId'] as String,
        symbol: json['symbol'] as String,
        side: OrderSide.fromJson(json['side'] as String),
        volume: (json['volume'] as num).toDouble(),
        openPrice: (json['openPrice'] as num).toDouble(),
        currentPrice: (json['currentPrice'] as num).toDouble(),
        stopLoss: json['stopLoss'] != null
            ? (json['stopLoss'] as num).toDouble()
            : null,
        takeProfit: json['takeProfit'] != null
            ? (json['takeProfit'] as num).toDouble()
            : null,
        profit: (json['profit'] as num).toDouble(),
        swap: (json['swap'] as num).toDouble(),
        openedAt: DateTime.parse(json['openedAt'] as String),
        comment: json['comment'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'positionId': positionId,
        'symbol': symbol,
        'side': side.toJson(),
        'volume': volume,
        'openPrice': openPrice,
        'currentPrice': currentPrice,
        'stopLoss': stopLoss,
        'takeProfit': takeProfit,
        'profit': profit,
        'swap': swap,
        'openedAt': openedAt.toIso8601String(),
        'comment': comment,
      };
}

class AccountInfo {
  final String accountId;
  final double balance;
  final double equity;
  final double margin;
  final double freeMargin;
  final double marginLevel;
  final String currency;
  final double leverage;
  final DateTime updatedAt;

  AccountInfo({
    required this.accountId,
    required this.balance,
    required this.equity,
    required this.margin,
    required this.freeMargin,
    required this.marginLevel,
    required this.currency,
    required this.leverage,
    required this.updatedAt,
  });

  factory AccountInfo.fromJson(Map<String, dynamic> json) => AccountInfo(
        accountId: json['accountId'] as String,
        balance: (json['balance'] as num).toDouble(),
        equity: (json['equity'] as num).toDouble(),
        margin: (json['margin'] as num).toDouble(),
        freeMargin: (json['freeMargin'] as num).toDouble(),
        marginLevel: (json['marginLevel'] as num).toDouble(),
        currency: json['currency'] as String,
        leverage: (json['leverage'] as num).toDouble(),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'accountId': accountId,
        'balance': balance,
        'equity': equity,
        'margin': margin,
        'freeMargin': freeMargin,
        'marginLevel': marginLevel,
        'currency': currency,
        'leverage': leverage,
        'updatedAt': updatedAt.toIso8601String(),
      };
}

class CreateOrderRequest {
  final String symbol;
  final OrderType type;
  final OrderSide side;
  final double volume;
  final double? price;
  final double? stopLoss;
  final double? takeProfit;
  final String? comment;

  CreateOrderRequest({
    required this.symbol,
    required this.type,
    required this.side,
    required this.volume,
    this.price,
    this.stopLoss,
    this.takeProfit,
    this.comment,
  });

  Map<String, dynamic> toJson() => {
        'symbol': symbol,
        'type': type.toJson(),
        'side': side.toJson(),
        'volume': volume,
        'price': price,
        'stopLoss': stopLoss,
        'takeProfit': takeProfit,
        'comment': comment,
      };
}

class ModifyOrderRequest {
  final double? price;
  final double? stopLoss;
  final double? takeProfit;
  final String? comment;

  ModifyOrderRequest({
    this.price,
    this.stopLoss,
    this.takeProfit,
    this.comment,
  });

  Map<String, dynamic> toJson() => {
        'price': price,
        'stopLoss': stopLoss,
        'takeProfit': takeProfit,
        'comment': comment,
      };
}

class ClosePositionRequest {
  final double? price;
  final String? comment;

  ClosePositionRequest({
    this.price,
    this.comment,
  });

  Map<String, dynamic> toJson() => {
        'price': price,
        'comment': comment,
      };
}

class MarketData {
  final String symbol;
  final double bid;
  final double ask;
  final double last;
  final double volume;
  final DateTime timestamp;

  MarketData({
    required this.symbol,
    required this.bid,
    required this.ask,
    required this.last,
    required this.volume,
    required this.timestamp,
  });

  factory MarketData.fromJson(Map<String, dynamic> json) {
    return MarketData(
      symbol: json['symbol'] ?? '',
      bid: json['bid']?.toDouble() ?? 0.0,
      ask: json['ask']?.toDouble() ?? 0.0,
      last: json['last']?.toDouble() ?? 0.0,
      volume: json['volume']?.toDouble() ?? 0.0,
      timestamp:
          DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class OrderRequest {
  final String symbol;
  final String type;
  final double volume;
  final double price;

  OrderRequest({
    required this.symbol,
    required this.type,
    required this.volume,
    required this.price,
  });

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'type': type,
      'volume': volume,
      'price': price,
    };
  }
}
