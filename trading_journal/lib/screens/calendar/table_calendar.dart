import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trading_journal/screens/calendar/trade_day_modal.dart';
import 'package:trading_journal/services/account_service.dart';
import '../../services/trade_service.dart';
import '../../models/trade.dart';

class TradeCalendar extends StatefulWidget {
  const TradeCalendar({super.key});

  @override
  TradeCalendarState createState() => TradeCalendarState();
}

class TradeCalendarState extends State<TradeCalendar> {
  late Map<DateTime, List<Trade>> _tradesByDate;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final activeAccount = AccountService.instance.activeAccount;

  @override
  void initState() {
    super.initState();
    _fetchTrades();
  }

  void _fetchTrades() {
    final activeAccount = AccountService.instance.activeAccount;
    if (activeAccount == null) {
      _tradesByDate = {};
      setState(() {});
      return;
    }
    final tradeService = Provider.of<TradeService>(context, listen: false);
    final trades = tradeService.getTradesForAccount(activeAccount.id);
    _tradesByDate = _groupTradesByDate(trades);
    setState(() {});
  }

  Map<DateTime, List<Trade>> _groupTradesByDate(List<Trade> trades) {
    final Map<DateTime, List<Trade>> groupedTrades = {};

    for (var trade in trades) {
      final date = DateTime(
        trade.exitTime.year,
        trade.exitTime.month,
        trade.exitTime.day,
      );
      groupedTrades.putIfAbsent(date, () => []).add(trade);
    }

    return groupedTrades;
  }

  List<Trade> _getTradesForDay(DateTime day) {
    return _tradesByDate[DateTime(day.year, day.month, day.day)] ?? [];
  }

  double _getDailyPnL(DateTime day) {
    final trades = _getTradesForDay(day);
    return trades.fold(0.0, (sum, trade) => sum + trade.pnl);
  }

  double _getWeeklyPnL(DateTime weekStart) {
    double sum = 0.0;
    for (int i = 0; i < 7; i++) {
      final day = weekStart.add(Duration(days: i));
      sum += _getDailyPnL(day);
    }
    return sum;
  }

  double _getCalendarCellHeight(BuildContext context, int weekCount) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double screenHeight = mediaQuery.size.height;
    final double paddingTop = mediaQuery.padding.top;
    final double paddingBottom = mediaQuery.padding.bottom;

    // Calculate available height by subtracting fixed elements
    final double appBarHeight = kToolbarHeight; // Standard app bar height
    final double calendarHeaderHeight = 60; // Your header height
    final double monthSummaryHeight = 60; // Your month P&L section height
    final double verticalMargins = 16; // Approximate total vertical margins

    final double availableHeight =
        screenHeight -
        paddingTop -
        paddingBottom -
        appBarHeight -
        calendarHeaderHeight -
        monthSummaryHeight -
        verticalMargins;

    // Calculate max height per week, but ensure minimum cell height
    final double maxWeekHeight = availableHeight / weekCount;
    final double minCellHeight = 60; // Minimum height you want

    return maxWeekHeight.clamp(minCellHeight, double.infinity);
  }

  List<List<DateTime>> _getVisibleWeeks(DateTime focusedDay) {
    final firstDayOfMonth = DateTime(focusedDay.year, focusedDay.month, 1);
    final lastDayOfMonth = DateTime(focusedDay.year, focusedDay.month + 1, 0);

    // Sunday = 7 in Dart's weekday, so adjust accordingly
    int firstDayOffset =
        firstDayOfMonth.weekday % 7; // Sunday=0, Monday=1, ..., Saturday=6
    DateTime firstVisibleDay = firstDayOfMonth.subtract(
      Duration(days: firstDayOffset),
    );
    int lastDayOffset = 6 - (lastDayOfMonth.weekday % 7);
    DateTime lastVisibleDay = lastDayOfMonth.add(Duration(days: lastDayOffset));

    List<List<DateTime>> weeks = [];
    DateTime current = firstVisibleDay;
    while (current.isBefore(lastVisibleDay) ||
        current.isAtSameMomentAs(lastVisibleDay)) {
      weeks.add(List.generate(7, (i) => current.add(Duration(days: i))));
      current = current.add(Duration(days: 7));
    }
    return weeks;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeAccount = AccountService.instance.activeAccount;

    if (activeAccount == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_balance_wallet, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              'No active account selected',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    final weeks = _getVisibleWeeks(_focusedDay);

    final double cellHeight = _getCalendarCellHeight(context, weeks.length);

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime(
                  _focusedDay.year,
                  _focusedDay.month - 1,
                  1,
                );
              });
            },
          ),
          Text(
            '${_focusedDay.month}/${_focusedDay.year}',
            style: theme.textTheme.titleMedium,
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward_ios),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime(
                  _focusedDay.year,
                  _focusedDay.month + 1,
                  1,
                );
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Calendar Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                bottom: BorderSide(color: theme.dividerColor.withOpacity(0.2)),
              ),
            ),
            child: Row(
              children: [
                ...['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'].map(
                  (day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Week P&L',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Calendar Grid
          Expanded(
            child: ListView.builder(
              itemCount: weeks.length,
              itemBuilder: (context, weekIndex) {
                final week = weeks[weekIndex];
                final weekPnL = _getWeeklyPnL(week[0]);
                final weekStart = week[6];
                final weekEnd = week[5];
                final isCurrentWeek =
                    DateTime.now().isAfter(weekStart) &&
                    DateTime.now().isBefore(weekEnd.add(Duration(days: 1)));

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      ...week.map(
                        (day) => Expanded(
                          child: _buildCalendarDay(day, theme, cellHeight),
                        ),
                      ),
                      // Weekly P&L Column
                      Expanded(
                        child: Container(
                          constraints: BoxConstraints(
                            minHeight: 60,
                            maxHeight: cellHeight,
                          ),
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: isCurrentWeek
                                ? theme.colorScheme.primary.withOpacity(0.1)
                                : theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isCurrentWeek
                                  ? theme.colorScheme.primary.withOpacity(0.3)
                                  : theme.dividerColor.withOpacity(0.2),
                              width: isCurrentWeek ? 2 : 1,
                            ),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  weekPnL == 0
                                      ? '-'
                                      : '${weekPnL > 0 ? '+' : ''}${weekPnL.toStringAsFixed(0)}',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: weekPnL > 0
                                        ? Colors.green.shade700
                                        : weekPnL < 0
                                        ? Colors.red.shade700
                                        : Colors.grey.shade600,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                if (weekPnL != 0) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    '${week.where((day) => _getTradesForDay(day).isNotEmpty).length} days',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.6),
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Month P&L: ',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Builder(
                  builder: (_) {
                    final monthPnL = _getMonthPnL(weeks);
                    return Text(
                      monthPnL == 0
                          ? '-'
                          : '${monthPnL > 0 ? '+' : ''}${monthPnL.toStringAsFixed(0)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: monthPnL > 0
                            ? Colors.green.shade700
                            : monthPnL < 0
                            ? Colors.red.shade700
                            : Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _getMonthPnL(List<List<DateTime>> weeks) {
    double sum = 0.0;
    for (final week in weeks) {
      sum += _getWeeklyPnL(week[0]);
    }
    return sum;
  }

  Widget _buildCalendarDay(DateTime day, ThemeData theme, double cellHeight) {
    final trades = _getTradesForDay(day);
    final dailyPnL = _getDailyPnL(day);
    final hasTrades = trades.isNotEmpty;
    final isToday = isSameDay(day, DateTime.now());
    final isSelected = isSameDay(day, _selectedDay ?? DateTime.now());
    final isCurrentMonth = day.month == _focusedDay.month;

    // Determine day color based on P&L
    Color dayColor = Colors.transparent;
    if (hasTrades) {
      if (dailyPnL > 0) {
        dayColor = Colors.green.withOpacity(0.15);
      } else if (dailyPnL < 0) {
        dayColor = Colors.red.withOpacity(0.15);
      } else {
        dayColor = Colors.grey.withOpacity(
          0.18,
        ); // Slightly more visible for break-even
      }
    }

    // Border color
    Color borderColor = Colors.transparent;
    if (isSelected) {
      borderColor = theme.colorScheme.primary;
    } else if (isToday) {
      borderColor = theme.colorScheme.secondary;
    }

    // Trade count color (blue with alpha)
    final tradeCountColor = Colors.blue.withOpacity(0.55);

    // PnL color
    Color pnlColor;
    if (dailyPnL > 0) {
      pnlColor = Colors.green.shade700;
    } else if (dailyPnL < 0) {
      pnlColor = Colors.red.shade700;
    } else {
      pnlColor = Colors.grey.shade600;
    }

    return GestureDetector(
      onTap: () {
        final trades = _getTradesForDay(day);

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 8,

            content: TradeDayModal(trades: trades, date: day),
            contentPadding: EdgeInsets.zero,
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Close',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
      child: Container(
        constraints: BoxConstraints(minHeight: cellHeight),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: dayColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: borderColor,
            width: isSelected || isToday ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              day.day.toString(),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: hasTrades ? FontWeight.bold : FontWeight.normal,
                color: isCurrentMonth
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurface.withOpacity(0.4),
              ),
            ),
            if (hasTrades) ...[
              const SizedBox(height: 2),
              Text(
                '${trades.length}',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: tradeCountColor,
                ),
              ),
              Text(
                dailyPnL > 0
                    ? '+${dailyPnL.toStringAsFixed(0)}'
                    : dailyPnL.toStringAsFixed(0),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  color: pnlColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

bool isSameDay(DateTime? a, DateTime? b) {
  if (a == null || b == null) return false;
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
