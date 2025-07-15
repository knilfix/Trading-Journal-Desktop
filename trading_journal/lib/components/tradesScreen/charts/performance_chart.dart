import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:trading_journal/models/trade.dart';

class PerformanceChart extends StatelessWidget {
  final List<Trade> trades;
  final double startingBalance;
  final double height;
  final double? width;
  final int maxTradesOnXAxis; // New parameter for X-axis range

  const PerformanceChart({
    super.key,
    required this.trades,
    this.startingBalance = 5000,
    this.height = 1000,
    this.width,
    this.maxTradesOnXAxis = 10, // Default to 10 trades on X-axis
  });

  @override
  Widget build(BuildContext context) {
    // Handle insufficient data
    if (trades.isEmpty) {
      return const Center(child: Text('No trades to display'));
    }

    // Build cumulative balances: X=0 is starting balance, X=1 is after first trade, etc.
    final spots = <FlSpot>[];
    double balance = startingBalance;
    spots.add(FlSpot(0, balance));
    for (int i = 0; i < trades.length; i++) {
      balance += trades[i].pnl;
      spots.add(FlSpot((i + 1).toDouble(), balance));
    }

    // Calculate Y-axis bounds
    final yValues = spots.map((s) => s.y);
    final minY = yValues.reduce((a, b) => a < b ? a : b);
    final maxY = yValues.reduce((a, b) => a > b ? a : b);
    final yRange = maxY - minY;
    // Dynamic padding: 25% below minY, 15% above maxY, with fallback for zero range
    final lowerPad = yRange == 0 ? startingBalance * 0.3 : yRange * 0.5;
    final upperPad = yRange == 0 ? startingBalance * 0.2 : yRange * 0.3;
    final adjustedMinY = minY - lowerPad; // Allow negative balances
    final adjustedMaxY = maxY + upperPad;

    // Calculate X-axis bounds
    final maxX = maxTradesOnXAxis.toDouble(); // Fixed X-axis range

    return SizedBox(
      height: height,
      width: width,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: maxX,
          minY: adjustedMinY,
          maxY: adjustedMaxY,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              gradient: const LinearGradient(
                colors: [Colors.blueAccent, Colors.greenAccent],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              barWidth: 3,
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    Colors.blueAccent.withOpacity(0.3),
                    Colors.greenAccent.withOpacity(0.1),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) =>
                    FlDotCirclePainter(
                      radius: index == 0
                          ? 6
                          : 4, // Larger dot for starting balance
                      color: index == 0 ? Colors.redAccent : Colors.blueAccent,
                      strokeWidth: 2,
                      strokeColor: Colors.white,
                    ),
              ),
            ),
          ],
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            drawHorizontalLine: true,
            horizontalInterval: (adjustedMaxY - adjustedMinY) / 5,
            verticalInterval: maxX / 5, // Grid lines based on maxTradesOnXAxis
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey.shade300, width: 1),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 48,
                interval: (adjustedMaxY - adjustedMinY) / 5,
                getTitlesWidget: (value, meta) => Text(
                  '\$${value.toStringAsFixed(0)}', // Currency format
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.right,
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: maxX / 5, // Labels based on maxTradesOnXAxis
                getTitlesWidget: (value, meta) {
                  if (value == 0) {
                    return const Text(
                      'Start',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    );
                  }
                  if (value % 1 == 0 && value <= maxX) {
                    return Text(
                      'T${value.toInt()}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => Colors.blueAccent.withOpacity(0.8),
              getTooltipItems: (List<LineBarSpot> touchedSpots) {
                return touchedSpots.map((spot) {
                  if (spot.x == 0) {
                    return LineTooltipItem(
                      'Starting Balance\n\$${spot.y.toStringAsFixed(2)}',
                      const TextStyle(color: Colors.white, fontSize: 12),
                    );
                  }
                  return LineTooltipItem(
                    'Trade ${spot.x.toInt()}\nBalance: \$${spot.y.toStringAsFixed(2)}\nPnL: \$${trades[spot.x.toInt() - 1].pnl.toStringAsFixed(2)}',
                    const TextStyle(color: Colors.white, fontSize: 12),
                  );
                }).toList();
              },
            ),
            handleBuiltInTouches: true,
            getTouchedSpotIndicator: (barData, spotIndexes) {
              return spotIndexes.map((index) {
                return TouchedSpotIndicatorData(
                  FlLine(color: Colors.blueAccent, strokeWidth: 2),
                  FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) =>
                        FlDotCirclePainter(
                          radius: 6,
                          color: Colors.blueAccent,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        ),
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }
}
