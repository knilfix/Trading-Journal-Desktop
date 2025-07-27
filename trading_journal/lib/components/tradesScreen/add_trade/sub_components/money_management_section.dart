import 'package:flutter/material.dart';
import 'package:trading_journal/components/tradesScreen/add_trade/modern_text_field.dart';
import 'package:trading_journal/components/tradesScreen/add_trade/trade-partials/trade_partial_modal.dart';

import 'package:trading_journal/models/account.dart';
import 'package:trading_journal/services/account_service.dart';
import './helpers.dart';

class MoneyManagementSection extends StatelessWidget {
  final TextEditingController riskController;
  final TextEditingController pnlController;
  final TextEditingController riskPercentageController;
  final TextEditingController feesController;

  final VoidCallback setStateCallback;
  final BuildContext parentContext;
  final Function(String) showErrorCallback;
  final AccountType? accountType;

  const MoneyManagementSection({
    super.key,
    required this.riskController,
    required this.pnlController,
    required this.riskPercentageController,
    required this.setStateCallback,
    required this.parentContext,
    required this.showErrorCallback,
    this.accountType,
    required this.feesController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            buildSectionHeader('Money Management', context),
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => TradePartialModal(
                    riskController: riskController,
                    pnlController: pnlController,
                  ),
                );
              },
              icon: Icon(Icons.pie_chart_outline, size: 20),
              tooltip: 'Manage partial positions',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              style: IconButton.styleFrom(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.primaryContainer.withAlpha(112),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ModernTextField(
                controller: riskController,
                label: 'Risk Amount',
                prefix: '\$',
                icon: Icons.warning_amber_outlined,
                isIconClickable: true, // This enables the clickable styling
                iconColor: Colors.orange, // Set the actual color here
                onIconTap: () => showRiskModal(
                  context: context,
                  riskPercentageController: riskPercentageController,
                  riskController: riskController,
                  onError: () => showErrorCallback(
                    'Please enter a valid percentage (0-100).',
                  ),
                  onStateUpdate: setStateCallback,
                  accountBalance:
                      AccountService.instance.activeAccount?.balance,
                ),
                iconTooltip: 'Calculate risk ', // Optional tooltip
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Required';
                  final risk = double.tryParse(value!);
                  if (risk == null) return 'Invalid number';
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ModernTextField(
                controller: pnlController,
                isPnlField: true,
                label: 'P&L',
                prefix: '\$',
                icon: Icons.account_balance_wallet_outlined,
                iconColor: Colors.blue,
                // isIconClickable defaults to false
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Required';
                  if (double.tryParse(value!) == null) return 'Invalid number';
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ModernTextField(controller: feesController, label: 'Fees'),
      ],
    );
  }
}
