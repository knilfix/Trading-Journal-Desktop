import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trading_journal/services/trade_data_processor.dart';
import 'package:trading_journal/models/performance_metrics.dart';
import 'package:fl_chart/fl_chart.dart';

class PerformanceView extends StatelessWidget {
  const PerformanceView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TradeDataProcessor>(
      builder: (context, processor, child) {
        if (processor.performanceMetrics == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final PerformanceMetrics metrics = processor.performanceMetrics!;

        // Access the current theme's color scheme
        final colorScheme = Theme.of(context).colorScheme;

        return Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Key Performance Metrics Cards
                _buildMetricsGrid(metrics, colorScheme),
                const SizedBox(height: 32),

                // Charts Section
                _buildChartsSection(metrics, colorScheme),
                const SizedBox(height: 32),

                // Detailed Stats Section
                _buildDetailedStatsSection(metrics, colorScheme),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetricsGrid(
    PerformanceMetrics metrics,
    ColorScheme colorScheme,
  ) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      childAspectRatio: 2.5,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildMetricCard(
          'Win Rate',
          '${metrics.winRate.toStringAsFixed(1)}%',
          Icons.trending_up,
          _getWinRateColor(metrics.winRate),
          colorScheme,
        ),
        _buildMetricCard(
          'Profit Factor',
          metrics.profitFactor.toStringAsFixed(2),
          Icons.account_balance,
          _getProfitFactorColor(metrics.profitFactor),
          colorScheme,
        ),
        _buildMetricCard(
          'Average Win',
          '\$${metrics.avgwin.toStringAsFixed(2)}',
          Icons.arrow_upward,
          Colors.green,
          colorScheme,
        ),
        _buildMetricCard(
          'Average Loss',
          '\$${metrics.avgloss.toStringAsFixed(2)}',
          Icons.arrow_downward,
          Colors.red,
          colorScheme,
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(icon, size: 20, color: color.withOpacity(0.7)),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartsSection(
    PerformanceMetrics metrics,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Performance Charts',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              flex: 5,
              child: _buildChartContainer(
                'Equity Curve',
                _buildEquityCurveChart(metrics, colorScheme),
                colorScheme,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 4,
              child: _buildChartContainer(
                'Daily P&L Distribution',
                _buildDailyPnlChart(metrics, colorScheme),
                colorScheme,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChartContainer(
    String title,
    Widget chart,
    ColorScheme colorScheme,
  ) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(child: chart),
        ],
      ),
    );
  }

  // Corrected _buildEquityCurveChart function with theme support
  Widget _buildEquityCurveChart(
    PerformanceMetrics metrics,
    ColorScheme colorScheme,
  ) {
    if (metrics.equityCurveData.isEmpty) {
      return Center(
        child: Text(
          'No equity curve data available',
          style: TextStyle(color: colorScheme.onSurface),
        ),
      );
    }

    List<FlSpot> spots = [];
    for (int i = 0; i < metrics.equityCurveData.length; i++) {
      spots.add(
        FlSpot(
          i.toDouble(),
          metrics.equityCurveData[i]['balance']?.toDouble() ?? 0.0,
        ),
      );
    }

    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: colorScheme.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            belowBarData: BarAreaData(
              show: true,
              color: colorScheme.primary.withOpacity(0.1),
            ),
          ),
        ],
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: colorScheme.onSurface.withOpacity(0.2),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60,
              getTitlesWidget: (value, meta) {
                return Text(
                  '\$${value.toInt()}',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: spots.length > 10 ? spots.length / 5 : 1,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 &&
                    value.toInt() < metrics.equityCurveData.length) {
                  final date =
                      metrics.equityCurveData[value.toInt()]['time']
                          as DateTime;
                  return Text(
                    '${date.month}/${date.day}',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  Widget _buildDailyPnlChart(
    PerformanceMetrics metrics,
    ColorScheme colorScheme,
  ) {
    if (metrics.dailyPnl.isEmpty) {
      return Center(
        child: Text(
          'No daily P&L data available',
          style: TextStyle(color: colorScheme.onSurface),
        ),
      );
    }

    // Convert the map to a list of entries and sort by day order
    final dayOrder = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final sortedEntries = metrics.dailyPnl.entries.toList()
      ..sort(
        (a, b) => dayOrder.indexOf(a.key).compareTo(dayOrder.indexOf(b.key)),
      );

    List<BarChartGroupData> barGroups = [];
    for (int i = 0; i < sortedEntries.length; i++) {
      final entry = sortedEntries[i];
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: entry.value,
              color: entry.value >= 0 ? Colors.green : Colors.red,
              width: 8,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(4),
              ),
            ),
          ],
          showingTooltipIndicators: [0],
        ),
      );
    }

    return BarChart(
      BarChartData(
        barGroups: barGroups,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    sortedEntries[value.toInt()].key.substring(
                      0,
                      3,
                    ), // Show "Mon", "Tue", etc.
                    style: TextStyle(
                      fontSize: 10,
                      color: colorScheme.onSurface,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: false),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final day = sortedEntries[groupIndex].key;
              final pnl = rod.toY;
              return BarTooltipItem(
                '$day: \$${pnl.toStringAsFixed(2)}',
                TextStyle(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w400,
                  fontSize: 8,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDetailedStatsSection(
    PerformanceMetrics metrics,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detailed Statistics',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Total Trades',
                  '${metrics.trades.length}',
                  colorScheme,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Winning Trades',
                  '${metrics.trades.where((t) => t.pnl > 0).length}',
                  colorScheme,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Losing Trades',
                  '${metrics.trades.where((t) => t.pnl < 0).length}',
                  colorScheme,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Break-even Trades',
                  '${metrics.trades.where((t) => t.pnl == 0).length}',
                  colorScheme,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Color _getWinRateColor(double winRate) {
    if (winRate >= 60) return Colors.green;
    if (winRate >= 45) return Colors.orange;
    return Colors.red;
  }

  Color _getProfitFactorColor(double profitFactor) {
    if (profitFactor >= 1.5) return Colors.green;
    if (profitFactor >= 1.0) return Colors.orange;
    return Colors.red;
  }
}
