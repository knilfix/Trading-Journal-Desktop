import 'package:flutter/material.dart';
import 'package:trading_journal/models/trade.dart';
import 'package:trading_journal/services/trade_service.dart';

import 'package:trading_journal/components/tradesScreen/trade_details/trade_metrics_view.dart';
import 'package:trading_journal/components/tradesScreen/trade_details/trade_screenshots_view.dart';

class TradeDetailsPage extends StatefulWidget {
  final int tradeId;
  const TradeDetailsPage({required this.tradeId, super.key});

  @override
  State<TradeDetailsPage> createState() => _TradeDetailsPageState();
}

enum TradeDetailsView { metrics, screenshots }

class _TradeDetailsPageState extends State<TradeDetailsPage> {
  TradeDetailsView _currentView = TradeDetailsView.metrics;
  late Future<Trade?> _tradeFuture;

  @override
  void initState() {
    super.initState();
    _tradeFuture = Future.value(
      TradeService.instance.getTradeById(widget.tradeId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder<Trade?>(
      future: _tradeFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: const Text('Loading...')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        final trade = snapshot.data;
        if (trade == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Trade Details')),
            body: const Center(child: Text('Trade not found!')),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(
              trade.currencyPair.symbol,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildViewToggleButton(),
                const SizedBox(height: 24),
                Expanded(
                  child: _currentView == TradeDetailsView.metrics
                      ? TradeMetricsView(trade: trade)
                      : TradeScreenshotsView(trade: trade),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildViewToggleButton() {
    return SegmentedButton<TradeDetailsView>(
      segments: const [
        ButtonSegment(
          value: TradeDetailsView.metrics,
          label: Text('Metrics'),
          icon: Icon(Icons.show_chart_outlined),
        ),
        ButtonSegment(
          value: TradeDetailsView.screenshots,
          label: Text('Screenshots'),
          icon: Icon(Icons.camera_alt_outlined),
        ),
      ],
      selected: {_currentView},
      onSelectionChanged: (newSelection) {
        setState(() {
          _currentView = newSelection.first;
        });
      },
    );
  }
}
