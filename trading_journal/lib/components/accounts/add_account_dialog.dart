import 'package:flutter/material.dart';
import '../../models/account.dart';

class AddAccountDialog extends StatefulWidget {
  final void Function(double balance, AccountType accountType, String name)
  onSubmit;

  const AddAccountDialog({super.key, required this.onSubmit});

  @override
  State<AddAccountDialog> createState() => _AddAccountDialogState();
}

class _AddAccountDialogState extends State<AddAccountDialog> {
  AccountType selectedAccountType = AccountType.backtesting;
  final TextEditingController balanceController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  @override
  void dispose() {
    balanceController.dispose();
    nameController.dispose();
    super.dispose();
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        prefixIcon: Icon(icon),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      backgroundColor: DialogTheme.of(context).backgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Add New Account', style: theme.textTheme.titleLarge),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
            controller: nameController,
            label: 'Account Name',
            icon: Icons.account_circle_outlined,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: balanceController,
            label: 'Initial Balance',
            icon: Icons.account_balance_wallet_outlined,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<AccountType>(
            decoration: InputDecoration(
              labelText: 'Account Type',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.category_outlined),
            ),
            value: selectedAccountType,
            onChanged: (AccountType? value) {
              if (value != null) {
                setState(() {
                  selectedAccountType = value;
                });
              }
            },
            items: AccountType.values.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(type.displayName),
              );
            }).toList(),
          ),
        ],
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.onSurface,
                minimumSize: const Size(120, 48),
              ),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final balance = double.tryParse(balanceController.text) ?? 0.0;
                final name = nameController.text;
                widget.onSubmit(balance, selectedAccountType, name);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                minimumSize: const Size(120, 48),
              ),
              child: const Text('Add Account'),
            ),
          ],
        ),
      ],
    );
  }
}
