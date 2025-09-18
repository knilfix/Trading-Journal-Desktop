import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trading_journal/models/trade_quality_data.dart';
import 'package:trading_journal/services/trade_data_processor.dart';
import 'package:fl_chart/fl_chart.dart';

class TradeQualityView extends StatelessWidget {
  const TradeQualityView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer<TradeDataProcessor>(
      builder: (context, processor, child) {
        final tradeQualityData = processor.tradeQualityData;

        if (tradeQualityData == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.analytics_outlined,
                  size: 64,
                  color: colorScheme.onSurface.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'No trades to analyze',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start trading to see quality metrics',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          backgroundColor: colorScheme.surface,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row - Risk/Reward and Hold Time
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildRiskRewardSection(tradeQualityData, theme),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildHoldTimeSection(tradeQualityData, theme),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Performance Analysis Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildHourlyPerformanceSection(
                        tradeQualityData,
                        theme,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildWeeklyPerformanceSection(
                        tradeQualityData,
                        theme,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRiskRewardSection(TradeQualityData data, ThemeData theme) {
    return Card(
      elevation: theme.cardTheme.elevation,
      color: theme.cardTheme.color,
      shape: theme.cardTheme.shape,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.balance_rounded,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Risk/Reward Distribution',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontSize: 18,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Risk/Reward Chart
            SizedBox(height: 200, child: _buildRiskRewardChart(data, theme)),

            const SizedBox(height: 16),

            // Risk/Reward Details
            ...data.riskRewardDistribution.map((item) {
              final count = item['count'] as int;
              final ratio = item['ratio'] as String;
              final percentage = _calculatePercentage(
                count,
                data.riskRewardDistribution,
              );

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getRiskRewardColor(ratio, theme),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Ratio $ratio',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Text(
                      '$count trades',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskRewardChart(TradeQualityData data, ThemeData theme) {
    if (data.riskRewardDistribution.isEmpty) {
      return Center(
        child: Text(
          'No risk/reward data available',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      );
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY:
            data.riskRewardDistribution
                .map((e) => (e['count'] as int).toDouble())
                .reduce((a, b) => a > b ? a : b) +
            2,
        barGroups: data.riskRewardDistribution.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final count = (item['count'] as int).toDouble();
          final ratio = item['ratio'] as String;

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: count,
                color: _getRiskRewardColor(ratio, theme),
                width: 16,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
            ],
          );
        }).toList(),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: theme.colorScheme.onSurface.withOpacity(0.1),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < data.riskRewardDistribution.length) {
                  return Text(
                    data.riskRewardDistribution[value.toInt()]['ratio'],
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
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

  Widget _buildHoldTimeSection(TradeQualityData data, ThemeData theme) {
    return Card(
      elevation: theme.cardTheme.elevation,
      color: theme.cardTheme.color,
      shape: theme.cardTheme.shape,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Hold Time Analysis',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontSize: 18,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            _buildHoldTimeDetails(
              'Winning Trades',
              data.holdTimeAnalysis['winning']!,
              Colors.green,
              theme,
            ),

            const SizedBox(height: 16),
            Divider(color: theme.colorScheme.onSurface.withOpacity(0.1)),
            const SizedBox(height: 16),

            _buildHoldTimeDetails(
              'Losing Trades',
              data.holdTimeAnalysis['losing']!,
              Colors.red,
              theme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHoldTimeDetails(
    String title,
    Map<String, Duration> times,
    Color accentColor,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _buildTimeMetric('Average', times['average'], theme),
            ),
            Expanded(child: _buildTimeMetric('Minimum', times['min'], theme)),
            Expanded(child: _buildTimeMetric('Maximum', times['max'], theme)),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeMetric(String label, Duration? duration, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _formatDuration(duration),
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildHourlyPerformanceSection(
    TradeQualityData data,
    ThemeData theme,
  ) {
    return Card(
      elevation: theme.cardTheme.elevation,
      color: theme.cardTheme.color,
      shape: theme.cardTheme.shape,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Hourly Performance',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontSize: 18,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            SizedBox(
              height: 250,
              child: _buildHourlyPerformanceChart(data, theme),
            ),

            const SizedBox(height: 16),
            _buildPerformanceSummary(
              data.hourlyPerformance,
              'Best Hour',
              'Worst Hour',
              theme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHourlyPerformanceChart(TradeQualityData data, ThemeData theme) {
    if (data.hourlyPerformance.isEmpty) {
      return Center(
        child: Text(
          'No hourly performance data available',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      );
    }

    List<BarChartGroupData> barGroups = [];
    for (var entry in data.hourlyPerformance.entries) {
      barGroups.add(
        BarChartGroupData(
          x: entry.key,
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
        ),
      );
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barGroups: barGroups,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: theme.colorScheme.onSurface.withOpacity(0.1),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, meta) {
                return Text(
                  '\$${value.toInt()}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 2,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}h',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  Widget _buildWeeklyPerformanceSection(
    TradeQualityData data,
    ThemeData theme,
  ) {
    return Card(
      elevation: theme.cardTheme.elevation,
      color: theme.cardTheme.color,
      shape: theme.cardTheme.shape,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_view_week_rounded,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Weekly Performance',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontSize: 18,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            SizedBox(
              height: 200,
              child: _buildWeeklyPerformanceChart(data, theme),
            ),

            const SizedBox(height: 16),

            ...data.weeklyPerformance.entries.map((entry) {
              final isPositive = entry.value >= 0;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isPositive ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        entry.key,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Text(
                      '\$${entry.value.toStringAsFixed(2)}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: isPositive ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 16),
            _buildPerformanceSummary(
              data.weeklyPerformance,
              'Best Day',
              'Worst Day',
              theme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyPerformanceChart(TradeQualityData data, ThemeData theme) {
    if (data.weeklyPerformance.isEmpty) {
      return Center(
        child: Text(
          'No weekly performance data available',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      );
    }

    // Use a map to store the day of the week and its corresponding profit/loss
    // The map already provides a natural ordering.
    final weeklyPerformance = data.weeklyPerformance;

    // Use a BarChart, as it is more appropriate for categorical data.
    List<BarChartGroupData> barGroups = [];
    int index = 0;

    // Create a list of the day names in the correct order for the x-axis
    final List<String> dayNames = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    for (String day in dayNames) {
      final value = weeklyPerformance[day] ?? 0.0;
      barGroups.add(
        BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: value,
              color: value >= 0
                  ? theme.colorScheme.primary
                  : theme.colorScheme.error,
              width: 16,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(4),
              ),
            ),
          ],
        ),
      );
      index++;
    }

    return BarChart(
      BarChartData(
        barGroups: barGroups,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: theme.colorScheme.onSurface.withOpacity(0.1),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, meta) {
                return Text(
                  '\$${value.toInt()}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final shortDayNames = [
                  'Mon',
                  'Tue',
                  'Wed',
                  'Thu',
                  'Fri',
                  'Sat',
                  'Sun',
                ];
                if (value.toInt() < shortDayNames.length) {
                  return Text(
                    shortDayNames[value.toInt()],
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
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

  Widget _buildPerformanceSummary<T>(
    Map<T, double> data,
    String bestLabel,
    String worstLabel,
    ThemeData theme,
  ) {
    if (data.isEmpty) return const SizedBox.shrink();

    final best = data.entries.reduce((a, b) => a.value > b.value ? a : b);
    final worst = data.entries.reduce((a, b) => a.value < b.value ? a : b);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.secondary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text(
                  bestLabel,
                  style: theme.textTheme.labelMedium?.copyWith(
                    // Use hardcoded green for 'best' as per the request
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${best.key}: \$${best.value.toStringAsFixed(2)}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 30,
            color: theme.colorScheme.onSurface.withOpacity(0.2),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  worstLabel,
                  style: theme.textTheme.labelMedium?.copyWith(
                    // Use hardcoded red for 'worst' as per the request
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${worst.key}: \$${worst.value.toStringAsFixed(2)}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration? d) {
    if (d == null) return 'N/A';
    String hours = d.inHours.toString().padLeft(2, '0');
    String minutes = (d.inMinutes % 60).toString().padLeft(2, '0');
    return '${hours}h ${minutes}m';
  }

  double _calculatePercentage(int count, List<Map<String, dynamic>> data) {
    final total = data.fold<int>(
      0,
      (sum, item) => sum + (item['count'] as int),
    );
    return total > 0 ? (count / total) * 100 : 0;
  }

  Color _getRiskRewardColor(String ratio, ThemeData theme) {
    final colors = [
      theme.colorScheme.primary,
      theme.colorScheme.secondary,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.purple,
    ];
    return colors[ratio.hashCode % colors.length];
  }
}
