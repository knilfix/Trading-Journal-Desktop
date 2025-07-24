import 'package:flutter/material.dart';
import 'package:trading_journal/components/accounts/account_metrics.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: AccountMetricsWidget(),
        ),
      ),
    );
  }
}
