import 'package:trading_journal/models/trade.dart';

class PerformanceMetrics {
  // Placeholder for performance metrics calculations
  final List<Trade> trades;

  //performance metrics
  final double winRate;
  final double profitFactor;
  final double avgwin;
  final double avgloss;

  //equity curve data
  final List<Map<String, dynamic>> equityCurveData;

  final Map<String, double> dailyPnl;

  PerformanceMetrics({
    required this.trades,
    required this.winRate,
    required this.profitFactor,
    required this.avgwin,
    required this.avgloss,
    required this.equityCurveData,
    required this.dailyPnl,
  });
}
