import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trading_journal/models/trade.dart';
import 'package:trading_journal/services/trade_service.dart';

class TradeDetailsPage extends StatelessWidget {
  final int tradeId;

  const TradeDetailsPage({super.key, required this.tradeId});

  @override
  Widget build(BuildContext context) {
    final tradeService = Provider.of<TradeService>(context);
    final trade = tradeService.getTradeById(tradeId);

    if (trade == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Trade Not Found')),
        body: const Center(child: Text('Trade not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Trade #${trade.id}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDeleteTrade(context, trade),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailCard(
              context,
              title: 'Basic Info',
              children: [
                _buildDetailRow('Currency Pair', trade.currencyPair.symbol),
                _buildDetailRow(
                  'Direction',
                  trade.direction.toString().split('.').last,
                ),
                _buildDetailRow('Entry Time', _formatDateTime(trade.entryTime)),
                _buildDetailRow('Exit Time', _formatDateTime(trade.exitTime)),
                _buildDetailRow(
                  'Duration',
                  trade.duration.toString().split('.').first,
                ),
              ],
            ),

            const SizedBox(height: 16),

            _buildDetailCard(
              context,
              title: 'Performance',
              children: [
                _buildDetailRow(
                  'Risk Amount',
                  '\$${trade.riskAmount.toStringAsFixed(2)}',
                ),
                _buildDetailRow(
                  'P&L',
                  '\$${trade.pnl.toStringAsFixed(2)}',
                  color: trade.pnl >= 0 ? Colors.green : Colors.red,
                ),
                _buildDetailRow(
                  'Risk:Reward',
                  '1:${trade.riskRewardRatio.abs().toStringAsFixed(2)}',
                ),
                _buildDetailRow(
                  'Account Balance',
                  '\$${trade.postTradeBalance.toStringAsFixed(2)}',
                ),
              ],
            ),

            const SizedBox(height: 16),

            if (trade.notes != null && trade.notes!.isNotEmpty)
              _buildDetailCard(
                context,
                title: 'Notes',
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(trade.notes!),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(fontWeight: FontWeight.w500, color: color),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _confirmDeleteTrade(BuildContext context, Trade trade) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Trade?'),
        content: Text('Are you sure you want to delete trade #${trade.id}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await Provider.of<TradeService>(
        context,
        listen: false,
      ).deleteTrade(trade.id!);

      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trade deleted successfully')),
        );
        Navigator.pop(context);
      }
    }
  }
}
