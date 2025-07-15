import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/tradesScreen/charts/chart_data_processor.dart';
import '../components/tradesScreen/charts/performance_chart.dart';
import '../services/account_service.dart';
import '../services/trade_service.dart';

class DemoScreen extends StatelessWidget {
  const DemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChartDataProcessor(
        accountService: AccountService.instance,
        tradeService: TradeService.instance,
      ),
      child: Scaffold(
        appBar: AppBar(title: const Text('Performance Chart Demo')),
        body: Consumer<ChartDataProcessor>(
          builder: (context, processor, child) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  height: 300,
                  padding: const EdgeInsets.all(16.0),
                  child: PerformanceChart(trades: processor.trades),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
