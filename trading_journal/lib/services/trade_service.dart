// lib/services/trade_service.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:trading_journal/models/trade.dart';
import 'package:trading_journal/services/account_service.dart';
import 'package:trading_journal/services/trade_screenshot_service.dart';
import 'package:trading_journal/models/trade_screenshot.dart';

/// Service for managing trades, including CRUD operations, persistence, and reactive updates for the active account.
class TradeService extends ChangeNotifier {
  TradeService._internal() {
    loadFromJson();
  }

  static final TradeService instance = TradeService._internal();

  static const String _tradeFileName = 'trades.json';
  int _nextId = 1;
  final List<Trade> _trades = [];
  final StreamController<List<Trade>> _tradesStream =
      StreamController.broadcast();

  List<Trade> get trades => List.unmodifiable(_trades);
  Stream<List<Trade>> get tradesStream => _tradesStream.stream;
  Trade? getTradeById(int tradeId) {
    try {
      return _trades.firstWhere((trade) => trade.id == tradeId);
    } catch (e) {
      return null;
    }
  }

  /// Records a new trade, saves multiple optional screenshots, updates account balance, and persists the change.
  Future<Trade?> recordTrade({
    required int accountId,
    required CurrencyPair currencyPair,
    required TradeDirection direction,
    required double riskAmount,
    required double pnl,
    required DateTime entryTime,
    required DateTime exitTime,
    String? notes,
    List<TradeScreenshot>? screenshots, // The new list parameter
  }) async {
    assert(exitTime.isAfter(entryTime), "Exit time must be after entry time");

    try {
      // 1. Handle screenshots - Loop through the new list
      final List<Map<String, String>> savedScreenshots = [];
      if (screenshots != null) {
        for (var screenshot in screenshots) {
          final path = await TradeScreenshotService.saveScreenshot(
            screenshot.file,
            _nextId,
            timeframe: screenshot.timeframe,
          );
          if (path != null) {
            savedScreenshots.add({
              'path': path,
              'timeframe': screenshot.timeframe,
            });
          }
        }
      }

      // 2. Proceed with trade creation
      final account = AccountService.instance.getAccountById(accountId);
      if (account == null) return null;

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
        screenshots: savedScreenshots, // Use the new list here
      );

      _trades.add(trade);
      await saveToJson();
      _tradesStream.add(_trades);
      notifyListeners();

      return trade;
    } catch (e) {
      debugPrint('[EXCEPTION] Error recording trade: $e');
      return null;
    }
  }

  /// Deletes the trade, associated screenshots, and adjusts the account's balance.
  Future<bool> deleteTrade(int tradeId) async {
    try {
      final tradeIndex = _trades.indexWhere((t) => t.id == tradeId);
      if (tradeIndex == -1) return false;
      final tradeToDelete = _trades[tradeIndex];

      // 2. Delete all associated screenshots
      for (var screenshot in tradeToDelete.screenshots) {
        await TradeScreenshotService.deleteScreenshot(screenshot['path']!);
      }

      // 3. Get the associated account
      final account = AccountService.instance.getAccountById(
        tradeToDelete.accountId,
      );
      if (account == null) return false;

      final newBalance = account.balance - tradeToDelete.pnl;
      final updatedAccount = await AccountService.instance.updateAccountBalance(
        tradeToDelete.accountId,
        newBalance,
      );
      if (updatedAccount == null) return false;

      // 6. Remove the trade
      _trades.removeAt(tradeIndex);
      await saveToJson();

      _tradesStream.add(_trades);
      notifyListeners();

      return true;
    } catch (e) {
      debugPrint('[EXCEPTION] Error deleting trade: $e');
      return false;
    }
  }

  // ... (rest of the methods are unchanged)
  List<Trade> getTradesForAccount(int accountId) {
    return _trades.where((t) => t.accountId == accountId).toList();
  }

  Future<List<Trade>> getTradesForAccountAsync(int accountId) async {
    return getTradesForAccount(accountId);
  }

  void clearAccountTrades(int accountId) {
    _trades.removeWhere((trade) => trade.accountId == accountId);
    saveToJson();
    notifyListeners();
  }

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

  Future<void> saveToJson() async {
    final file = await _getTradeFile();
    final tradeList = _trades.map((t) => t.toMap()).toList();
    final jsonContents = jsonEncode(tradeList);
    await file.writeAsString(jsonContents);
  }

  List<Trade> get tradesForActiveAccount {
    final activeAccountId = AccountService.instance.activeAccount?.id;
    if (activeAccountId == null) return [];
    return _trades.where((t) => t.accountId == activeAccountId).toList();
  }

  Future<File> _getTradeFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final appDir = Directory('${directory.path}/TradingJournal');
    if (!await appDir.exists()) {
      await appDir.create(recursive: true);
    }
    return File('${appDir.path}/$_tradeFileName');
  }
}

// NOTE: TradeScreenshotService.deleteScreenshot must be updated to handle a single file path
// as opposed to a trade ID.
