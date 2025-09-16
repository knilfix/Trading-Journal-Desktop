import 'dart:math';
import 'package:trading_journal/models/profit_loss_data.dart';
import 'package:trading_journal/models/trade.dart';

class ProfitLossCalculator {
  ProfitLossData calculate(List<Trade> trades) {
    if (trades.isEmpty) {
      return ProfitLossData(
        netPnL: 0.0,
        biggestWinningDay: 0.0,
        biggestLosingDay: 0.0,
        averagePnL: 0.0,
        totalTrades: 0,
        expectancy: 0.0,
      );
    }

    // Step 1: Calculate Net P&L, total fees, and total trades
    final netPnL = trades.fold(0.0, (sum, trade) => sum + trade.pnl);
    final totalTrades = trades.length;
    final averagePnL = netPnL / totalTrades;

    // Step 2: Calculate daily P&L to find biggest winning/losing day
    final Map<String, double> dailyPnl = {};
    for (var trade in trades) {
      final date = trade.exitTime.toIso8601String().substring(0, 10);
      dailyPnl[date] = (dailyPnl[date] ?? 0.0) + trade.pnl;
    }

    // Use min and max from dart:math for a cleaner implementation
    final biggestWinningDay = dailyPnl.values.reduce(max);
    final biggestLosingDay = dailyPnl.values.reduce(min);

    // Step 3: Calculate expectancy, handling empty lists
    final winningTrades = trades.where((t) => t.pnl > 0).toList();
    final losingTrades = trades.where((t) => t.pnl < 0).toList();

    double avgWin = 0.0;
    if (winningTrades.isNotEmpty) {
      final grossProfit = winningTrades.fold(0.0, (sum, t) => sum + t.pnl);
      avgWin = grossProfit / winningTrades.length;
    }

    double avgLoss = 0.0;
    if (losingTrades.isNotEmpty) {
      final grossLoss = losingTrades.fold(0.0, (sum, t) => sum + t.pnl);
      avgLoss = grossLoss / losingTrades.length;
    }

    final winRate = winningTrades.length / totalTrades;
    final lossRate = losingTrades.length / totalTrades;

    // Expectancy formula
    final expectancy = (winRate * avgWin) - (lossRate * avgLoss.abs());

    return ProfitLossData(
      netPnL: netPnL,
      biggestWinningDay: biggestWinningDay,
      biggestLosingDay: biggestLosingDay,
      averagePnL: averagePnL,
      totalTrades: totalTrades,
      expectancy: expectancy,
    );
  }
}
