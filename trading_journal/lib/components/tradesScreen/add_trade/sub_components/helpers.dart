import 'package:flutter/material.dart';

Widget buildSectionHeader(String title, BuildContext context) {
  return Text(
    title,
    style:
        Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ) ??
        TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
  );
}

void showRiskModal({
  required BuildContext context,
  required TextEditingController riskPercentageController,
  required TextEditingController riskController,
  required VoidCallback onError,
  required VoidCallback onStateUpdate,
  required double? accountBalance,
}) {
  if (accountBalance == null) {
    onError();
    return;
  }

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Set Risk Percentage'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: riskPercentageController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Percentage (%)',
                hintText: 'e.g., 1.0',
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Balance: \$${accountBalance.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final percentage = double.tryParse(riskPercentageController.text);
              if (percentage == null || percentage <= 0 || percentage > 100) {
                onError();
                return;
              }
              final riskAmount = accountBalance * (percentage / 100);
              riskController.text = riskAmount.toStringAsFixed(2);
              onStateUpdate();
              Navigator.pop(context);
            },
            child: const Text('Set'),
          ),
        ],
      );
    },
  );
}

void showError(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(child: Text(message)),
        ],
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );
}
