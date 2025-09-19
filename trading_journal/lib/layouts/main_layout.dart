import 'package:flutter/material.dart';
import 'package:trading_journal/screens/analytics_screen.dart';
import 'package:trading_journal/screens/demo_screen.dart';
import 'package:trading_journal/screens/calendar/table_calendar.dart';
import '../components/layout/sidebar.dart';
import '../models/navigation_item.dart';
import '../screens/dashboard_screen.dart';
import '../screens/settings_screen.dart';
import '../components/accounts/account_selection_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;
  bool _isExpanded = false;

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
      label: 'Dashboard',
      screen: const DashboardScreen(),
    ),
    NavigationItem(
      icon: Icons.show_chart_outlined,
      selectedIcon: Icons.show_chart,
      label: 'Trades',
      screen: const AccountSelectionScreen(),
    ),
    NavigationItem(
      icon: Icons.pie_chart_outline,
      selectedIcon: Icons.pie_chart,
      label: 'Analytics',
      screen: const AnalyticsScreen(),
    ),
    NavigationItem(
      icon: Icons.analytics_outlined,
      selectedIcon: Icons.analytics,
      label: 'Calendar',
      screen: const TradeCalendar(),
    ),
    NavigationItem(
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      label: 'Settings',
      screen: const SettingsScreen(),
    ),
    NavigationItem(
      icon: Icons.bug_report_outlined,
      selectedIcon: Icons.bug_report,
      label: 'Demos',
      screen: const DemoScreen(),
    ),
  ];

  void _toggleSidebar() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  void _onItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentScreen = _navigationItems[_selectedIndex].screen;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Row(
        children: [
          Sidebar(
            isExpanded: _isExpanded,
            selectedIndex: _selectedIndex,
            navigationItems: _navigationItems,
            onItemSelected: _onItemSelected,
            onToggleSidebar: _toggleSidebar,
            theme: theme,
          ),
          Expanded(
            child: Container(
              color: theme.scaffoldBackgroundColor,
              child: Column(children: [Expanded(child: currentScreen)]),
            ),
          ),
        ],
      ),
    );
  }
}
