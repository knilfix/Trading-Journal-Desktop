import 'package:trading_journal/models/trade.dart';
import 'package:trading_journal/models/trade_quality_data.dart';

class TradeQualityCalculator {
  TradeQualityData calculate(List<Trade> trades) {
    if (trades.isEmpty) {
      return TradeQualityData(
        riskRewardDistribution: [],
        holdTimeAnalysis: {'winning': {}, 'losing': {}},
        hourlyPerformance: {},
        weeklyPerformance: {},
      );
    }

    final winningTrades = trades.where((t) => t.pnl > 0).toList();
    final losingTrades = trades.where((t) => t.pnl < 0).toList();

    return TradeQualityData(
      // Call the helper methods with the correct `this.` prefix or as private methods.
      // This is the correct syntax for calling methods on the same class.
      riskRewardDistribution: _calculateRiskRewardDistribution(trades),
      holdTimeAnalysis: _calculateHoldTimeAnalysis(winningTrades, losingTrades),
      hourlyPerformance: _calculateHourlyPerformance(trades),
      weeklyPerformance: _calculateWeeklyPerformance(trades),
    );
  }

  List<Map<String, dynamic>> _calculateRiskRewardDistribution(
    List<Trade> trades,
  ) {
    final Map<String, int> distribution = {};
    for (var trade in trades) {
      if (trade.riskAmount == 0) continue;
      // Calculate a simplified R:R (e.g., P&L / Risk)
      final ratio = (trade.pnl / trade.riskAmount).toStringAsFixed(1);
      distribution[ratio] = (distribution[ratio] ?? 0) + 1;
    }
    return distribution.entries
        .map((e) => {'ratio': e.key, 'count': e.value})
        .toList();
  }

  Map<String, Map<String, Duration>> _calculateHoldTimeAnalysis(
    List<Trade> winningTrades,
    List<Trade> losingTrades,
  ) {
    final Map<String, Map<String, Duration>> analysis = {
      'winning': {},
      'losing': {},
    };

    if (winningTrades.isNotEmpty) {
      final winningDurations = winningTrades
          .map((t) => t.exitTime.difference(t.entryTime))
          .toList();
      final averageWinningHold =
          winningDurations.fold(Duration.zero, (sum, d) => sum + d) ~/
          winningDurations.length;
      analysis['winning']!['average'] = averageWinningHold;
      analysis['winning']!['min'] = winningDurations.reduce(
        (a, b) => a < b ? a : b,
      );
      analysis['winning']!['max'] = winningDurations.reduce(
        (a, b) => a > b ? a : b,
      );
    }

    if (losingTrades.isNotEmpty) {
      final losingDurations = losingTrades
          .map((t) => t.exitTime.difference(t.entryTime))
          .toList();
      final averageLosingHold =
          losingDurations.fold(Duration.zero, (sum, d) => sum + d) ~/
          losingDurations.length;
      analysis['losing']!['average'] = averageLosingHold;
      analysis['losing']!['min'] = losingDurations.reduce(
        (a, b) => a < b ? a : b,
      );
      analysis['losing']!['max'] = losingDurations.reduce(
        (a, b) => a > b ? a : b,
      );
    }
    return analysis;
  }

  Map<int, double> _calculateHourlyPerformance(List<Trade> trades) {
    final Map<int, double> hourlyPnl = {};
    for (var trade in trades) {
      final hour = trade.exitTime.hour;
      hourlyPnl[hour] = (hourlyPnl[hour] ?? 0.0) + trade.pnl;
    }
    return hourlyPnl;
  }

  Map<String, double> _calculateWeeklyPerformance(List<Trade> trades) {
    final Map<String, double> weeklyPnl = {};
    final daysOfWeek = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    for (var trade in trades) {
      final day = daysOfWeek[trade.exitTime.weekday - 1];
      weeklyPnl[day] = (weeklyPnl[day] ?? 0.0) + trade.pnl;
    }
    return weeklyPnl;
  }
}
