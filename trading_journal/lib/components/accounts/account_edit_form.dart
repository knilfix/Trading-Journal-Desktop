import 'package:flutter/material.dart';
import '../../models/account.dart';

class AccountEditForm extends StatefulWidget {
  final Account account;
  final void Function(String name, double? target, double? maxLoss)
  onSave;
  final VoidCallback onCancel;

  const AccountEditForm({
    super.key,
    required this.account,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<AccountEditForm> createState() => _AccountEditFormState();
}

class _AccountEditFormState extends State<AccountEditForm> {
  late TextEditingController _nameController;
  late TextEditingController _targetController;
  late TextEditingController _maxLossController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.account.name,
    );
    _targetController = TextEditingController(
      text: widget.account.target?.toString() ?? '',
    );
    _maxLossController = TextEditingController(
      text: widget.account.maxLoss?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    _maxLossController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Edit Account',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                tooltip: 'Cancel',
                onPressed: widget.onCancel,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Name field
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Account Name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.account_circle_outlined),
            ),
          ),
          const SizedBox(height: 20),

          // Target field
          TextFormField(
            controller: _targetController,
            decoration: const InputDecoration(
              labelText: 'Target',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.flag_outlined),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 32),

          // Target field
          TextFormField(
            controller: _maxLossController,
            decoration: const InputDecoration(
              labelText: 'Max Loss',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.flag_outlined),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 32),

          // Save button
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Save Changes'),
                  onPressed: () {
                    final name = _nameController.text.trim();
                    final targetText = _targetController.text.trim();
                    final maxLossText = _maxLossController.text
                        .trim();
                    final target = targetText.isEmpty
                        ? null
                        : double.tryParse(targetText);
                    final maxLoss = maxLossText.isEmpty
                        ? null
                        : double.tryParse(maxLossText);
                    widget.onSave(name, target, maxLoss);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
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
