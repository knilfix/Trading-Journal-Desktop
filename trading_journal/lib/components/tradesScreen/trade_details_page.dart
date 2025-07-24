import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trading_journal/models/trade.dart';
import 'package:trading_journal/services/trade_service.dart';
import 'package:intl/intl.dart';

class TradeDetailsPage extends StatelessWidget {
  final int tradeId;

  const TradeDetailsPage({super.key, required this.tradeId});

  @override
  Widget build(BuildContext context) {
    final tradeService = Provider.of<TradeService>(context);
    final trade = tradeService.getTradeById(tradeId);
    final theme = Theme.of(context);
    final isProfit = trade != null && trade.pnl >= 0;

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
          children: [
            // Trade Summary Card
            _buildSummaryCard(context, trade, isProfit),

            const SizedBox(height: 20),

            // Trade Execution Details
            _buildSectionCard(
              context,
              title: 'Execution Details',
              icon: Icons.timeline,
              children: [
                _buildDetailItem(
                  context,
                  label: 'Currency Pair',
                  value: trade.currencyPair.symbol,
                  icon: Icons.currency_exchange,
                ),
                _buildDetailItem(
                  context,
                  label: 'Direction',
                  value: trade.direction.toString().split('.').last,
                  icon: trade.direction == TradeDirection.buy
                      ? Icons.trending_up
                      : Icons.trending_down,
                  valueColor: trade.direction == TradeDirection.buy
                      ? Colors.green
                      : Colors.red,
                ),
                _buildDetailItem(
                  context,
                  label: 'Entry Time',
                  value: _formatDateTime(trade.entryTime),
                  icon: Icons.login,
                ),
                _buildDetailItem(
                  context,
                  label: 'Exit Time',
                  value: _formatDateTime(trade.exitTime),
                  icon: Icons.logout,
                ),
                _buildDetailItem(
                  context,
                  label: 'Duration',
                  value: trade.duration.toString().split('.').first,
                  icon: Icons.timer,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Performance Metrics
            _buildSectionCard(
              context,
              title: 'Performance Metrics',
              icon: Icons.assessment,
              children: [
                _buildDetailItem(
                  context,
                  label: 'Risk Amount',
                  value: '\$${trade.riskAmount.toStringAsFixed(2)}',
                  icon: Icons.money_off,
                ),
                _buildDetailItem(
                  context,
                  label: 'P&L',
                  value: '\$${trade.pnl.toStringAsFixed(2)}',
                  icon: Icons.monetization_on,
                  valueColor: isProfit ? Colors.green : Colors.red,
                  isHighlighted: true,
                ),
                _buildDetailItem(
                  context,
                  label: 'Risk:Reward',
                  value: '1:${trade.riskRewardRatio.abs().toStringAsFixed(2)}',
                  icon: Icons.compare_arrows,
                ),
                _buildDetailItem(
                  context,
                  label: 'Post-Trade Balance',
                  value: '\$${trade.postTradeBalance.toStringAsFixed(2)}',
                  icon: Icons.account_balance_wallet,
                ),
              ],
            ),

            if (trade.notes != null && trade.notes!.isNotEmpty) ...[
              const SizedBox(height: 20),
              _buildSectionCard(
                context,
                title: 'Trade Notes',
                icon: Icons.notes,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Text(trade.notes!, style: theme.textTheme.bodyLarge),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, Trade trade, bool isProfit) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trade.currencyPair.symbol,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      trade.direction.toString().split('.').last,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: trade.direction == TradeDirection.buy
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isProfit
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '\$${trade.pnl.toStringAsFixed(2)}',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: isProfit ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryStat(
                  context,
                  label: 'Risk',
                  value: '\$${trade.riskAmount.toStringAsFixed(2)}',
                  icon: Icons.warning,
                ),
                _buildSummaryStat(
                  context,
                  label: 'R:R',
                  value: '1:${trade.riskRewardRatio.abs().toStringAsFixed(2)}',
                  icon: Icons.compare,
                ),
                _buildSummaryStat(
                  context,
                  label: 'Duration',
                  value: trade.duration.toString().split('.').first,
                  icon: Icons.timer,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryStat(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    Color? valueColor,
    bool isHighlighted = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: valueColor,
                fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy - HH:mm').format(dateTime);
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
          SnackBar(
            content: const Text('Trade deleted successfully'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        Navigator.pop(context);
      }
    }
  }
}
