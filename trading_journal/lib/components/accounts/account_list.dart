import 'package:flutter/material.dart';
import 'package:trading_journal/components/is_active.dart';
import '../../models/account.dart';

class AccountList extends StatelessWidget {
  final List<Account> accounts;
  final Account? selectedAccount;
  final ValueChanged<Account> onSelect;
  final ValueChanged<int> onDelete;
  final int activeAccountId;

  const AccountList({
    super.key,
    required this.accounts,
    required this.selectedAccount,
    required this.onSelect,
    required this.onDelete,
    required this.activeAccountId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      itemCount: accounts.length.clamp(0, 20),
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final account = accounts[index];
        final isSelected = selectedAccount?.id == account.id;
        final isActive =
            activeAccountId != -1 &&
            account.id ==
                activeAccountId; // Check if this is the active account

        String typeLabel;
        Color typeColor;
        switch (account.accountType) {
          case AccountType.live:
            typeLabel = 'Live';
            typeColor = Colors.green.shade700;
            break;
          case AccountType.demo:
            typeLabel = 'Demo';
            typeColor = Colors.orange.shade700;
            break;
          case AccountType.backtesting:
            typeLabel = 'Backtest';
            typeColor = Colors.blue.shade700;
            break;
        }

        return Material(
          elevation: isSelected ? 3 : 1,
          borderRadius: BorderRadius.circular(12),
          shadowColor: isSelected
              ? theme.colorScheme.primary.withAlpha(13)
              : Colors.black.withAlpha(64),
          color: isSelected
              ? theme.colorScheme.primary.withAlpha(20)
              : theme.cardColor,
          child: Stack(
            children: [
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: isSelected
                      ? BorderSide(
                          color: theme.colorScheme.primary.withAlpha(77),
                          width: 1,
                        )
                      : BorderSide.none,
                ),
                selected: isSelected,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                title: Row(
                  children: [
                    if (isActive)
                      IsActive(
                        size: 8,
                        color: Colors.green.shade600,
                        withAnimation: true, // Optional pulsating animation
                        withGlow: true, // Optional subtle glow effect
                      ),
                    Expanded(
                      child: Text(
                        account.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.textTheme.titleMedium?.color,
                        ),
                      ),
                    ),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Row(
                    children: [
                      Text(
                        'Balance: ',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        '\$${account.balance.toStringAsFixed(2)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: account.balance >= 0
                              ? Colors.green.shade700
                              : theme.colorScheme.error,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: account.accountType == AccountType.live
                              ? Colors.green.withAlpha(31)
                              : Colors.blue.withAlpha(31),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          typeLabel,
                          style: TextStyle(
                            color: typeColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                trailing: IconButton(
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    color: theme.colorScheme.error.withAlpha(204),
                    size: 22,
                  ),
                  tooltip: 'Delete Account',
                  onPressed: () => onDelete(account.id),
                  splashRadius: 20,
                ),
                onTap: () => onSelect(account),
                hoverColor: theme.colorScheme.primary.withAlpha(10),
                splashColor: theme.colorScheme.primary.withAlpha(26),
              ),
            ],
          ),
        );
      },
    );
  }
}
