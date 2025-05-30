import 'package:flutter/material.dart';
import 'package:trading_journal/components/under_construction.dart';

// screens/analytics_screen.dart
class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String name = 'Trading Analytics';
    final String displayMessage =
        'Advanced trading analytics and performance metrics ';
    final Icon icon = Icon(
      Icons.analytics,
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
