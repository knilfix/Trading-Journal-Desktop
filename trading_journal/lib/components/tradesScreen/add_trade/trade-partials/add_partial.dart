import 'package:flutter/material.dart';
import 'package:trading_journal/models/trade_partials.dart';

class AddPartialDialog extends StatefulWidget {
  final double remainingRisk;
  final Function(TradePartial) onAdd;

  const AddPartialDialog({
    super.key,
    required this.remainingRisk,
    required this.onAdd,
  });

  @override
  State<AddPartialDialog> createState() => _AddPartialDialogState();
}

class _AddPartialDialogState extends State<AddPartialDialog> {
  final _formKey = GlobalKey<FormState>();
  late double _riskPercentage;
  double _riskReward = 4.0;
  TradeOutcome _outcome = TradeOutcome.breakeven;

  @override
  void initState() {
    super.initState();
    _riskPercentage = (widget.remainingRisk * 0.5).clamp(
      1,
      widget.remainingRisk,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add Trade Partial"),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Slider(
              value: _riskPercentage,
              min: 1,
              max: widget.remainingRisk,
              divisions: widget.remainingRisk.toInt(),
              label: "${_riskPercentage.round()}%",
              onChanged: (value) {
                final clampedValue = value.clamp(1, widget.remainingRisk);
                setState(() => _riskPercentage = clampedValue.toDouble());
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              initialValue: _riskReward.toString(),
              decoration: const InputDecoration(
                labelText: "Risk:Reward Ratio",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                final rr = double.tryParse(value ?? "");
                return rr == null || rr <= 0 ? "Enter positive number" : null;
              },
              onChanged: (value) {
                final rr = double.tryParse(value);
                if (rr != null) _riskReward = rr;
              },
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<TradeOutcome>(
              value: _outcome,
              items: TradeOutcome.values.map((outcome) {
                return DropdownMenuItem(
                  value: outcome,
                  child: Text(outcome.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) => setState(() => _outcome = value!),
              decoration: const InputDecoration(
                labelText: "Outcome",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onAdd(
                TradePartial(
                  // Call the callback first
                  riskPercentage: _riskPercentage,
                  riskRewardRatio: _riskReward,
                  outcome: _outcome,
                ),
              );
              Navigator.pop(context); // Then close dialog
            }
          },
          child: const Text("Add"),
        ),
      ],
    );
  }
}
