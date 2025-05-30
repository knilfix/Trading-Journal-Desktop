import 'package:flutter/material.dart';
import '../../services/account_service.dart';
import '../../models/account.dart';

class AccountManagementScreen extends StatefulWidget {
  const AccountManagementScreen({super.key});

  @override
  State<AccountManagementScreen> createState() =>
      _AccountManagementScreenState();
}

class _AccountManagementScreenState extends State<AccountManagementScreen> {
  final AccountService _accountService = AccountService.instance;
  Account? _selectedAccount;

  void _selectAccount(Account account) {
    setState(() {
      _selectedAccount = account;
    });
  }

  void _deleteAccount(int id) async {
    await _accountService.deleteAccount(id);
    setState(() {
      if (_selectedAccount?.id == id) {
        _selectedAccount = null;
      }
    });
  }

  Future<void> _toggleActiveAccount() async {
    if (_selectedAccount == null) return;

    if (_accountService.activeAccount?.id == _selectedAccount?.id) {
      _accountService.clearActiveAccount();
    } else {
      await _accountService.setActiveAccount(_selectedAccount!.id);
    }

    if (mounted) {
      setState(() {}); // Trigger UI update
    }
  }

  void _createAccount(
    BuildContext context,
    double balance,
    AccountType accountType,
    String name,
  ) async {
    if (balance <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Balance must be greater than 0'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    final newAccount = await _accountService.createAccount(
      balance: balance,
      accountType: accountType,
      name: name,
    );

    if (newAccount != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Account created successfully!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }

      Navigator.pop(context);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create account. Select Active User'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = _accountService.activeAccount?.id == _selectedAccount?.id;

    return Scaffold(
      appBar: AppBar(title: const Text('Account Management')),
      body: Row(
        children: [
          // Left Panel - Account List
          ValueListenableBuilder<List<Account>>(
            valueListenable: _accountService.accountsListenable,
            builder: (context, accounts, child) {
              return Container(
                width: MediaQuery.of(context).size.width * 0.25,
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: theme.dividerColor.withOpacity(0.1),
                    ),
                  ),
                ),
                child: ListView.builder(
                  itemCount: accounts.length.clamp(0, 20), // Limit to 20
                  itemBuilder: (context, index) {
                    final account = accounts[index];
                    final isSelected = _selectedAccount?.id == account.id;

                    return ListTile(
                      selected: isSelected,
                      title: Text('Account #${account.name}'),
                      subtitle: Text('Balance: \$${account.balance}'),
                      trailing: IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: theme.colorScheme.error,
                        ),
                        onPressed: () => _deleteAccount(account.id),
                      ),
                      onTap: () => _selectAccount(account),
                    );
                  },
                ),
              );
            },
          ),

          // Right Panel - Account Details
          Expanded(
            child: _selectedAccount == null
                ? Center(child: Text('Select an account to view details'))
                : Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Account Details',
                          style: theme.textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 16),
                        Text('Account Name: ${_selectedAccount!.name}'),
                        Text('Balance: \$${_selectedAccount!.balance}'),
                        Text('Account Type: ${_selectedAccount!.accountType}'),
                        Text('Created At: ${_selectedAccount!.createdAt}'),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                // Logic to update account (implement later)
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              child: const Text('Update Account'),
                            ),

                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _toggleActiveAccount,
                                icon: Icon(
                                  isActive
                                      ? Icons.person_remove
                                      : Icons.person_add,
                                ),
                                label: Text(
                                  isActive ? 'Deactivate' : 'Activate',
                                ),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  backgroundColor: isActive
                                      ? Colors.orange
                                      : Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              AccountType selectedAccountType = AccountType
                  .backtesting; // Default selection // Default selection
              TextEditingController balanceController = TextEditingController();
              TextEditingController nameController = TextEditingController();

              return AlertDialog(
                backgroundColor: theme.dialogBackgroundColor, // Match theme
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Text(
                  'Add New Account',
                  style: theme.textTheme.titleLarge,
                ),
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
                          selectedAccountType = value;
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
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          minimumSize: const Size(120, 48),
                        ),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _createAccount(
                            context,
                            double.tryParse(balanceController.text) ?? 0.0,
                            selectedAccountType,
                            nameController.text,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
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
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        prefixIcon: Icon(icon),
      ),
    );
  }
}
