class TradePartials {
  final double riskPercentage;
  final double riskRewardRatio;
  final TradeOutcome outcome;

  TradePartials({
    required this.riskPercentage,
    required this.riskRewardRatio,
    required this.outcome,
  });
}

enum TradeOutcome { win, loss, breakeven }
