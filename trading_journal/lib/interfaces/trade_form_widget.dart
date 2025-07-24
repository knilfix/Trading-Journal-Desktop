import 'package:flutter/material.dart';
import 'package:trading_journal/components/tradesScreen/add_trade/trade_submission_controller.dart';

abstract class TradeFormWidget extends StatefulWidget {
  final TradeSubmissionController controller;
  final double widht;

  const TradeFormWidget({
    super.key,
    required this.controller,
    this.widht = 0.35,
  });

  @override
  TradeFormWidgetState createState();
}

abstract class TradeFormWidgetState<T extends TradeFormWidget>
    extends State<T> {
  void submitTrade(); // UI must implement this to collect and submit data
  void resetForm(); // UI must implement this to reset the form
}
