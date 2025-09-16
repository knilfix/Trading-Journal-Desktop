import 'package:flutter/widgets.dart';
import 'package:trading_journal/components/analytics/performance_calculator.dart';
import 'package:trading_journal/components/analytics/profit_loss_calculator.dart';
import 'package:trading_journal/components/analytics/trade_quality_calculator.dart';
import 'package:trading_journal/models/performance_metrics.dart';
import 'package:trading_journal/models/profit_loss_data.dart'; // Import the new data model
import 'package:trading_journal/models/trade_quality_data.dart';
import 'package:trading_journal/services/account_service.dart';
import 'package:trading_journal/services/trade_service.dart';

class TradeDataProcessor with ChangeNotifier {
  final _accountService = AccountService.instance;
  final _tradeService = TradeService.instance;

  PerformanceMetrics? _performanceMetrics;
  PerformanceMetrics? get performanceMetrics => _performanceMetrics;

  // 1. Add private field for ProfitLossData
  ProfitLossData? _profitLossData;

  // 2. Add public getter for ProfitLossData
  ProfitLossData? get profitLossData => _profitLossData;

  TradeQualityData? _tradeQualityData;
  TradeQualityData? get tradeQualityData => _tradeQualityData;

  TradeDataProcessor() {
    _accountService.addListener(_processData);
    _tradeService.addListener(_processData);
    _processData();
  }

  @override
  void dispose() {
    _accountService.removeListener(_processData);
    _tradeService.removeListener(_processData);
    super.dispose();
  }

  void _processData() {
    final activeAccount = _accountService.activeAccount;
    if (activeAccount == null) {
      _performanceMetrics = null;
      _profitLossData = null; // Also clear profit/loss data
      _tradeQualityData = null;
      notifyListeners();
      return;
    }

    final trades = _tradeService.getTradesForAccount(activeAccount.id);
    if (trades.isEmpty) {
      _performanceMetrics = null;
      _profitLossData = null;
      _tradeQualityData = null;
      notifyListeners();
      return;
    }

    // Delegate the calculations to the dedicated calculators
    final performanceCalculator = PerformanceCalculator();
    _performanceMetrics = performanceCalculator.calculate(
      trades,
      activeAccount,
    );

    final profitLossCalculator = ProfitLossCalculator();
    // Store the calculated data in the new field
    _profitLossData = profitLossCalculator.calculate(trades);

    final tradeQualityCalculator = TradeQualityCalculator();
    _tradeQualityData = tradeQualityCalculator.calculate(trades);

    notifyListeners();
  }
}
