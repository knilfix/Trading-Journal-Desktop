import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'trade_list.dart';
import '../../services/trade_service.dart';
import '../../services/account_service.dart';
import '../../models/trade.dart';
import '../../models/account.dart';

class TradesTabView extends StatefulWidget {
  final int accountId;

  const TradesTabView({super.key, required this.accountId});

  @override
  State<TradesTabView> createState() => _TradesTabViewState();
}

class _TradesTabViewState extends State<TradesTabView> {
  @override
  Widget build(BuildContext context) {
    final account = AccountService.instance.getAccountById(widget.accountId);
    final startBalance = account?.startBalance;

    return Consumer<TradeService>(
      builder: (context, tradeService, child) {
        return FutureBuilder<List<Trade>>(
          future: tradeService.getTradesForAccountAsync(widget.accountId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            return TradeList(
              trades: snapshot.data ?? [],
              initialBalance: startBalance ?? 0.0,
              accountType: account?.accountType ?? AccountType.demo,
            );
          },
        );
      },
    );
  }
}
