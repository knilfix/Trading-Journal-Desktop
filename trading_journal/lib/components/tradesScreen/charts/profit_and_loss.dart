import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:trading_journal/components/tradesScreen/charts/trade_data_processor.dart';
import '../../../services/account_service.dart';
import '../../../services/trade_service.dart';
import '../../../models/account.dart';

class ProfitLossChart extends StatefulWidget {
  final int? maxTradesToShow;
  static const double chartHeight = 640;
  static const double containerPadding = 20;
  static const double dotRadius = 4;
  static const double dotStrokeWidth = 2;
  static const double lineWidth = 2;
  static const double baselineOpacity = 0.3;
  static const double areaOpacity = 0.2;
  static const double gridOpacity = 0.1;
  static const double emptySpaceFraction = 0.25;

  const ProfitLossChart({super.key, this.maxTradesToShow});

  @override
  State<ProfitLossChart> createState() => _ProfitLossChartState();
}

class _ProfitLossChartState extends State<ProfitLossChart> {
  bool _showLastTenTradesOnly = false;
  final Color _profitColor = Colors.green;
  final Color _lossColor = Colors.red;
  final Color _mainLineColor = const Color.fromARGB(255, 83, 129, 231);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer2<AccountService, TradeService>(
      builder: (context, accountService, tradeService, child) {
        final activeAccount = accountService.activeAccount;

        if (activeAccount == null) {
          return const Center(child: Text('No active account selected'));
        }

        final trades = tradeService.getTradesForAccount(activeAccount.id);

        if (trades.isEmpty) {
          return const Center(child: Text('No trades recorded yet'));
        }

        final processor = TradeDataProcessor(
          trades,
          activeAccount.startBalance,
          showLastTenOnly: _showLastTenTradesOnly,
        );

        return Container(
          height: ProfitLossChart.chartHeight,
          padding: const EdgeInsets.all(ProfitLossChart.containerPadding),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.dividerColor.withOpacity(
                ProfitLossChart.baselineOpacity,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildChartHeader(theme, trades.length, activeAccount, processor),
              const SizedBox(height: 8),
              _buildLastTenToggle(theme),
              const SizedBox(height: 16),
              Expanded(
                child: LineChart(
                  LineChartData(
                    minY: processor.calculateMinY(),
                    maxY: processor.calculateMaxY(),
                    gridData: _buildGridData(theme, processor),
                    titlesData: _buildTitlesData(theme, processor),
                    borderData: _buildBorderData(theme),
                    clipData: const FlClipData.all(),
                    lineBarsData: _buildLineBarsData(
                      theme,
                      processor,
                      activeAccount.startBalance,
                    ),
                    lineTouchData: _buildTouchData(theme, processor),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<LineChartBarData> _buildLineBarsData(
    ThemeData theme,
    TradeDataProcessor processor,
    double startBalance,
  ) {
    final spots = processor.generateCumulativeSpots();
    if (spots.isEmpty) return [];

    final double maxX = spots.last.x;
    final double extendedMaxX = maxX / (1 - ProfitLossChart.emptySpaceFraction);

    return [
      // Baseline reference line
      LineChartBarData(
        spots: [FlSpot(0, startBalance), FlSpot(extendedMaxX, startBalance)],
        isCurved: false,
        color: theme.colorScheme.onSurface.withAlpha(
          (ProfitLossChart.baselineOpacity * 255).toInt(),
        ),
        barWidth: 1,
        dotData: const FlDotData(show: false),
        dashArray: [5, 5],
        belowBarData: BarAreaData(show: false),
      ),

      // Profit area (green above baseline)
      LineChartBarData(
        spots: spots,
        isCurved: true,
        curveSmoothness: 0.3,
        color: Colors.transparent,
        barWidth: 0,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(
          show: true,
          applyCutOffY: true,
          cutOffY: startBalance,
          color: _profitColor.withAlpha(
            (ProfitLossChart.areaOpacity * 255).toInt(),
          ),
        ),
      ),

      // Loss area (red below baseline)
      LineChartBarData(
        spots: spots,
        isCurved: true,
        curveSmoothness: 0.3,
        color: Colors.transparent,
        barWidth: 0,
        dotData: const FlDotData(show: false),
        aboveBarData: BarAreaData(
          show: true,
          applyCutOffY: true,
          cutOffY: startBalance,
          color: _lossColor.withAlpha(
            (ProfitLossChart.areaOpacity * 255).toInt(),
          ),
        ),
      ),

      // Main visible performance line
      LineChartBarData(
        spots: spots,
        isCurved: true,
        curveSmoothness: 0.3,
        color: _mainLineColor,
        barWidth: ProfitLossChart.lineWidth,
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, _, __, ___) {
            final tradePoint = processor.getTradePoint(spot.x.toInt());
            return FlDotCirclePainter(
              radius: ProfitLossChart.dotRadius,
              color: tradePoint.pnl >= 0 ? _profitColor : _lossColor,
              strokeColor: Colors.white,
              strokeWidth: ProfitLossChart.dotStrokeWidth,
            );
          },
        ),
        belowBarData: BarAreaData(show: false),
        aboveBarData: BarAreaData(show: false),
      ),
    ];
  }

  Widget _buildChartHeader(
    ThemeData theme,
    int tradeCount,
    Account activeAccount,
    TradeDataProcessor processor,
  ) {
    return Row(
      children: [
        Icon(Icons.show_chart, color: theme.primaryColor, size: 20),
        const SizedBox(width: 8),
        Text(
          'P&L Performance - ${_showLastTenTradesOnly
              ? "Last 10"
              : processor.isSampling
              ? "Sample of ${processor.totalTradeCount}"
              : "All ${processor.totalTradeCount}"} Trades',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        _buildAccountTypeIndicator(activeAccount),
      ],
    );
  }

  Widget _buildAccountTypeIndicator(Account account) {
    final String label;
    final Color color;
    final String icon;

    switch (account.accountType) {
      case AccountType.live:
        label = 'Live';
        color = _profitColor;
        icon = '🚀';
        break;
      case AccountType.demo:
        label = 'Demo';
        color = _mainLineColor;
        icon = '🧪';
        break;
      case AccountType.backtesting:
        label = 'Backtest';
        color = Colors.purple;
        icon = '🔍';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(ProfitLossChart.areaOpacity),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(ProfitLossChart.baselineOpacity),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLastTenToggle(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text('Show last 10 trades only', style: theme.textTheme.bodySmall),
        const SizedBox(width: 8),
        Switch(
          value: _showLastTenTradesOnly,
          onChanged: (value) {
            setState(() {
              _showLastTenTradesOnly = value;
            });
          },
        ),
      ],
    );
  }

  FlTitlesData _buildTitlesData(ThemeData theme, TradeDataProcessor processor) {
    final minY = processor.calculateMinY();
    final maxY = processor.calculateMaxY();
    final tradeCount = processor.tradeCount;

    return FlTitlesData(
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: _calculateLeftAxisReservedSpace(minY, maxY),
          interval: _calculateYInterval(minY, maxY),
          getTitlesWidget: (value, meta) {
            return Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Text(
                _formatYAxisValue(value),
                textAlign: TextAlign.right,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  color: theme.colorScheme.onSurface.withOpacity(
                    ProfitLossChart.baselineOpacity,
                  ),
                ),
              ),
            );
          },
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 24,
          interval: _calculateXInterval(tradeCount),
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index == 0) return _buildStartLabel(theme);
            if (index % _calculateXInterval(tradeCount).toInt() != 0 &&
                index != tradeCount - 1) {
              return const SizedBox();
            }

            return _buildTradeLabel(theme, index);
          },
        ),
      ),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  String _formatYAxisValue(double value) {
    if (value >= 1000000) {
      return '\$${(value / 1000000).toStringAsFixed(1)}M';
    }
    if (value >= 1000) {
      return '\$${(value / 1000).toStringAsFixed(1)}K';
    }
    return '\$${value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2)}';
  }

  double _calculateLeftAxisReservedSpace(double minY, double maxY) {
    final longestLabel = maxY >= 1000
        ? _formatYAxisValue(maxY)
        : _formatYAxisValue(minY);
    final textPainter = TextPainter(
      text: TextSpan(text: longestLabel, style: const TextStyle(fontSize: 10)),
      textDirection: TextDirection.ltr,
    )..layout();
    return textPainter.width + 12;
  }

  double _calculateYInterval(double minY, double maxY) {
    final range = maxY - minY;
    if (range <= 50) return 10;
    if (range <= 100) return 20;
    if (range <= 500) return 50;
    if (range <= 1000) return 100;
    if (range <= 5000) return 500;
    return 1000;
  }

  double _calculateXInterval(int tradeCount) {
    if (tradeCount <= 10) return 1;
    if (tradeCount <= 20) return 2;
    if (tradeCount <= 50) return 5;
    if (tradeCount <= 100) return 10;
    return 20;
  }

  Widget _buildStartLabel(ThemeData theme) {
    return Text(
      'Start',
      style: theme.textTheme.bodySmall?.copyWith(
        fontSize: 10,
        color: theme.colorScheme.onSurface.withOpacity(
          ProfitLossChart.baselineOpacity,
        ),
      ),
    );
  }

  Widget _buildTradeLabel(ThemeData theme, int index) {
    return Text(
      'T$index',
      style: theme.textTheme.bodySmall?.copyWith(
        fontSize: 10,
        color: theme.colorScheme.onSurface.withOpacity(
          ProfitLossChart.baselineOpacity,
        ),
      ),
    );
  }

  FlBorderData _buildBorderData(ThemeData theme) {
    return FlBorderData(
      show: true,
      border: Border(
        left: BorderSide(
          color: theme.dividerColor.withOpacity(ProfitLossChart.gridOpacity),
        ),
        bottom: BorderSide(
          color: theme.dividerColor.withOpacity(ProfitLossChart.gridOpacity),
        ),
      ),
    );
  }

  LineTouchData _buildTouchData(ThemeData theme, TradeDataProcessor processor) {
    return LineTouchData(
      enabled: true,
      handleBuiltInTouches: true,
      touchTooltipData: LineTouchTooltipData(
        getTooltipColor: (_) => theme.colorScheme.surface,
        tooltipBorder: BorderSide(color: theme.dividerColor),
        tooltipPadding: const EdgeInsets.all(8),
        getTooltipItems: (List<LineBarSpot> touchedSpots) {
          if (touchedSpots.isEmpty) return [];

          // The main performance line is always index 3 in our lineBarsData
          // (after baseline, profit area, and loss area)
          const int mainLineIndex = 3;

          // Find the spot from the main performance line
          final mainSpot = touchedSpots.firstWhere(
            (spot) => spot.barIndex == mainLineIndex,
            orElse: () => touchedSpots.first,
          );

          // Get trade data for this spot
          final tradePoint = processor.getTradePoint(mainSpot.x.toInt());

          // Return tooltips for all spots (one per line)
          return touchedSpots.map((spot) {
            // Only show tooltip for main performance line
            if (spot.barIndex != mainLineIndex) return null;

            return LineTooltipItem(
              tradePoint.isStartingBalance
                  ? 'Starting Balance\n\$${tradePoint.balance.toStringAsFixed(2)}'
                  : 'Trade ${tradePoint.tradeId ?? "N/A"}\n'
                        'Balance: \$${tradePoint.balance.toStringAsFixed(2)}\n'
                        'P&L: ${tradePoint.pnl >= 0 ? "+" : ""}\$${tradePoint.pnl.toStringAsFixed(2)}',

              TextStyle(
                color: tradePoint.pnl >= 0 ? _profitColor : _lossColor,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            );
          }).toList();
        },
      ),
      touchSpotThreshold: 10,
    );
  }

  FlGridData _buildGridData(ThemeData theme, TradeDataProcessor processor) {
    final minY = processor.calculateMinY();
    final maxY = processor.calculateMaxY();

    return FlGridData(
      show: true,
      drawVerticalLine: false,
      horizontalInterval: _calculateYInterval(minY, maxY),
      getDrawingHorizontalLine: (_) => FlLine(
        color: theme.dividerColor.withOpacity(ProfitLossChart.gridOpacity),
        strokeWidth: 1,
      ),
    );
  }
}
