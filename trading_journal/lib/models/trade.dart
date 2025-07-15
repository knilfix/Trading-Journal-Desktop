class Trade {
  final int? id;
  final int accountId;
  final CurrencyPair currencyPair;
  final TradeDirection direction;
  final DateTime entryTime;
  final DateTime exitTime;
  final double riskAmount;
  final double pnl;
  final double postTradeBalance; // Add this property
  final String? notes;
  final List<String>? attachmentPaths;

  Trade({
    this.id,
    required this.accountId,
    required this.currencyPair,
    required this.direction,
    required this.entryTime,
    required this.exitTime,
    required this.riskAmount,
    required this.pnl,
    required this.postTradeBalance, // Add to constructor
    this.notes,
    this.attachmentPaths,
  });

  // Update serialization methods
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'account_id': accountId,
      'currency_pair': currencyPair.name,
      'direction': direction.name,
      'risk_amount': riskAmount,
      'pnl': pnl,
      'account_balance': postTradeBalance, // Add to map
      'entry_time': entryTime.toIso8601String(),
      'exit_time': exitTime.toIso8601String(),
      'notes': notes,
    };
  }

  factory Trade.fromMap(Map<String, dynamic> map) {
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
      postTradeBalance: map['account_balance'] as double, // Add from map
      entryTime: DateTime.parse(map['entry_time']),
      exitTime: DateTime.parse(map['exit_time']),
      notes: map['notes'] as String?,
      attachmentPaths: map['attachment_paths'] != null
          ? List<String>.from(map['attachment_paths'])
          : null,
    );
  }

  double get riskRewardRatio {
    if (riskAmount == 0) return 0;
    return pnl.abs() / riskAmount;
  }

  Duration get duration => exitTime.difference(entryTime);
}

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
