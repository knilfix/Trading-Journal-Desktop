import 'package:flutter/material.dart';
import 'package:trading_journal/components/tradesScreen/charts/profit_and_loss.dart';
import '../../services/account_service.dart';
import '../../services/trade_service.dart';
import '../../models/trade.dart';
import 'dart:math' as math;
import 'package:provider/provider.dart';

class AccountMetricsWidget extends StatelessWidget {
  const AccountMetricsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final activeAccount = AccountService.instance.activeAccount;
    final theme = Theme.of(context);
    final tradeService = Provider.of<TradeService>(context);

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(24),
        child: StreamBuilder<List<Trade>>(
          stream: tradeService.tradesStream,
          builder: (context, snapshot) {
            final trades = tradeService.getTradesForAccount(
              activeAccount?.id ?? 0,
            );
            final lastTrade = trades.isNotEmpty ? trades.last : null;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.analytics_outlined,
                        color: theme.primaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Performance Dashboard',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            activeAccount?.name ?? 'No Account Selected',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.textTheme.bodyMedium?.color
                                  ?.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Quick Stats
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: lastTrade?.isWin ?? false
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            lastTrade?.isWin ?? false
                                ? Icons.trending_up
                                : Icons.trending_down,
                            size: 14,
                            color: lastTrade?.isWin ?? false
                                ? Colors.green
                                : Colors.red,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Last Trade: ${lastTrade != null ? (lastTrade.isWin ? "Win" : "Loss") : "N/A"}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: lastTrade?.isWin ?? false
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                Consumer<AccountService>(
                  builder: (context, accountService, child) {
                    final activeAccount = accountService.activeAccount;
                    final activeAccountBalance = activeAccount?.balance ?? 0.0;
                    debugPrint(
                      'Account Metrics: Account Balance -> $activeAccountBalance | Account Name: ${activeAccount?.name}',
                    );
                    final trades = TradeService.instance.getTradesForAccount(
                      activeAccount?.id ?? 0,
                    );
                    final metrics = _calculateMetrics(trades);

                    return GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: _getGridColumns(context),
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: _getCardAspectRatio(context),
                      children: [
                        _buildModernMetricCard(
                          context,
                          title: 'Account Balance',
                          value: '\$${activeAccountBalance.toStringAsFixed(2)}',
                          icon: Icons.account_balance_wallet_outlined,
                          color: Colors.blue,
                          subtitle: 'Current equity',
                          trend: TrendType.neutral,
                        ),
                        _buildModernMetricCard(
                          context,
                          title: 'Win Rate',
                          value: '${metrics['winRate']}%',
                          icon: Icons.adjust_outlined,
                          color: Colors.green,
                          subtitle:
                              '${trades.where((t) => t.isWin).length}/${trades.length} trades',
                          trend: _getTrendForWinRate(metrics['winRate']),
                        ),
                        _buildModernMetricCard(
                          context,
                          title: 'Avg P&L',
                          value: '\$${metrics['avgPnl']}',
                          icon: Icons.trending_up_outlined,
                          color: double.parse(metrics['avgPnl']) >= 0
                              ? Colors.green
                              : Colors.red,
                          subtitle: 'Per trade',
                          trend: double.parse(metrics['avgPnl']) >= 0
                              ? TrendType.up
                              : TrendType.down,
                        ),
                        _buildModernMetricCard(
                          context,
                          title: 'Total P&L',
                          value: '\$${metrics['totalPnl']}',
                          icon: Icons.payments_outlined,
                          color: double.parse(metrics['totalPnl']) >= 0
                              ? Colors.green
                              : Colors.red,
                          subtitle: 'All trades',
                          trend: double.parse(metrics['totalPnl']) >= 0
                              ? TrendType.up
                              : TrendType.down,
                        ),
                        _buildModernMetricCard(
                          context,
                          title: 'Win Streak',
                          value: '${metrics['winStreak']}',
                          icon: Icons.whatshot_outlined,
                          color: Colors.orange,
                          subtitle: 'Best run',
                          trend: TrendType.neutral,
                        ),
                        _buildModernMetricCard(
                          context,
                          title: 'Avg Duration',
                          value: metrics['avgDuration'],
                          icon: Icons.schedule_outlined,
                          color: Colors.purple,
                          subtitle: 'Hold time',
                          trend: TrendType.neutral,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 32),
                // Performance Chart Section
                ProfitLossChart(maxTradesToShow: 10),
              ],
            );
          },
        ),
      ),
    );
  }
}

Widget _buildModernMetricCard(
  BuildContext context, {
  required String title,
  required String value,
  required IconData icon,
  required Color color,
  required String subtitle,
  required TrendType trend,
}) {
  final theme = Theme.of(context);

  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.02),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const Spacer(),
            if (trend != TrendType.neutral)
              Icon(
                trend == TrendType.up
                    ? Icons.arrow_upward
                    : Icons.arrow_downward,
                size: 16,
                color: trend == TrendType.up ? Colors.green : Colors.red,
              ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          title,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
            fontSize: 11,
          ),
        ),
      ],
    ),
  );
}

int _getGridColumns(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  if (width > 1200) return 3;
  if (width > 800) return 2;
  return 1;
}

double _getCardAspectRatio(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  if (width > 1200) return 1.4;
  if (width > 800) return 1.3;
  return 1.2;
}

TrendType _getTrendForWinRate(int winRate) {
  if (winRate >= 60) return TrendType.up;
  if (winRate <= 40) return TrendType.down;
  return TrendType.neutral;
}

// Helper methods for mock data and calculations
Map<String, dynamic> _calculateMetrics(List<Trade> trades) {
  if (trades.isEmpty) {
    return {
      'winRate': 0,
      'avgPnl': '0.00',
      'totalPnl': '0.00',
      'avgDuration': '0h',
      'winStreak': 0,
      'lossStreak': 0,
    };
  }

  final wins = trades.where((t) => t.isWin).length;
  final totalPnl = trades.map((t) => t.pnl).reduce((a, b) => a + b);

  // Calculate streaks
  int currentWinStreak = 0;
  int maxWinStreak = 0;
  int currentLossStreak = 0;
  int maxLossStreak = 0;

  for (final trade in trades) {
    if (trade.isWin) {
      currentWinStreak++;
      maxWinStreak = math.max(maxWinStreak, currentWinStreak);
      currentLossStreak = 0;
    } else {
      currentLossStreak++;
      maxLossStreak = math.max(maxLossStreak, currentLossStreak);
      currentWinStreak = 0;
    }
  }

  return {
    'winRate': ((wins / trades.length) * 100).round(),
    'avgPnl': (totalPnl / trades.length).toStringAsFixed(2),
    'totalPnl': totalPnl.toStringAsFixed(2),
    'avgDuration':
        '${(trades.map((t) => t.duration.inMinutes).reduce((a, b) => a + b) / trades.length / 60).toStringAsFixed(1)}h',
    'winStreak': maxWinStreak,
    'lossStreak': maxLossStreak,
  };
}

// Helper enums and classes
enum TrendType { up, down, neutral }

class PnlData {
  final int tradeNumber;
  final double pnl;

  PnlData({required this.tradeNumber, required this.pnl});
}

extension TradeHelpers on Trade {
  bool get isWin => pnl > 0;
  Duration get duration => exitTime.difference(entryTime);
}
