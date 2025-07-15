import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/trade.dart';
import 'trade_utils.dart';

class TradeDayModal extends StatelessWidget {
  final List<Trade> trades;
  final DateTime date;

  const TradeDayModal({
    super.key,
    required this.trades,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: MediaQuery.of(context).size.width * 0.3,
      height:
          MediaQuery.of(context).size.height *
          0.4, // Reduced height for compactness
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: trades.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 36, // Smaller icon for minimalistic look
                    color: theme.colorScheme.onSurface.withOpacity(
                      0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No Trades on ${DateFormat('MMM d').format(date)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(
                        0.7,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.show_chart,
                        color: theme.colorScheme.primary,
                        size: 20, // Smaller icon
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${DateFormat('MMM d').format(date)} (${trades.length})',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 1,
                  color: theme.dividerColor.withOpacity(0.3),
                ),
                Expanded(
                  child: ListView.separated(
                    itemCount: trades.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      color: theme.dividerColor.withOpacity(0.2),
                    ),
                    itemBuilder: (context, index) {
                      final trade = trades[index];
                      return ListTile(
                        leading: CircleAvatar(
                          radius: 12, // Smaller avatar
                          backgroundColor: theme.colorScheme.primary
                              .withOpacity(0.8),
                          child: Text(
                            "${index + 1}",
                            style: TextStyle(
                              color: theme.colorScheme.onPrimary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              trade.currencyPair.symbol,
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color:
                                        theme.colorScheme.onSurface,
                                  ),
                            ),
                            Text.rich(
                              TextSpan(
                                children: [
                                  const TextSpan(
                                    text: 'PnL: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: trade.pnlText,
                                    style: TextStyle(
                                      color: trade.pnlColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const TextSpan(
                                    text: '  •  Duration: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: trade.tradeDuration,
                                    style: TextStyle(
                                      color: Colors
                                          .blue, // Blue for duration value
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              style: theme.textTheme.bodySmall
                                  ?.copyWith(
                                    fontSize: 11,
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.7),
                                  ),
                            ),
                          ],
                        ),
                        trailing: Icon(
                          trade.direction == TradeDirection.buy
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          size: 18,
                          color: trade.direction == TradeDirection.buy
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                        ),
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4, // Tighter padding
                        ),
                        minLeadingWidth: 24,
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
