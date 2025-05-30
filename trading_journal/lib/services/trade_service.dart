import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:trading_journal/models/trade.dart';
import '../services/account_service.dart';

class TradeService extends ChangeNotifier {
  static final TradeService instance = TradeService._internal();
  TradeService._internal();

  final List<Trade> _trades = [];
  int _nextId = 1;

  // Immutable trades - no update/delete methods
  List<Trade> get trades => List.unmodifiable(_trades);

  bool _isGeneratingTrades = false;
  bool get isGeneratingTrades => _isGeneratingTrades;
  final activeAccount = AccountService.instance.activeAccount;

  final StreamController<List<Trade>> _tradesStream =
      StreamController.broadcast();
  Stream<List<Trade>> get tradesStream => _tradesStream.stream;

  Trade? getTradeById(int tradeId) {
    try {
      return _trades.firstWhere((trade) => trade.id == tradeId);
    } catch (e) {
      debugPrint('[TradeService] Trade with ID $tradeId not found');
      return null;
    }
  }

  Future<Trade?> recordTrade({
    required int accountId,
    required CurrencyPair currencyPair,
    required TradeDirection direction,
    required double riskAmount,
    required double pnl,
    required DateTime entryTime,
    required DateTime exitTime,
    String? notes,
  }) async {
    assert(exitTime.isAfter(entryTime), "Exit time must be after entry time");

    try {
      final account = AccountService.instance.getAccountById(accountId);
      if (account == null) {
        debugPrint("[ERROR] Account $accountId not found");
        return null;
      }

      final newBalance = account.balance + pnl;
      assert(newBalance >= 0, "Account balance cannot be negative");

      final updatedAccount = await AccountService.instance.updateAccountBalance(
        accountId,
        newBalance,
      );
      if (updatedAccount == null) return null;

      final trade = Trade(
        id: _nextId++,
        accountId: accountId,
        currencyPair: currencyPair,
        direction: direction,
        riskAmount: riskAmount,
        pnl: pnl,
        postTradeBalance: newBalance,
        entryTime: entryTime,
        exitTime: exitTime,
        notes: notes,
      );

      _trades.add(trade);
      _tradesStream.add(_trades);
      notifyListeners();

      _logTradeMetrics(trade, account.balance, accountId); // Now called!
      return trade;
    } catch (e, stackTrace) {
      debugPrint("[EXCEPTION] Failed to record trade: $e");
      debugPrint(stackTrace.toString());
      return null;
    }
  }

  void _logTradeMetrics(Trade trade, double previousBalance, int accountId) {
    // 1. Get the current balance AFTER trade execution
    final currentBalance =
        AccountService.instance.getAccountById(accountId)?.balance ??
        previousBalance; // Fallback to previous if fetch fails

    // 2. Calculate expected new balance
    final expectedBalance = previousBalance + trade.pnl;

    // 3. Add verification metrics
    final metrics = {
      'Trade ID': trade.id,
      'Pair': trade.currencyPair.symbol,
      'Direction': trade.direction.toString().split('.').last,
      'Risk Amount': '\$${trade.riskAmount.toStringAsFixed(2)}',
      'PnL': '\$${trade.pnl.toStringAsFixed(2)}',
      'Duration':
          '${trade.duration.inHours}h ${trade.duration.inMinutes.remainder(60)}m',
      'Risk:Reward': '1:${trade.riskRewardRatio.abs().toStringAsFixed(2)}',
      'Previous Balance': '\$${previousBalance.toStringAsFixed(2)}',
      'Expected Balance': '\$${expectedBalance.toStringAsFixed(2)}',
      'Current Balance': '\$${currentBalance.toStringAsFixed(2)}',
      'Balance Match': currentBalance == expectedBalance ? '✅' : '❌',
      'Account Impact':
          '${((trade.pnl / previousBalance) * 100).toStringAsFixed(2)}%',
      'Entry Time': trade.entryTime.toString(),
      'Exit Time': trade.exitTime.toString(),
    };

    // 4. Debug output
    debugPrint("[TRADE METRICS] ================");
    metrics.forEach((key, value) => debugPrint("$key: $value"));
    debugPrint("===============================");

    // 5. Explicit warning if mismatch
    if (currentBalance != expectedBalance) {
      debugPrint("[WARNING] Balance mismatch detected!");
      debugPrint("Expected: \$${expectedBalance.toStringAsFixed(2)}");
      debugPrint("Actual: \$${currentBalance.toStringAsFixed(2)}");
    }
  }

  /// Deletes a trade and adjusts the account balance accordingly
  Future<bool> deleteTrade(int tradeId) async {
    try {
      // 1. Find the trade to delete
      final tradeIndex = _trades.indexWhere((t) => t.id == tradeId);
      if (tradeIndex == -1) {
        debugPrint("[ERROR] Trade $tradeId not found");
        return false;
      }
      final tradeToDelete = _trades[tradeIndex];

      // 2. Get the associated account
      final account = AccountService.instance.getAccountById(
        tradeToDelete.accountId,
      );
      if (account == null) {
        debugPrint("[ERROR] Associated account not found");
        return false;
      }

      // 3. Calculate new balance by reversing the trade's PnL
      final newBalance = account.balance - tradeToDelete.pnl;

      // 4. Update the account balance
      final updatedAccount = await AccountService.instance.updateAccountBalance(
        tradeToDelete.accountId,
        newBalance,
      );
      if (updatedAccount == null) return false;

      // 5. Remove the trade
      _trades.removeAt(tradeIndex);

      // 6. Notify listeners and update stream
      _tradesStream.add(_trades);
      notifyListeners();

      debugPrint(
        "[SUCCESS] Deleted trade $tradeId and adjusted account balance",
      );
      return true;
    } catch (e, stackTrace) {
      debugPrint("[EXCEPTION] Failed to delete trade: $e");
      debugPrint(stackTrace.toString());
      return false;
    }
  }

  List<Trade> getTradesForAccount(int accountId) {
    return _trades.where((t) => t.accountId == accountId).toList();
  }

  void clearAccountTrades(int accountId) {
    _trades.removeWhere((trade) => trade.accountId == accountId);
    notifyListeners();
  }

  Future<void> createTestTradesForTestAccount(int accountId) async {
    if (_isGeneratingTrades) return;

    _isGeneratingTrades = true;
    notifyListeners();

    try {
      final account = AccountService.instance.getAccountById(accountId);
      if (account == null) {
        debugPrint('Account $accountId not found');
        return;
      }

      if (account.name == 'Testing Account' &&
          getTradesForAccount(accountId).isEmpty) {
        final testTrades = await _generateTestTrades(accountId);

        for (final trade in testTrades) {
          await recordTrade(
            accountId: accountId,
            currencyPair: trade.currencyPair,
            direction: trade.direction,
            riskAmount: trade.riskAmount,
            pnl: trade.pnl,
            entryTime: trade.entryTime,
            exitTime: trade.exitTime,
            notes: trade.notes,
          );
        }

        debugPrint('Created ${testTrades.length} test trades');
      }
    } catch (e, stackTrace) {
      debugPrint('Error generating trades: $e');
      debugPrint(stackTrace.toString());
    } finally {
      _isGeneratingTrades = false;
      notifyListeners();
    }
  }

  Future<void> createDemoTradesForAccount(int accountId) async {
    if (_isGeneratingTrades) return;

    _isGeneratingTrades = true;
    notifyListeners();

    try {
      final account = AccountService.instance.getAccountById(accountId);
      if (account == null) return;

      final demoTrades = await _generateTestTrades(accountId);

      for (final trade in demoTrades) {
        await recordTrade(
          accountId: accountId,
          currencyPair: trade.currencyPair,
          direction: trade.direction,
          riskAmount: trade.riskAmount,
          pnl: trade.pnl,
          entryTime: trade.entryTime,
          exitTime: trade.exitTime,
          notes: trade.notes,
        );
      }
      debugPrint('Created ${demoTrades.length} demo trades');
    } catch (e, stackTrace) {
      debugPrint('Error generating demo trades: $e');
      debugPrint(stackTrace.toString());
    } finally {
      _isGeneratingTrades = false;
      notifyListeners();
    }
  }

  Future<List<Trade>> _generateTestTrades(int accountId) async {
    final random = Random();
    final baseTime = DateTime.now().subtract(const Duration(days: 7));
    final account = AccountService.instance.getAccountById(accountId);
    if (account == null) throw Exception('Account not found');

    double runningBalance = account.balance;
    final trades = <Trade>[];

    // Strict risk management parameters
    const riskPercentage = 1.0; // Always risk 1%
    const fixedRewardRatio = 4.0; // Always target 4:1 RR
    const winRate = 0.4; // 40% win rate

    for (int i = 0; i < 40; i++) {
      // Calculate fixed risk amount (1% of current balance)
      final riskAmount = runningBalance * (riskPercentage / 100);

      // Determine trade outcome (win/loss only)
      final isWin = random.nextDouble() <= winRate;

      // Fixed PnL calculation (4:1 on wins, -1R on losses)
      final pnl = isWin ? (riskAmount * fixedRewardRatio) : -riskAmount;

      // Update running balance
      runningBalance += pnl;

      // Trade timing (unchanged)
      final entryTime = baseTime.add(Duration(hours: i * 6));
      final exitTime = entryTime.add(Duration(hours: 1 + random.nextInt(3)));

      final trade = Trade(
        id: _nextId++,
        accountId: accountId,
        currencyPair:
            CurrencyPair.values[random.nextInt(CurrencyPair.values.length)],
        direction: random.nextBool() ? TradeDirection.buy : TradeDirection.sell,
        riskAmount: riskAmount,
        pnl: pnl,
        postTradeBalance: runningBalance,
        entryTime: entryTime,
        exitTime: exitTime,
        notes:
            'Test trade ${i + 1}: ${isWin ? "WIN" : "LOSS"} | Fixed RR: $fixedRewardRatio',
      );

      trades.add(trade);

      // Debug output with risk consistency verification
      debugPrint('''
[TRADE ${i + 1}] ${isWin ? "WIN" : "LOSE"}
Risk: \$${riskAmount.toStringAsFixed(2)} (STRICT $riskPercentage%)
RR Ratio: $fixedRewardRatio:1
PnL: \$${pnl.toStringAsFixed(2)}
Account Impact: ${(riskAmount / runningBalance * 100).toStringAsFixed(2)}% risk
New Balance: \$${runningBalance.toStringAsFixed(2)}
===============================
''');
    }

    return trades;
  }
}
