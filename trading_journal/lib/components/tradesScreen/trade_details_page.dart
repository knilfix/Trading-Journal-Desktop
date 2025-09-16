import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trading_journal/models/trade.dart';
import 'package:trading_journal/services/trade_screenshot_service.dart';
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
    final colorScheme = theme.colorScheme;

    if (trade == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Trade Not Found')),
        body: const Center(child: Text('Trade not found')),
      );
    }

    final isProfit = trade.pnl >= 0;
    final directionColor = trade.direction == TradeDirection.buy
        ? Colors.green[400]
        : Colors.red[400];

    return Scaffold(
      appBar: AppBar(
        title: Text('Trade #${trade.id}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _confirmDeleteTrade(context, trade),
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Trade Summary Card
            _buildSummaryCard(context, trade, isProfit),

            const SizedBox(height: 6),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column - Execution Details and Metrics
                Expanded(
                  child: Column(
                    children: [
                      _buildSectionCard(
                        context,
                        title: 'Execution Details',
                        icon: Icons.timeline,
                        iconColor: colorScheme.primary,
                        children: [
                          _buildDetailItem(
                            context,
                            label: 'Currency Pair',
                            value: trade.currencyPair.symbol,
                            icon: Icons.currency_exchange,
                            iconColor: Colors.blue[400],
                          ),
                          _buildDetailItem(
                            context,
                            label: 'Direction',
                            value: trade.direction
                                .toString()
                                .split('.')
                                .last
                                .toUpperCase(),
                            icon: trade.direction == TradeDirection.buy
                                ? Icons.trending_up
                                : Icons.trending_down,
                            iconColor: directionColor,
                            valueColor: directionColor,
                            isBold: true,
                          ),
                          _buildDetailItem(
                            context,
                            label: 'Entry Time',
                            value: _formatDateTime(trade.entryTime),
                            icon: Icons.login,
                            iconColor: Colors.orange[400],
                          ),
                          _buildDetailItem(
                            context,
                            label: 'Exit Time',
                            value: _formatDateTime(trade.exitTime),
                            icon: Icons.logout,
                            iconColor: Colors.orange[400],
                          ),
                          _buildDetailItem(
                            context,
                            label: 'Duration',
                            value: _formatDuration(trade.duration),
                            icon: Icons.timer,
                            iconColor: Colors.purple[400],
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      _buildSectionCard(
                        context,
                        title: 'Performance Metrics',
                        icon: Icons.assessment,
                        iconColor: colorScheme.primary,
                        children: [
                          _buildDetailItem(
                            context,
                            label: 'Risk Amount',
                            value: '\$${trade.riskAmount.toStringAsFixed(2)}',
                            icon: Icons.money_off,
                            iconColor: Colors.amber[600],
                          ),
                          _buildDetailItem(
                            context,
                            label: 'P&L',
                            value: '\$${trade.pnl.toStringAsFixed(2)}',
                            icon: Icons.monetization_on,
                            iconColor: isProfit
                                ? Colors.green[400]
                                : Colors.red[400],
                            valueColor: isProfit
                                ? Colors.green[400]
                                : Colors.red[400],
                            isBold: true,
                          ),
                          _buildDetailItem(
                            context,
                            label: 'Risk:Reward',
                            value:
                                '1:${trade.riskRewardRatio.abs().toStringAsFixed(2)}',
                            icon: Icons.compare_arrows,
                            iconColor: Colors.blueGrey[400],
                          ),
                          _buildDetailItem(
                            context,
                            label: 'Post-Trade Balance',
                            value:
                                '\$${trade.postTradeBalance.toStringAsFixed(2)}',
                            icon: Icons.account_balance_wallet,
                            iconColor: Colors.teal[400],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // Right Column - Notes and Screenshot
                Expanded(
                  child: Column(
                    children: [
                      // Screenshot Card (always shown)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.camera_alt,
                                    color: colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Trade Screenshot',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const Divider(height: 8),
                              SizedBox(
                                height: 280, // Fixed height
                                child: Center(
                                  child: trade.screenshotPath.isNotEmpty
                                      ? FutureBuilder<File?>(
                                          future:
                                              TradeScreenshotService.getScreenshotForTrade(
                                                trade,
                                              ),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return const CircularProgressIndicator();
                                            }
                                            if (snapshot.hasError ||
                                                !snapshot.hasData) {
                                              return Text(
                                                'Error loading image',
                                                style: theme
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      color: theme
                                                          .colorScheme
                                                          .error,
                                                    ),
                                              );
                                            }
                                            return InteractiveViewer(
                                              minScale: 0.5,
                                              maxScale: 4.0,
                                              child: Image.file(
                                                snapshot.data!,
                                                fit: BoxFit.contain,
                                              ),
                                            );
                                          },
                                        )
                                      : Text(
                                          'No Screenshot',
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                color: theme.disabledColor,
                                              ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 6),
                      // In your right Column where the notes section is:
                      _buildSectionCard(
                        context,
                        title: 'Trade Notes',
                        icon: Icons.notes,
                        iconColor: colorScheme.primary,
                        children: [
                          SizedBox(
                            height: 85,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: Text(
                                trade.notes?.isNotEmpty == true
                                    ? trade.notes!
                                    : 'No Note',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: trade.notes?.isNotEmpty == true
                                      ? theme.textTheme.bodyLarge?.color
                                      : theme.disabledColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, Trade trade, bool isProfit) {
    final theme = Theme.of(context);

    final directionColor = trade.direction == TradeDirection.buy
        ? Colors.green[400]
        : Colors.red[400];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  trade.currencyPair.symbol,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: directionColor?.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        trade.direction == TradeDirection.buy
                            ? Icons.trending_up
                            : Icons.trending_down,
                        size: 16,
                        color: directionColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        trade.direction
                            .toString()
                            .split('.')
                            .last
                            .toUpperCase(),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: directionColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '\$${trade.pnl.toStringAsFixed(2)}',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: isProfit ? Colors.green[400] : Colors.red[400],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatDateTime(trade.entryTime),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.disabledColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
    Color? iconColor,
  }) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: iconColor ?? theme.iconTheme.color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
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
    Color? iconColor,
    Color? valueColor,
    bool isBold = false,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: iconColor ?? theme.iconTheme.color),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: valueColor ?? theme.textTheme.bodyMedium?.color,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy - HH:mm').format(dateTime);
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 24) {
      return '${duration.inDays}d ${duration.inHours.remainder(24)}h';
    } else if (duration.inMinutes > 60) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    } else if (duration.inSeconds > 60) {
      return '${duration.inMinutes}m';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  void _confirmDeleteTrade(BuildContext context, Trade trade) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Trade'),
        content: const Text('Are you sure you want to delete this trade?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<TradeService>(
                context,
                listen: false,
              ).deleteTrade(trade.id!);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
