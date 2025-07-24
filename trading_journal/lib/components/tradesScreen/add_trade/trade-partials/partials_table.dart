import 'package:flutter/material.dart';
import 'package:trading_journal/models/trade_partials.dart';

class PartialsTable extends StatelessWidget {
  final List<TradePartial> partials;
  final double totalRisk;
  final Function(String) onRemove;

  const PartialsTable({
    super.key,
    required this.partials,
    required this.totalRisk,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder.all(
        color: Theme.of(context).dividerColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      columnWidths: const {
        0: FixedColumnWidth(64),
        1: FixedColumnWidth(64),
        2: FixedColumnWidth(84),
        3: FixedColumnWidth(84),
        4: FixedColumnWidth(48),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          children: [
            _buildHeaderCell(context, "%"),
            _buildHeaderCell(context, "R:R"),
            _buildHeaderCell(context, "Outcome"),
            _buildHeaderCell(context, "P&L"),
            _buildHeaderCell(context, ""),
          ],
        ),
        ...partials.map((partial) {
          final pnl = partial.calculatePnl(totalRisk);
          return TableRow(
            children: [
              _buildCell("${partial.riskPercentage.toStringAsFixed(0)}%"),
              _buildCell(partial.riskRewardRatio.toStringAsFixed(1)),
              _buildCell(partial.outcome.name.toUpperCase()),
              _buildCell(
                "${pnl >= 0 ? '+' : ''}${pnl.toStringAsFixed(2)}",
                color: pnl > 0
                    ? Colors.green
                    : pnl < 0
                    ? Colors.red
                    : null,
              ),
              IconButton(
                icon: Icon(Icons.delete, size: 18),
                onPressed: () => onRemove(partial.id!),
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildHeaderCell(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildCell(String text, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Text(
        text,
        style: TextStyle(color: color),
        textAlign: TextAlign.center,
      ),
    );
  }
}
