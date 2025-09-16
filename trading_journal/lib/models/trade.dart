enum TradeDirection { buy, sell }

enum CurrencyPair {
  eurUsd('EUR/USD'),
  gbpUsd('GBP/USD'),
  usdJpy('USD/JPY'),
  audUsd('AUD/USD'),
  usdCad('USD/CAD'),
  nzdUsd('NZD/USD'),
  usdChf('USD/CHF'),
  eurGbp('EUR/GBP'),
  eurJpy('EUR/JPY'),
  gbpJpy('GBP/JPY');

  final String symbol;
  const CurrencyPair(this.symbol);

  @override
  String toString() => symbol;
}

class Trade {
  final int? id;
  final int accountId;
  final CurrencyPair currencyPair;
  final TradeDirection direction;
  final DateTime entryTime;
  final DateTime exitTime;
  final double riskAmount;
  final double pnl;
  final double postTradeBalance;
  final String? notes;
  // This is the correct, new field
  final List<Map<String, String>> screenshots;

  Trade({
    this.id,
    required this.accountId,
    required this.currencyPair,
    required this.direction,
    required this.entryTime,
    required this.exitTime,
    required this.riskAmount,
    required this.pnl,
    required this.postTradeBalance,
    this.notes,
    // Make the screenshots list an optional parameter with a default empty list
    this.screenshots = const [],
  });

  // Simplified copyWith
  Trade copyWith({
    int? id,
    int? accountId,
    CurrencyPair? currencyPair,
    TradeDirection? direction,
    DateTime? entryTime,
    DateTime? exitTime,
    double? riskAmount,
    double? pnl,
    double? postTradeBalance,
    String? notes,
    List<Map<String, String>>? screenshots,
  }) {
    return Trade(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      currencyPair: currencyPair ?? this.currencyPair,
      direction: direction ?? this.direction,
      entryTime: entryTime ?? this.entryTime,
      exitTime: exitTime ?? this.exitTime,
      riskAmount: riskAmount ?? this.riskAmount,
      pnl: pnl ?? this.pnl,
      postTradeBalance: postTradeBalance ?? this.postTradeBalance,
      notes: notes ?? this.notes,
      screenshots: screenshots ?? this.screenshots,
    );
  }

  // Update serialization methods to handle the list
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'account_id': accountId,
      'currency_pair': currencyPair.name,
      'direction': direction.name,
      'risk_amount': riskAmount,
      'pnl': pnl,
      'account_balance': postTradeBalance,
      'entry_time': entryTime.toIso8601String(),
      'exit_time': exitTime.toIso8601String(),
      'notes': notes,
      'screenshots': screenshots, // Use the new list
    };
  }

  factory Trade.fromMap(Map<String, dynamic> map) {
    // Get the screenshots list, defaulting to an empty list if it's null
    final List<dynamic> screenshotsFromMap = map['screenshots'] ?? [];

    // Convert the generic list of maps into our specific type
    final List<Map<String, String>> screenshots = screenshotsFromMap
        .map((item) => Map<String, String>.from(item))
        .toList();

    return Trade(
      id: map['id'] as int?,
      accountId: map['account_id'] as int,
      currencyPair: CurrencyPair.values.firstWhere(
        (e) => e.name == map['currency_pair'],
      ),
      direction: TradeDirection.values.firstWhere(
        (e) => e.name == map['direction'],
      ),
      riskAmount: map['risk_amount'] as double,
      pnl: map['pnl'] as double,
      postTradeBalance: map['account_balance'] as double,
      entryTime: DateTime.parse(map['entry_time']),
      exitTime: DateTime.parse(map['exit_time']),
      notes: map['notes'] as String?,
      screenshots: screenshots, // Use the new, correctly typed list
    );
  }

  // Helper methods for analysis
  double get riskRewardRatio {
    if (riskAmount == 0) return 0;
    return pnl.abs() / riskAmount;
  }

  Duration get duration => exitTime.difference(entryTime);
}
