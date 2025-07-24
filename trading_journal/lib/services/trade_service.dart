import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:trading_journal/models/trade.dart';
import '../services/account_service.dart';

/// Service for managing trades, including CRUD operations, persistence, and reactive updates for the active account.
class TradeService extends ChangeNotifier {
  /// Singleton instance of TradeService.
  static final TradeService instance = TradeService._internal();

  /// Private constructor for singleton pattern. Loads trades from storage on initialization.
  TradeService._internal() {
    loadFromJson();
  }

  /// In-memory list of all trades.
  final List<Trade> _trades = [];

  /// The next trade ID to assign.
  int _nextId = 1;

  static const String _tradeFileName = 'trades.json';

  /// Returns an unmodifiable list of all trades.
  List<Trade> get trades => List.unmodifiable(_trades);

  /// Stream controller for broadcasting trade list updates.
  final StreamController<List<Trade>> _tradesStream =
      StreamController.broadcast();

  /// Stream of all trades (for reactive UI updates).
  Stream<List<Trade>> get tradesStream => _tradesStream.stream;

  /// Returns the trade with the given ID, or null if not found.
  Trade? getTradeById(int tradeId) {
    try {
      return _trades.firstWhere((trade) => trade.id == tradeId);
    } catch (e) {
      return null;
    }
  }

  /// Returns a File handle for the trades.json file in the app's documents directory.
  Future<File> _getTradeFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final appDir = Directory('${directory.path}/TradingJournal');
    if (!await appDir.exists()) {
      await appDir.create(recursive: true);
    }
    return File('${appDir.path}/$_tradeFileName');
  }

  /// Records a new trade for the given account, updates the account balance, and persists the change.
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
      await saveToJson();
      _tradesStream.add(_trades);
      notifyListeners();

      return trade;
    } catch (e) {
      return null;
    }
  }

  /// Deletes the trade with the given ID and adjusts the associated account's balance.
  Future<bool> deleteTrade(int tradeId) async {
    try {
      // 1. Find the trade to delete
      final tradeIndex = _trades.indexWhere((t) => t.id == tradeId);
      if (tradeIndex == -1) {
        return false;
      }
      final tradeToDelete = _trades[tradeIndex];

      // 2. Get the associated account
      final account = AccountService.instance.getAccountById(
        tradeToDelete.accountId,
      );
      if (account == null) {
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
      await saveToJson();

      // 6. Notify listeners and update stream
      _tradesStream.add(_trades);
      notifyListeners();

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Returns a list of trades for the given account ID.
  List<Trade> getTradesForAccount(int accountId) {
    return _trades.where((t) => t.accountId == accountId).toList();
  }

  /// Async version of getTradesForAccount for FutureBuilder usage
  Future<List<Trade>> getTradesForAccountAsync(int accountId) async {
    return getTradesForAccount(accountId); // Just wraps the synchronous version
  }

  /// Removes all trades for the given account ID.
  void clearAccountTrades(int accountId) {
    _trades.removeWhere((trade) => trade.accountId == accountId);
    saveToJson();
    notifyListeners();
  }

  /// Loads trades from persistent storage (trades.json).
  Future<void> loadFromJson() async {
    final file = await _getTradeFile();
    if (await file.exists()) {
      final contents = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(contents);
      _trades.clear();
      for (var tradeMap in jsonList) {
        _trades.add(Trade.fromMap(tradeMap));
      }
      if (_trades.isNotEmpty) {
        _nextId =
            _trades.map((t) => t.id ?? 0).reduce((a, b) => a > b ? a : b) + 1;
      }
      _tradesStream.add(_trades);
      notifyListeners();
    }
  }

  /// Saves the current list of trades to persistent storage (trades.json).
  Future<void> saveToJson() async {
    final file = await _getTradeFile();
    final tradeList = _trades.map((t) => t.toMap()).toList();
    final jsonContents = jsonEncode(tradeList);
    await file.writeAsString(jsonContents);
  }

  /// Returns a list of trades for the currently active account.
  List<Trade> get tradesForActiveAccount {
    final activeAccountId = AccountService.instance.activeAccount?.id;
    if (activeAccountId == null) return [];
    return _trades.where((t) => t.accountId == activeAccountId).toList();
  }
}
