import 'package:flutter/material.dart';
import 'package:trading_journal/components/accounts/account_edit_form.dart';
import '../../services/account_service.dart';
import '../../models/account.dart';
import '../../components/accounts/account_list.dart';
import '../../components/accounts/account_details.dart';
import '../../components/accounts/add_account_dialog.dart';

class AccountManagementScreen extends StatefulWidget {
  const AccountManagementScreen({super.key});

  @override
  State<AccountManagementScreen> createState() =>
      _AccountManagementScreenState();
}

class _AccountManagementScreenState extends State<AccountManagementScreen> {
  final AccountService _accountService = AccountService.instance;

  Account? _selectedAccount;
  bool _isEditing = false;

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
    int? activeAccountid = _accountService.activeAccount?.id;

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
                child: AccountList(
                  accounts: accounts,
                  selectedAccount: _selectedAccount,
                  activeAccountId: activeAccountid ?? -1,
                  onSelect: _selectAccount,
                  onDelete: _deleteAccount,
                ),
              );
            },
          ),

          // Right Panel - Account Details
          Expanded(
            child: _selectedAccount == null
                ? Center(child: Text('Select an account to view details'))
                : _isEditing
                ? AccountEditForm(
                    account: _selectedAccount!,
                    onSave: (name, target, maxLoss) async {
                      await _accountService.updateAccount(
                        id: _selectedAccount!.id,
                        name: name,
                        target: target,
                        maxLoss: maxLoss,
                      );
                      setState(() {
                        _selectedAccount = _accountService.getAccountById(
                          _selectedAccount!.id,
                        );
                        _isEditing = false;
                      });

                      //show confirmation
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Changes saved')),
                      );
                    },
                    onCancel: () => setState(() => _isEditing = false),
                  )
                : AccountDetails(
                    account: _selectedAccount!,
                    isActive: isActive,
                    onToggleActive: _toggleActiveAccount,
                    onUpdateTarget: (target) async {},
                    onEdit: () => setState(() => _isEditing = true),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AddAccountDialog(
                onSubmit: (balance, accountType, name) {
                  _createAccount(context, balance, accountType, name);
                },
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
