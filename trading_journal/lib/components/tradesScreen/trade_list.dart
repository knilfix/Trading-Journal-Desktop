import 'package:flutter/material.dart';
import '../../models/trade.dart';
import '../../models/account.dart';
import '../../services/account_service.dart';

class TradeList extends StatefulWidget {
  final List<Trade> trades;
  final double initialBalance;
  final AccountType accountType;

  const TradeList({
    super.key,
    required this.trades,
    required this.initialBalance,
    required this.accountType,
  });

  @override
  State<TradeList> createState() => _TradeListState();
}

class _TradeListState extends State<TradeList> {
  late List<Trade> _sortedTrades;
  SortOption _currentSort = SortOption.dateNewestFirst;

  @override
  void initState() {
    super.initState();
    _sortedTrades = _sortTrades(widget.trades, _currentSort);
  }

  @override
  void didUpdateWidget(covariant TradeList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trades != widget.trades) {
      _sortedTrades = _sortTrades(widget.trades, _currentSort);
    }
  }

  List<Trade> _sortTrades(List<Trade> trades, SortOption sortOption) {
    final list = List<Trade>.from(trades);
    switch (sortOption) {
      case SortOption.dateNewestFirst:
        list.sort((a, b) => b.exitTime.compareTo(a.exitTime));
        break;
      case SortOption.dateOldestFirst:
        list.sort((a, b) => a.exitTime.compareTo(b.exitTime));
        break;
      case SortOption.pnlHighestFirst:
        list.sort((a, b) => b.pnl.compareTo(a.pnl));
        break;
      case SortOption.pnlLowestFirst:
        list.sort((a, b) => a.pnl.compareTo(b.pnl));
        break;
      case SortOption.buyTradesFirst:
        list.sort((a, b) => b.direction == TradeDirection.buy ? 1 : -1);
        break;
      case SortOption.sellTradesFirst:
        list.sort((a, b) => a.direction == TradeDirection.buy ? 1 : -1);
        break;
    }
    return list;
  }

  void _changeSort(SortOption newSort) {
    setState(() {
      _currentSort = newSort;
      _sortedTrades = _sortTrades(_sortedTrades, newSort);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.trades.isEmpty) {
      return const Center(
        child: Text(
          'No trades recorded yet',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
      );
    }

    final activeAccount = AccountService.instance.activeAccount;

    return Column(
      children: [
        // Account summary header
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Account Summary',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.accountType.displayName,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${widget.trades.length} ${widget.trades.length == 1 ? 'Trade' : 'Trades'}',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                      ),
                      Text(
                        'Balance: \$${activeAccount != null ? activeAccount.balance.toStringAsFixed(2) : '--'}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Sorting controls
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildSortChip(
                      context,
                      'Newest First',
                      _currentSort == SortOption.dateNewestFirst,
                      () => _changeSort(SortOption.dateNewestFirst),
                      Icons.access_time,
                    ),
                    _buildSortChip(
                      context,
                      'Oldest First',
                      _currentSort == SortOption.dateOldestFirst,
                      () => _changeSort(SortOption.dateOldestFirst),
                      Icons.access_time,
                    ),
                    _buildSortChip(
                      context,
                      'Profit',
                      _currentSort == SortOption.pnlHighestFirst,
                      () => _changeSort(SortOption.pnlHighestFirst),
                      Icons.trending_up,
                    ),
                    _buildSortChip(
                      context,
                      'Loss',
                      _currentSort == SortOption.pnlLowestFirst,
                      () => _changeSort(SortOption.pnlLowestFirst),
                      Icons.trending_down,
                    ),
                    _buildSortChip(
                      context,
                      'Buy Trades',
                      _currentSort == SortOption.buyTradesFirst,
                      () => _changeSort(SortOption.buyTradesFirst),
                      Icons.shopping_cart,
                    ),
                    _buildSortChip(
                      context,
                      'Sell Trades',
                      _currentSort == SortOption.sellTradesFirst,
                      () => _changeSort(SortOption.sellTradesFirst),
                      Icons.sell,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Trade list
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.only(bottom: 16),
            itemCount: _sortedTrades.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final trade = _sortedTrades[index];

              return CompactTradeListItem(
                trade: trade,
                balanceAfterTrade: trade.postTradeBalance,
                isLastItem: index == _sortedTrades.length - 1,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSortChip(
    BuildContext context,
    String label,
    bool isSelected,
    VoidCallback onTap,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        avatar: Icon(
          icon,
          size: 16,
          color: isSelected
              ? Theme.of(context).colorScheme.onPrimaryContainer
              : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        label: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: isSelected
                ? Theme.of(context).colorScheme.onPrimaryContainer
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        backgroundColor: isSelected
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.surfaceVariant,
        onPressed: onTap,
      ),
    );
  }
}

enum SortOption {
  dateNewestFirst,
  dateOldestFirst,
  pnlHighestFirst,
  pnlLowestFirst,
  buyTradesFirst,
  sellTradesFirst,
}

class CompactTradeListItem extends StatelessWidget {
  final Trade trade;
  final double balanceAfterTrade;
  final bool isLastItem;

  const CompactTradeListItem({
    required this.trade,
    required this.balanceAfterTrade,
    this.isLastItem = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final bool isProfit = trade.pnl >= 0;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.only(left: 16, right: 16, bottom: isLastItem ? 16 : 0),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          // Navigation to trade details
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // First row - Pair, direction, date
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: trade.direction == TradeDirection.buy
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      trade.direction.toString().split('.').last.toUpperCase(),
                      style: TextStyle(
                        color: trade.direction == TradeDirection.buy
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    trade.currencyPair.symbol,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatDate(trade.exitTime),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.textTheme.labelSmall?.color?.withOpacity(
                        0.6,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Second row - PnL, Risk, R:R
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // PnL indicator
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isProfit
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isProfit ? Icons.arrow_upward : Icons.arrow_downward,
                          size: 12,
                          color: isProfit ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '\$${trade.pnl.abs().toStringAsFixed(2)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isProfit ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Risk amount
                  Text(
                    'Risk: \$${trade.riskAmount.toStringAsFixed(2)}',
                    style: theme.textTheme.bodySmall,
                  ),

                  // Risk:Reward
                  Text(
                    'R:R ${trade.riskRewardRatio.toStringAsFixed(1)}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Third row - Duration and balance
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDuration(trade.duration),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.textTheme.labelSmall?.color?.withOpacity(
                        0.6,
                      ),
                    ),
                  ),
                  Text(
                    '\$${balanceAfterTrade.toStringAsFixed(2)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateDay = DateTime(date.year, date.month, date.day);

    if (dateDay == today) {
      return _formatTime(date);
    } else {
      return '${date.day}/${date.month} ${_formatTime(date)}';
    }
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
