import 'package:flutter/material.dart';
import '../../services/account_service.dart';
import 'add_trade.dart';
import 'account_metrics.dart';
import 'trades_tab_view.dart';

class TradesScreen extends StatefulWidget {
  const TradesScreen({super.key});

  @override
  State<TradesScreen> createState() => _TradesScreenState();
}

class _TradesScreenState extends State<TradesScreen> {
  int _selectedIndex = 0;

  final List<TabItem> _tabs = [
    const TabItem(icon: Icons.dashboard_outlined),
    const TabItem(icon: Icons.list_alt),
  ];

  @override
  Widget build(BuildContext context) {
    final activeAccount =
        AccountService.instance.activeAccount;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: activeAccount == null
          ? const Center(
              child: Text(
                'No active account selected',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : Column(
              children: [
                // Modern Floating Tab Bar
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Center(
                    child: ModernFloatingTabs(
                      selectedIndex: _selectedIndex,
                      onTabSelected: (index) {
                        setState(() {
                          _selectedIndex = index;
                        });
                      },
                      tabs: _tabs,
                    ),
                  ),
                ),

                // Content
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(
                      milliseconds: 300,
                    ),
                    child: _selectedIndex == 0
                        ? _buildDashboardView()
                        : _buildAllTradesView(
                            activeAccount.id,
                          ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildDashboardView() {
    return Row(
      key: const ValueKey('dashboard'),
      children: [
        // Left Panel - Trade Entry (25%)
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.25,
          child: const AddTradeScreen(),
        ),
        const VerticalDivider(
          width: 1,
          thickness: 1,
          color: Colors.grey,
        ),
        // Right Panel - Metrics (75%)
        const Expanded(child: AccountMetricsWidget()),
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

// Tab item class (same as in the floating tabs widget)
class TabItem {
  final IconData icon;
  final String? title;

  const TabItem({required this.icon, this.title});
}

// Modern Floating Tabs Widget (embedded for completeness)
class ModernFloatingTabs extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabSelected;
  final List<TabItem> tabs;

  const ModernFloatingTabs({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
    required this.tabs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          final isSelected = index == selectedIndex;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => onTabSelected(index),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF4A90E2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        tab.icon,
                        size: 18,
                        color: isSelected
                            ? Colors.white
                            : Colors.grey[400],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        tab.title ?? "",
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : Colors.grey[400],
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
