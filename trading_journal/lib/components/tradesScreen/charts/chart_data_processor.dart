import 'package:flutter/material.dart';
import 'package:trading_journal/services/account_service.dart';
import 'package:trading_journal/services/trade_service.dart';
import '../../../models/trade.dart';

class ChartDataProcessor extends ChangeNotifier {
  final AccountService accountService;
  final TradeService tradeService;
  List<Trade> _trades = [];

  ChartDataProcessor({
    required this.accountService,
    required this.tradeService,
  }) {
    accountService.addListener(_onDataChanged);
    tradeService.addListener(_onDataChanged);
    _updateTrades();
  }

  void _onDataChanged() {
    _updateTrades();
  }

  void _updateTrades() {
    final account = accountService.activeAccount;
    if (account != null) {
      _trades = tradeService.getTradesForAccount(account.id);
    } else {
      _trades = [];
    }
    notifyListeners();
  }

  List<Trade> get trades => List.unmodifiable(_trades);

  @override
  void dispose() {
    accountService.removeListener(_onDataChanged);
    tradeService.removeListener(_onDataChanged);
    super.dispose();
  }
}
