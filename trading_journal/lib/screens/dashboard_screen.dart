import 'package:flutter/material.dart';
import 'package:trading_journal/components/under_construction.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String name = 'Dashboard';
    final String displayMessage =
        'DashBoard metrics and Visualizations ';
    final Icon icon = Icon(
      Icons.dashboard,
      size: 64,
      color: Colors.grey,
    );
    return UnderConstructionScreen(
      pageName: name,
      message: displayMessage,
      pageIcon: icon,
    );
  }
}
