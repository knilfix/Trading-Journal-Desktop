import 'package:flutter/material.dart';
import 'package:trading_journal/components/under_construction.dart';

class TradesScreen extends StatelessWidget {
  const TradesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String name = 'Trading History';
    final String displayMessage =
        'Trade logs and history tracking ';
    final Icon icon = Icon(
      Icons.show_chart,
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
