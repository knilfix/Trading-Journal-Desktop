class TradePartial {
  final double riskPercentage; // e.g. 50 for 50%
  final double riskRewardRatio; // e.g. 4.0 for 4:1
  final TradeOutcome outcome;
  final String? id; // For easier management

  TradePartial({
    required this.riskPercentage,
    required this.riskRewardRatio,
    required this.outcome,
    String? id,
  }) : id = id ?? DateTime.now().microsecondsSinceEpoch.toString();

  // Helper to calculate P&L for this partial
  double calculatePnl(double totalRiskAmount) {
    final riskAmount = totalRiskAmount * (riskPercentage / 100);
    return riskAmount *
        (outcome == TradeOutcome.win
            ? riskRewardRatio
            : outcome == TradeOutcome.loss
            ? -1
            : 0);
  }
}

enum TradeOutcome { win, loss, breakeven }
