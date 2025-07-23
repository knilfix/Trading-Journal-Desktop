import 'package:flutter/material.dart';
import 'package:trading_journal/components/tradesScreen/trade_details_page.dart';
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
            fontSize: 16,
            fontWeight: FontWeight.w400,
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
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
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
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
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
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            itemCount: _sortedTrades.length,
            separatorBuilder: (context, index) => const SizedBox(height: 4),
            itemBuilder: (context, index) {
              final trade = _sortedTrades[index];
              return CompactTradeListItem(
                trade: trade,
                balanceAfterTrade: trade.postTradeBalance,
                initialBalance: widget.initialBalance,
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
            : Theme.of(context).colorScheme.surfaceContainerHighest,
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
