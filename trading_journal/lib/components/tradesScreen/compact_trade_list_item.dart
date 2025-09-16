import 'package:flutter/material.dart';
import 'package:trading_journal/components/tradesScreen/trade_details/trade_details_page.dart';
import 'package:trading_journal/models/trade.dart';

class CompactTradeListItem extends StatelessWidget {
  final Trade trade;
  final double balanceAfterTrade;
  final double initialBalance;
  final bool isLastItem;

  const CompactTradeListItem({
    required this.trade,
    required this.balanceAfterTrade,
    required this.initialBalance,
    this.isLastItem = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final bool isProfit = trade.pnl >= 0;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final balanceColor = balanceAfterTrade > initialBalance
        ? Colors.green[400]
        : balanceAfterTrade < initialBalance
        ? Colors.red[400]
        : Colors.grey[400];
    final notes = trade.notes;

    return InkWell(
      borderRadius: BorderRadius.circular(4),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TradeDetailsPage(tradeId: trade.id!),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        margin: EdgeInsets.only(bottom: isLastItem ? 8 : 0),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // First row: Pair, Direction, P&L
            Row(
              children: [
                // Direction icon
                Icon(
                  trade.direction == TradeDirection.buy
                      ? Icons.arrow_upward
                      : Icons.arrow_downward,
                  size: 16,
                  color: trade.direction == TradeDirection.buy
                      ? Colors.green[400]
                      : Colors.red[400],
                ),
                const SizedBox(width: 6),
                // Currency pair
                Expanded(
                  child: Text(
                    trade.currencyPair.symbol,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                // P&L
                Row(
                  children: [
                    Icon(
                      isProfit ? Icons.trending_up : Icons.trending_down,
                      size: 16,
                      color: isProfit ? Colors.green[400] : Colors.red[400],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '\$${trade.pnl.abs().toStringAsFixed(2)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isProfit ? Colors.green[400] : Colors.red[400],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 2),
            // Second row: Risk, R:R, Duration, Balance
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Risk
                Row(
                  children: [
                    Icon(
                      Icons.warning_amber_outlined,
                      size: 14,
                      color: Colors.amber[300],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '\$${trade.riskAmount.toStringAsFixed(2)}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.amber[300],
                      ),
                    ),
                  ],
                ),

                // R:R
                Row(
                  children: [
                    Icon(Icons.balance, size: 14, color: Colors.blue[300]),
                    const SizedBox(width: 4),
                    Text(
                      trade.riskRewardRatio.toStringAsFixed(1),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.blue[300],
                      ),
                    ),
                  ],
                ),

                // Duration
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey[400]),
                    const SizedBox(width: 4),
                    Text(
                      _formatDuration(trade.duration),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),

                SizedBox(
                  width: 20,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Show notes icon if notes exist
                      if (notes?.isNotEmpty ?? false)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Icon(
                            Icons.notes,
                            size: 14,
                            color: Theme.of(
                              context,
                            ).colorScheme.secondary.withAlpha(252),
                          ),
                        ),

                      // Show screenshot icon if screenshot exists
                      if (trade.screenshots.isNotEmpty)
                        Icon(
                          Icons.camera_alt,
                          size: 14,
                          color: Theme.of(
                            context,
                          ).colorScheme.secondary.withAlpha(252),
                        ),
                    ],
                  ),
                ),

                // Balance
                Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 14,
                      color: balanceColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '\$${balanceAfterTrade.toStringAsFixed(2)}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: balanceColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours.remainder(24)}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m';
    } else {
      return '${duration.inSeconds}s';
    }
  }
}
