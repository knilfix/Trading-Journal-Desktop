import 'package:flutter/material.dart';
import 'package:trading_journal/components/tradesScreen/add_trade/trade-partials/add_partial.dart';
import 'package:trading_journal/components/tradesScreen/add_trade/trade-partials/partials_table.dart';
import 'package:trading_journal/components/tradesScreen/add_trade/trade-partials/trade_partials_manager.dart';
import 'package:trading_journal/models/trade_partials.dart';

class TradePartialModal extends StatefulWidget {
  final TextEditingController riskController;
  final TextEditingController pnlController;

  const TradePartialModal({
    super.key,
    required this.riskController,
    required this.pnlController,
  });

  @override
  State<TradePartialModal> createState() => _TradePartialModalState();
}

class _TradePartialModalState extends State<TradePartialModal> {
  late final TradePartialsManager _manager;

  @override
  void initState() {
    super.initState();
    _manager = TradePartialsManager();
    _updateRisk();
    widget.riskController.addListener(_updateRisk);

    //listerner to rebuild when partials change
    _manager.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    widget.riskController.removeListener(_updateRisk);
    _manager.dispose();
    super.dispose();
  }

  void _updateRisk() {
    final risk = double.tryParse(widget.riskController.text) ?? 0;
    _manager.updateTotalRisk(risk);
  }

  Future<void> _showAddPartialDialog() async {
    final partial = await showDialog<TradePartial>(
      context: context,
      builder: (_) => AddPartialDialog(
        remainingRisk: _manager.remainingRiskPercentage,
        onAdd: (partial) => _manager.addPartial(partial),
      ),
    );

    if (partial != null) {
      _manager.addPartial(partial);
    }
  }

  void _applyPnl() {
    widget.pnlController.text = _manager.calculateTotalPnl().toStringAsFixed(2);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Manage Partial Positions"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Risk Amount: \$${_manager.totalRisk.toStringAsFixed(2)}",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              "Remaining Risk: ${_manager.remainingRiskPercentage.toStringAsFixed(1)}%",
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            if (_manager.partials.isEmpty)
              const Text("No partial positions added")
            else
              PartialsTable(
                partials: _manager.partials,
                totalRisk: _manager.totalRisk,
                onRemove: _manager.removePartial,
              ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.add, size: 18),
              label: const Text("Add Partial"),
              onPressed: _manager.remainingRiskPercentage > 0
                  ? _showAddPartialDialog
                  : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(onPressed: _applyPnl, child: const Text("Apply P&L")),
      ],
    );
  }
}
