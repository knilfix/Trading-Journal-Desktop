import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trading_journal/models/profit_loss_data.dart';
import 'package:trading_journal/services/trade_data_processor.dart';
import 'package:fl_chart/fl_chart.dart';

class ProfitLossView extends StatelessWidget {
  const ProfitLossView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer<TradeDataProcessor>(
      builder: (context, processor, child) {
        if (processor.profitLossData == null) {
          return Center(
            child: CircularProgressIndicator(color: colorScheme.primary),
          );
        }

        final profitLossData = processor.profitLossData!;

        return Scaffold(
          backgroundColor: colorScheme.surface,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Key P&L Metrics
                _buildPnLSummaryCards(profitLossData, theme),
                const SizedBox(height: 32),

                // Visual P&L Breakdown
                _buildPnLVisualization(profitLossData, theme),
                const SizedBox(height: 32),

                // Detailed Analysis Section
                _buildDetailedAnalysis(profitLossData, theme),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPnLSummaryCards(dynamic profitLossData, ThemeData theme) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      childAspectRatio: 2.2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildSummaryCard(
          'Net P&L',
          '\$${profitLossData.netPnL.toStringAsFixed(2)}',
          _getPnLIcon(profitLossData.netPnL),
          _getPnLColor(profitLossData.netPnL, theme),
          theme,
          subtitle: 'Total Performance',
        ),
        _buildSummaryCard(
          'Best Day',
          '\$${profitLossData.biggestWinningDay.toStringAsFixed(2)}',
          Icons.trending_up_rounded,
          Colors.green,
          theme,
          subtitle: 'Highest Single Day',
        ),
        _buildSummaryCard(
          'Worst Day',
          '\$${profitLossData.biggestLosingDay.toStringAsFixed(2)}',
          Icons.trending_down_rounded,
          Colors.red,
          theme,
          subtitle: 'Lowest Single Day',
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color accentColor,
    ThemeData theme, {
    String? subtitle,
  }) {
    return Card(
      elevation: theme.cardTheme.elevation,
      color: theme.cardTheme.color,
      shape: theme.cardTheme.shape,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.8),
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 24, color: accentColor),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: accentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPnLVisualization(dynamic profitLossData, ThemeData theme) {
    return Row(
      children: [
        // P&L Breakdown Pie Chart
        Expanded(
          flex: 1,
          child: _buildVisualizationCard(
            'P&L Distribution',
            _buildPnLPieChart(profitLossData, theme),
            theme,
          ),
        ),
        const SizedBox(width: 16),

        // Key Ratios Cards
        Expanded(
          flex: 1,
          child: Column(
            children: [
              _buildRatioCard(
                'Average P&L per Trade',
                '\$${profitLossData.averagePnL.toStringAsFixed(2)}',
                profitLossData.averagePnL,
                theme,
              ),
              const SizedBox(height: 16),
              _buildRatioCard(
                'Expectancy',
                '${profitLossData.expectancy.toStringAsFixed(3)}',
                profitLossData.expectancy,
                theme,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVisualizationCard(
    String title,
    Widget content,
    ThemeData theme,
  ) {
    return Card(
      elevation: theme.cardTheme.elevation,
      color: theme.cardTheme.color,
      shape: theme.cardTheme.shape,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontSize: 16,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(height: 200, child: content),
          ],
        ),
      ),
    );
  }

  Widget _buildRatioCard(
    String title,
    String value,
    double numericValue,
    ThemeData theme,
  ) {
    return Card(
      elevation: theme.cardTheme.elevation,
      color: theme.cardTheme.color,
      shape: theme.cardTheme.shape,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _getPnLColor(numericValue, theme),
                  ),
                ),
                Icon(
                  _getPnLIcon(numericValue),
                  color: _getPnLColor(numericValue, theme),
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPnLPieChart(ProfitLossData profitLossData, ThemeData theme) {
    final totalProfit = profitLossData.totalProfit;
    final totalLoss = profitLossData.totalLoss;

    // For pie chart, we want to show the composition of gross P&L
    final totalGross =
        totalProfit + totalLoss; // This is the sum of absolute values

    if (totalGross == 0) {
      return Center(
        child: Text(
          'No P&L data available',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withAlpha(216),
          ),
        ),
      );
    }

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 50,
        sections: [
          PieChartSectionData(
            color: Colors.green,
            value: totalProfit,
            title:
                '${(totalProfit / totalGross * 100).toStringAsFixed(1)}%\n\$${totalProfit.toStringAsFixed(2)}',
            radius: 60,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          PieChartSectionData(
            color: Colors.red,
            value: totalLoss,
            title:
                '${(totalLoss / totalGross * 100).toStringAsFixed(1)}%\n\$${totalLoss.toStringAsFixed(2)}',
            radius: 60,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedAnalysis(dynamic profitLossData, ThemeData theme) {
    return Card(
      elevation: theme.cardTheme.elevation,
      color: theme.cardTheme.color,
      shape: theme.cardTheme.shape,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detailed Analysis',
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 24,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 24),

            // Analysis Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 4,
              crossAxisSpacing: 32,
              mainAxisSpacing: 16,
              children: [
                _buildAnalysisItem(
                  'Total Trades Executed',
                  '${profitLossData.totalTrades}',
                  Icons.swap_horiz_rounded,
                  theme,
                ),
                _buildAnalysisItem(
                  'Risk-Reward Ratio',
                  profitLossData.biggestLosingDay != 0
                      ? '1:${(profitLossData.biggestWinningDay.abs() / profitLossData.biggestLosingDay.abs()).toStringAsFixed(2)}'
                      : 'N/A',
                  Icons.balance_rounded,
                  theme,
                ),
                _buildAnalysisItem(
                  'Max Drawdown Day',
                  '\$${profitLossData.biggestLosingDay.toStringAsFixed(2)}',
                  Icons.trending_down_rounded,
                  theme,
                ),
                _buildAnalysisItem(
                  'Best Performance Day',
                  '\$${profitLossData.biggestWinningDay.toStringAsFixed(2)}',
                  Icons.trending_up_rounded,
                  theme,
                ),
              ],
            ),

            const SizedBox(height: 24),
            Divider(color: theme.colorScheme.onSurface.withOpacity(0.1)),
            const SizedBox(height: 16),

            // Performance Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.insights_rounded,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Performance Insight',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getPerformanceInsight(profitLossData),
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisItem(
    String label,
    String value,
    IconData icon,
    ThemeData theme,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.secondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getPnLColor(double value, ThemeData theme) {
    if (value > 0) return Colors.green;
    if (value < 0) return Colors.red;
    return theme.colorScheme.onSurface.withOpacity(0.7);
  }

  IconData _getPnLIcon(double value) {
    if (value > 0) return Icons.trending_up_rounded;
    if (value < 0) return Icons.trending_down_rounded;
    return Icons.remove_rounded;
  }

  String _getPerformanceInsight(dynamic profitLossData) {
    if (profitLossData.netPnL > 0 && profitLossData.expectancy > 0) {
      return 'Strong positive performance with favorable expectancy. Your trading strategy shows consistent profitability.';
    } else if (profitLossData.netPnL > 0 && profitLossData.expectancy <= 0) {
      return 'Positive P&L but low expectancy. Consider reviewing trade selection and risk management.';
    } else if (profitLossData.netPnL < 0 && profitLossData.expectancy > 0) {
      return 'Negative P&L despite positive expectancy. May need more trades for statistical significance.';
    } else {
      return 'Performance needs improvement. Focus on trade strategy refinement and risk management.';
    }
  }
}
