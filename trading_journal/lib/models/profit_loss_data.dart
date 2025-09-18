class ProfitLossData {
  // Placeholder for profit and loss data structure

  final double netPnL;
  final double biggestWinningDay;
  final double biggestLosingDay;
  final double averagePnL;
  final double totalProfit;
  final double totalLoss;

  final int totalTrades;
  final double expectancy;

  ProfitLossData({
    required this.netPnL,
    required this.biggestWinningDay,
    required this.biggestLosingDay,
    required this.averagePnL,
    required this.totalTrades,
    required this.expectancy,
    required this.totalProfit,
    required this.totalLoss,
  });
}
