import 'package:fl_chart/fl_chart.dart';
import 'dart:math';
import '../../../models/trade.dart';

class TradeDataProcessor {
  final List<Trade> trades;
  final double startingBalance;
  final bool showLastTenOnly;

  late final List<Trade> _sortedTrades;
  late final List<TradeWithBalance> _tradesWithBalance;

  TradeDataProcessor(
    this.trades,
    this.startingBalance, {
    this.showLastTenOnly = false,
  }) {
    // Sort trades by date in chronological order
    _sortedTrades = List.from(trades)
      ..sort((a, b) => a.entryTime.compareTo(b.entryTime));

    // Pre-calculate all balances for efficiency
    _tradesWithBalance = _calculateBalances();
  }

  List<TradeWithBalance> _calculateBalances() {
    final result = <TradeWithBalance>[];
    double runningBalance = startingBalance;

    for (int i = 0; i < _sortedTrades.length; i++) {
      runningBalance += _sortedTrades[i].pnl;
      result.add(
        TradeWithBalance(
          trade: _sortedTrades[i],
          balanceAfter: runningBalance,
          index: i,
        ),
      );
    }

    return result;
  }

  List<TradeWithBalance> get processedTrades {
    if (showLastTenOnly && _tradesWithBalance.length > 10) {
      return _tradesWithBalance.skip(_tradesWithBalance.length - 10).toList();
    }

    // Intelligent sampling when showing all trades
    if (!showLastTenOnly && _tradesWithBalance.length > 20) {
      return _intelligentSample(_tradesWithBalance);
    }

    return _tradesWithBalance;
  }

  List<TradeWithBalance> _intelligentSample(List<TradeWithBalance> allTrades) {
    if (allTrades.length <= 15) return allTrades;

    final sampled = <TradeWithBalance>[];

    // Always include first trade
    sampled.add(allTrades.first);

    // Always include last few trades (recent activity is important)
    final lastFew = allTrades.skip(max(0, allTrades.length - 3)).toList();

    // Find significant trades (biggest wins/losses, milestones)
    final significantTrades = _findSignificantTrades(allTrades);

    // Combine and sort by original index
    final combined = <TradeWithBalance>{
      ...sampled,
      ...significantTrades,
      ...lastFew,
    }.toList()..sort((a, b) => a.index.compareTo(b.index));

    // If still too many, subsample evenly
    if (combined.length > 15) {
      return _evenlySubsample(combined, 12);
    }

    return combined;
  }

  List<TradeWithBalance> _findSignificantTrades(List<TradeWithBalance> trades) {
    final significant = <TradeWithBalance>[];

    // Sort by PnL to find biggest wins/losses
    final sortedByPnl = List.from(trades)
      ..sort((a, b) => b.trade.pnl.abs().compareTo(a.trade.pnl.abs()));

    // Take top 5 most significant trades by absolute PnL
    significant.addAll(sortedByPnl.take(5).cast<TradeWithBalance>());

    // Find balance milestones (new highs/lows)
    double highWaterMark = startingBalance;
    double lowWaterMark = startingBalance;

    for (final tradeWithBalance in trades) {
      if (tradeWithBalance.balanceAfter > highWaterMark) {
        highWaterMark = tradeWithBalance.balanceAfter;
        significant.add(tradeWithBalance);
      }
      if (tradeWithBalance.balanceAfter < lowWaterMark) {
        lowWaterMark = tradeWithBalance.balanceAfter;
        significant.add(tradeWithBalance);
      }
    }

    return significant;
  }

  List<TradeWithBalance> _evenlySubsample(
    List<TradeWithBalance> trades,
    int targetCount,
  ) {
    if (trades.length <= targetCount) return trades;

    final result = <TradeWithBalance>[];
    final step = trades.length / (targetCount - 1);

    for (int i = 0; i < targetCount - 1; i++) {
      final index = (i * step).round();
      if (index < trades.length) {
        result.add(trades[index]);
      }
    }

    // Always include the last trade
    if (trades.isNotEmpty && !result.contains(trades.last)) {
      result.add(trades.last);
    }

    return result;
  }

  List<FlSpot> generateCumulativeSpots() {
    final List<FlSpot> spots = []; // Explicitly type the list
    final tradesToShow = processedTrades;

    if (showLastTenOnly && _tradesWithBalance.length > 10) {
      // Find the balance before the last 10 trades started
      final startIndex = _tradesWithBalance.length - 10;
      final precedingBalance = startIndex > 0
          ? _tradesWithBalance[startIndex - 1].balanceAfter
          : startingBalance;

      // Add the preceding point
      spots.add(FlSpot(0, precedingBalance));

      // Add the last 10 trades
      for (int i = 0; i < tradesToShow.length; i++) {
        spots.add(FlSpot((i + 1).toDouble(), tradesToShow[i].balanceAfter));
      }
    } else {
      // Original behavior for all trades
      spots.add(FlSpot(0, startingBalance));
      for (int i = 0; i < tradesToShow.length; i++) {
        final xPosition = showLastTenOnly
            ? (i + 1).toDouble()
            : (tradesToShow[i].index + 1).toDouble();
        spots.add(FlSpot(xPosition, tradesToShow[i].balanceAfter));
      }
    }

    return spots;
  }

  double calculateMinY() {
    if (_tradesWithBalance.isEmpty) return startingBalance * 0.95;

    final tradesToAnalyze = processedTrades;
    double minBalance = startingBalance;

    for (final tradeWithBalance in tradesToAnalyze) {
      minBalance = min(minBalance, tradeWithBalance.balanceAfter);
    }

    // Smart padding based on range
    final range = calculateMaxY() - minBalance;
    final padding = range * 0.1;
    return minBalance - padding;
  }

  double calculateMaxY() {
    if (_tradesWithBalance.isEmpty) return startingBalance * 1.05;

    final tradesToAnalyze = processedTrades;
    double maxBalance = startingBalance;

    for (final tradeWithBalance in tradesToAnalyze) {
      maxBalance = max(maxBalance, tradeWithBalance.balanceAfter);
    }

    // Smart padding based on range
    final range = maxBalance - calculateMinYRaw();
    final padding = range * 0.1;
    return maxBalance + padding;
  }

  double calculateMinYRaw() {
    if (_tradesWithBalance.isEmpty) return startingBalance;

    final tradesToAnalyze = processedTrades;
    double minBalance = startingBalance;

    for (final tradeWithBalance in tradesToAnalyze) {
      minBalance = min(minBalance, tradeWithBalance.balanceAfter);
    }

    return minBalance;
  }

  // Helper method to get trade details for tooltips
  // Update getTradePoint to handle the preceding point for last 10 trades
  TradePoint getTradePoint(int index) {
    if (showLastTenOnly && _tradesWithBalance.length > 10) {
      if (index == 0) {
        // Return the balance point before the last 10 trades
        final startIndex = _tradesWithBalance.length - 10;
        final precedingBalance = startIndex > 0
            ? _tradesWithBalance[startIndex - 1].balanceAfter
            : startingBalance;

        return TradePoint(
          balance: precedingBalance,
          pnl: 0,
          date: startIndex > 0
              ? _tradesWithBalance[startIndex - 1].trade.exitTime
              : null,
          isStartingBalance: false,
          tradeId: startIndex > 0
              ? _tradesWithBalance[startIndex - 1].trade.id
              : null,
        );
      }

      final tradesToShow = processedTrades;
      if (index - 1 < tradesToShow.length) {
        final trade = tradesToShow[index - 1];
        return TradePoint(
          balance: trade.balanceAfter,
          pnl: trade.trade.pnl,
          date: trade.trade.entryTime,
          isStartingBalance: false,
          tradeId: trade.trade.id,
        );
      }
    }

    // Original behavior for all trades
    return _getTradePointForAllTrades(index);
  }

  // Helper method for original trade point logic
  TradePoint _getTradePointForAllTrades(int index) {
    if (index == 0) {
      return TradePoint(
        balance: startingBalance,
        pnl: 0,
        isStartingBalance: true,
      );
    }

    final tradesToShow = processedTrades;
    final targetTrade = tradesToShow.firstWhere(
      (t) => t.index == index - 1,
      orElse: () => tradesToShow.last,
    );

    return TradePoint(
      balance: targetTrade.balanceAfter,
      pnl: targetTrade.trade.pnl,
      date: targetTrade.trade.entryTime,
      isStartingBalance: false,
      tradeId: targetTrade.trade.id,
    );
  }

  int get tradeCount {
    if (showLastTenOnly) {
      return min(10, _sortedTrades.length) + 1; // +1 for starting point
    }
    return _sortedTrades.length + 1; // +1 for starting point
  }

  // Getter for total trades (useful for header display)
  int get totalTradeCount => _sortedTrades.length;

  // Check if we're currently sampling
  bool get isSampling => !showLastTenOnly && _tradesWithBalance.length > 20;
}

class TradePoint {
  final double balance;
  final double pnl;
  final DateTime? date;
  final bool isStartingBalance;
  final int? tradeId;

  TradePoint({
    required this.balance,
    required this.pnl,
    this.date,
    this.isStartingBalance = false,
    this.tradeId,
  });
}

class TradeWithBalance {
  final Trade trade;
  final double balanceAfter;
  final int index; // Original position in the full trade list

  TradeWithBalance({
    required this.trade,
    required this.balanceAfter,
    required this.index,
  });
}
