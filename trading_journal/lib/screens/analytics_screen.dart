// screens/analytics_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trading_journal/components/analytics/profit_loss_view.dart';
import 'package:trading_journal/components/analytics/trade_quality_view.dart';
import 'package:trading_journal/components/analytics/performance_view.dart';
import 'package:trading_journal/services/trade_data_processor.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TradeDataProcessor>(
      create: (context) => TradeDataProcessor(),
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          elevation: 0,
          bottom: TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Theme.of(
              context,
            ).colorScheme.onSurface.withOpacity(0.6),
            indicatorSize: TabBarIndicatorSize.label,
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 3.0,
              ),
            ),
            tabs: const [
              Tab(text: 'Performance'),
              Tab(text: 'P&L'),
              Tab(text: 'Trade Quality'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: const [
            PerformanceView(),
            ProfitLossView(),
            TradeQualityView(),
          ],
        ),
      ),
    );
  }
}
