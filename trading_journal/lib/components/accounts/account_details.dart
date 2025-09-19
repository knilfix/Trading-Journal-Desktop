import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/account.dart';

class AccountDetails extends StatelessWidget {
  final Account account;
  final bool isActive;
  final VoidCallback onToggleActive;
  final Future<void> Function(double?) onUpdateTarget;
  final VoidCallback onEdit;

  const AccountDetails({
    super.key,
    required this.account,
    required this.isActive,
    required this.onToggleActive,
    required this.onUpdateTarget,
    required this.onEdit,
  });

  String getAccountTypeLabel(AccountType type) {
    switch (type) {
      case AccountType.live:
        return 'Live';
      case AccountType.demo:
        return 'Demo';
      case AccountType.backtesting:
        return 'Backtest';
    }
  }

  Color getAccountTypeColor(AccountType type) {
    switch (type) {
      case AccountType.live:
        return Colors.green.shade700;
      case AccountType.demo:
        return Colors.orange.shade700;
      case AccountType.backtesting:
        return Colors.blue.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with title and (future) edit button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Account Details',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit Account',
                onPressed: onEdit,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Account name and type badge
          Row(
            children: [
              Expanded(
                child: Text(
                  account.name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: getAccountTypeColor(account.accountType).withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  getAccountTypeLabel(account.accountType),
                  style: TextStyle(
                    color: getAccountTypeColor(account.accountType),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (isActive) ...[
                const SizedBox(width: 10),
                Chip(
                  label: const Text('Active'),
                  backgroundColor: Colors.green.withAlpha(38),
                  labelStyle: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                  avatar: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 18,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ],
            ],
          ),
          const Divider(height: 32, thickness: 1.2),

          // Balance
          Row(
            children: [
              const Icon(Icons.account_balance_wallet_outlined, size: 20),
              const SizedBox(width: 8),
              Text('Balance:', style: theme.textTheme.bodyMedium),
              const SizedBox(width: 8),
              Text(
                NumberFormat.simpleCurrency().format(account.balance),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: account.balance >= 0
                      ? Colors.green.shade700
                      : theme.colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Created at
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 18),
              const SizedBox(width: 8),
              Text('Created:', style: theme.textTheme.bodyMedium),
              const SizedBox(width: 8),
              Text(
                account.createdAt != null
                    ? DateFormat.yMMMd().format(account.createdAt!)
                    : 'N/A',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Target field
          Row(
            children: [
              const Icon(Icons.flag_outlined, size: 20),
              const SizedBox(width: 8),
              Text('Target:', style: theme.textTheme.bodyMedium),
              const SizedBox(width: 8),
              Text(
                NumberFormat.simpleCurrency().format(account.target ?? 0),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.blueGrey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Target field
          Row(
            children: [
              const Icon(Icons.flag_outlined, size: 20),
              const SizedBox(width: 8),
              Text('Max Loss:', style: theme.textTheme.bodyMedium),
              const SizedBox(width: 8),
              Text(
                NumberFormat.simpleCurrency().format(account.maxLoss ?? 0),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.blueGrey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Activate/Deactivate button
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onToggleActive,
                  icon: Icon(isActive ? Icons.person_remove : Icons.person_add),
                  label: Text(isActive ? 'Deactivate' : 'Activate'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: isActive ? Colors.orange : Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
