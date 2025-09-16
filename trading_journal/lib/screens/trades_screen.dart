import 'package:flutter/material.dart';
import '../services/account_service.dart';
import '../components/tradesScreen/add_trade/add_trade.dart';
import '../components/tradesScreen/trades_tab_view.dart';
import '../components/tradesScreen/charts/profit_and_loss.dart';
import '../components/tradesScreen/add_trade/trade_submission_controller.dart';

class TradesScreen extends StatefulWidget {
  const TradesScreen({super.key});

  @override
  State<TradesScreen> createState() => _TradesScreenState();
}

class _TradesScreenState extends State<TradesScreen> {
  int _selectedIndex = 0;

  @override
  @override
  Widget build(BuildContext context) {
    final activeAccount = AccountService.instance.activeAccount;

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? Colors
                .white // Whitish background in light mode
          : Theme.of(context).colorScheme.surface, // Dark surface in dark mode
      body: activeAccount == null
          ? const Center(
              child: Text(
                'No active account selected',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : Column(
              children: [
                // Segmented Button for View Selection
                Padding(
                  padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
                  child: SegmentedButton<int>(
                    segments: const [
                      ButtonSegment<int>(
                        value: 0,
                        icon: Icon(Icons.dashboard_outlined),
                        label: Text('Trade Entry'),
                      ),
                      ButtonSegment<int>(
                        value: 1,
                        icon: Icon(Icons.list_alt),
                        label: Text('All Trades'),
                      ),
                    ],
                    selected: {_selectedIndex},
                    onSelectionChanged: (newSelection) {
                      setState(() {
                        _selectedIndex = newSelection.first;
                      });
                    },
                    style: SegmentedButton.styleFrom(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.surface, // Adaptive background
                      foregroundColor: Theme.of(
                        context,
                      ).colorScheme.onSurface, // Adaptive text/icon color
                      selectedForegroundColor: Theme.of(
                        context,
                      ).colorScheme.onPrimary, // White text on selected
                      selectedBackgroundColor: Theme.of(
                        context,
                      ).colorScheme.primary, // Adaptive selected color
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      side: BorderSide(
                        color: Theme.of(context).dividerColor.withOpacity(0.3),
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                // Content
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _selectedIndex == 0
                        ? _buildTradeEntryView()
                        : _buildAllTradesView(activeAccount.id),
                  ),
                ),
              ],
            ),
    );
  }

  // Refactored _buildTradeEntryView
  Widget _buildTradeEntryView() {
    return Row(
      key: const ValueKey('trade_entry'),
      children: [
        // Left Panel - Trade Entry (Flexible instead of SizedBox)
        Flexible(
          flex: 3, // For example, 30% of the space
          child: AddTradeScreen(controller: TradeSubmissionController()),
        ),
        // Right Panel - Performance Chart
        Expanded(
          flex: 7, // For example, 70% of the space
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: const ProfitLossChart(),
          ),
        ),
      ],
    );
  }

  Widget _buildAllTradesView(int accountId) {
    return Container(
      key: const ValueKey('trades'),
      child: TradesTabView(accountId: accountId),
    );
  }
}
