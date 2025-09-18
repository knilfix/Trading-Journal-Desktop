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
        totalProfit: 0.0,
        totalLoss: 0.0,
      );
    }

    // Calculate basic metrics
    final netPnL = trades.fold(0.0, (sum, trade) => sum + trade.pnl);
    final totalTrades = trades.length;
    final averagePnL = netPnL / totalTrades;

    // Calculate daily P&L
    final Map<String, double> dailyPnl = {};
    for (var trade in trades) {
      final date = trade.exitTime.toIso8601String().substring(0, 10);
      dailyPnl[date] = (dailyPnl[date] ?? 0.0) + trade.pnl;
    }

    // Handle biggest winning/losing days safely
    double biggestWinningDay = 0.0;
    double biggestLosingDay = 0.0;

    if (dailyPnl.isNotEmpty) {
      biggestWinningDay = dailyPnl.values.reduce(max);
      biggestLosingDay = dailyPnl.values.reduce(min);
    }

    // Calculate winning and losing trades
    final winningTrades = trades.where((t) => t.pnl > 0).toList();
    final losingTrades = trades.where((t) => t.pnl < 0).toList();

    // Calculate expectancy
    double avgWin = 0.0;
    if (winningTrades.isNotEmpty) {
      avgWin =
          winningTrades.fold(0.0, (sum, t) => sum + t.pnl) /
          winningTrades.length;
    }

    double avgLoss = 0.0;
    if (losingTrades.isNotEmpty) {
      avgLoss =
          losingTrades.fold(0.0, (sum, t) => sum + t.pnl.abs()) /
          losingTrades.length;
    }

    final winRate = winningTrades.length / totalTrades;
    final lossRate = losingTrades.length / totalTrades;
    final expectancy = (winRate * avgWin) - (lossRate * avgLoss);

    // Calculate total profit and loss
    final totalProfit = winningTrades.fold(
      0.0,
      (sum, trade) => sum + trade.pnl,
    );
    final totalLoss = losingTrades.fold(
      0.0,
      (sum, trade) => sum + trade.pnl.abs(),
    );

    return ProfitLossData(
      netPnL: netPnL,
      biggestWinningDay: biggestWinningDay,
      biggestLosingDay: biggestLosingDay,
      averagePnL: averagePnL,
      totalTrades: totalTrades,
      expectancy: expectancy,
      totalProfit: totalProfit,
      totalLoss: totalLoss,
    );
  }
}
