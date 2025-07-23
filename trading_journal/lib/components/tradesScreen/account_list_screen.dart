import 'package:flutter/material.dart';
import '../../models/account.dart';
import '../../services/account_service.dart';
import '../../screens/trades_screen.dart';

class AccountListScreen extends StatelessWidget {
  const AccountListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Your Accounts")),
      body: ValueListenableBuilder<List<Account>>(
        valueListenable: AccountService.instance.accountsListenable,
        builder: (context, accounts, _) {
          return ListView.builder(
            itemCount: accounts.length,
            itemBuilder: (ctx, index) {
              final account = accounts[index];
              return ListTile(
                title: Text(account.accountType.toString()),
                subtitle: Text("\$${account.balance.toStringAsFixed(2)}"),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => TradesScreen()),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
