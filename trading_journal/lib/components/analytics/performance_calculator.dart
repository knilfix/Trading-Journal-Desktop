// lib/services/analytics/performance_calculator.dart

import 'package:trading_journal/models/performance_metrics.dart';
import 'package:trading_journal/models/trade.dart';
import 'package:trading_journal/models/account.dart';

class PerformanceCalculator {
  PerformanceMetrics calculate(List<Trade> trades, Account account) {
    if (trades.isEmpty) {
      return PerformanceMetrics(
        trades: [],
        winRate: 0.0,
        profitFactor: 0.0,
        avgwin: 0.0,
        avgloss: 0.0,
        equityCurveData: [],
        dailyPnl: [],
      );
    }

    final winningTrades = trades.where((t) => t.pnl > 0).toList();
    final losingTrades = trades.where((t) => t.pnl < 0).toList();

    // All your existing calculation logic goes here
    final double winRate = (winningTrades.length / trades.length) * 100;
    final double profitFactor = _calculateProfitFactor(
      winningTrades,
      losingTrades,
    );
    final double avgWin = _calculateAverage(winningTrades);
    final double avgLoss = _calculateAverage(losingTrades);
    final List<Map<String, dynamic>> equityCurveData = _calculateEquityCurve(
      trades,
      account.startBalance,
    );

    return PerformanceMetrics(
      trades: trades,
      winRate: winRate,
      profitFactor: profitFactor,
      avgwin: avgWin,
      avgloss: avgLoss,
      equityCurveData: equityCurveData,
      dailyPnl: _calculateDailyPnl(trades),
    );
  }

  // Your helper methods like _calculateProfitFactor, etc., go here
  double _calculateProfitFactor(List<Trade> winners, List<Trade> losers) {
    final grossProfit = winners.fold(0.0, (sum, t) => sum + t.pnl);
    final grossLoss = losers.fold(0.0, (sum, t) => sum + t.pnl);
    return grossLoss != 0 ? grossProfit / grossLoss.abs() : 0.0;
  }

  double _calculateAverage(List<Trade> trades) {
    if (trades.isEmpty) return 0.0;
    final total = trades.fold(0.0, (sum, t) => sum + t.pnl);
    return total / trades.length;
  }

  List<Map<String, dynamic>> _calculateEquityCurve(
    List<Trade> trades,
    double startBalance,
  ) {
    final List<Map<String, dynamic>> data = [
      {'time': trades.first.entryTime, 'balance': startBalance},
    ];
    double currentBalance = startBalance;
    for (var trade in trades) {
      currentBalance += trade.pnl;
      data.add({'time': trade.exitTime, 'balance': currentBalance});
    }
    return data;
  }

  List<double> _calculateDailyPnl(List<Trade> trades) {
    // This is a placeholder for your daily P&L logic
    // You'll need to group trades by day and sum their P&L
    return [];
  }
}
