class TradeQualityData {
  final List<Map<String, dynamic>> riskRewardDistribution;
  final Map<String, Map<String, Duration>> holdTimeAnalysis;
  final Map<int, double> hourlyPerformance;
  final Map<String, double> weeklyPerformance;

  TradeQualityData({
    required this.riskRewardDistribution,
    required this.holdTimeAnalysis,
    required this.hourlyPerformance,
    required this.weeklyPerformance,
  });
}
