import 'package:flutter/material.dart';
import 'package:trading_journal/components/under_construction.dart';

class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String name = 'Portfolio Overview';
    final String displayMessage =
        'Portfolio management and tracking ';
    final Icon icon = Icon(
      Icons.pie_chart,
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
