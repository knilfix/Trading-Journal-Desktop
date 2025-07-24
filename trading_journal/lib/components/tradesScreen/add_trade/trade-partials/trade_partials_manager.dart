import 'package:flutter/material.dart';
import 'package:trading_journal/models/trade_partials.dart';

class TradePartialsManager extends ChangeNotifier {
  final List<TradePartial> _partials = [];
  double _totalRisk = 0;

  List<TradePartial> get partials => _partials;
  double get remainingRiskPercentage => 100 - usedRiskPercentage;
  double get totalRisk => _totalRisk;
  double get usedRiskPercentage =>
      _partials.fold(0, (sum, p) => sum + p.riskPercentage);

  void updateTotalRisk(double risk) {
    _totalRisk = risk;
    notifyListeners();
  }

  String? validateNewPartial(double riskPercentage) {
    if (riskPercentage <= 0) return "Must be positive";
    if (riskPercentage > remainingRiskPercentage) {
      return "Only ${remainingRiskPercentage.toStringAsFixed(1)}% remaining";
    }
    return null;
  }

  void addPartial(TradePartial partial) {
    debugPrint(
      '[PartialManager] Adding partial: '
      '${partial.riskPercentage}% at R:R ${partial.riskRewardRatio} '
      '(Outcome: ${partial.outcome})',
    );

    _partials.add(partial);
    notifyListeners();

    debugPrint('[PartialManager] New partials count: ${_partials.length}');
    debugPrint('[PartialManager] Remaining risk: $remainingRiskPercentage%');
  }

  void removePartial(String id) {
    debugPrint('[PartialManager] Removing partial ID: $id');
    _partials.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  double calculateTotalPnl() {
    double total = _partials.fold(
      0,
      (sum, p) => sum + p.calculatePnl(_totalRisk),
    );
    debugPrint(
      '[PartialManager] Calculated Total P&L: \$${total.toStringAsFixed(2)}',
    );

    return total;
  }
}
