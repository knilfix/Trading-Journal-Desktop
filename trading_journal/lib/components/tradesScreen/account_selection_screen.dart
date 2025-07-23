import 'package:flutter/material.dart';
import 'package:trading_journal/services/account_service.dart';
import '../../screens/trades_screen.dart';

class AccountSelectionScreen extends StatelessWidget {
  const AccountSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final accountService = AccountService.instance;
    final activeAccount = accountService.activeAccount;
    final hasAccounts = accountService.accounts.isNotEmpty;

    // If active account exists, go straight to trades
    if (activeAccount != null) {
      return const TradesScreen();
    }

    // Determine the appropriate message based on account state
    final (
      String headline,
      String submessage,
      String buttonText,
    ) = hasAccounts
        ? (
            'Activate Your Account',
            'You have existing accounts.\nPlease select one to activate.',
            'Manage Accounts',
          )
        : (
            'Create Your First Account',
            'No accounts found.\nCreate and activate an account to get started.',
            'Create Account',
          );

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Visual icon
              Icon(
                Icons.account_balance_wallet,
                size: 64,
                color: Theme.of(
                  context,
                ).colorScheme.primary,
              ),
              const SizedBox(height: 24),

              // Main message
              Text(
                headline,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // Submessage
              Text(
                submessage,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                      color: Theme.of(context).hintColor,
                    ),
              ),
              const SizedBox(height: 32),

              // Action button
              FilledButton(
                onPressed: () {},
                child: Text(buttonText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
