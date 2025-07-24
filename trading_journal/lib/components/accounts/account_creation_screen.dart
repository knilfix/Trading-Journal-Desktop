import 'package:flutter/material.dart';
import 'package:trading_journal/models/account.dart';
import '../../services/account_service.dart';
import '../../screens/trades_screen.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  CreateAccountScreenState createState() => CreateAccountScreenState();
}

class CreateAccountScreenState extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _accountNameController = TextEditingController();
  final _balanceController = TextEditingController();
  AccountType _selectedAccountType = AccountType.demo;

  @override
  void dispose() {
    _accountNameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("New Account")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _accountNameController,
                decoration: const InputDecoration(
                  labelText: "Account Name",
                  hintText: "Enter account name",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Account name is required";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _balanceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: "Initial Balance",
                  hintText: "Enter initial balance",
                  prefixText: "\$",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Initial balance is required";
                  }
                  final balance = double.tryParse(value);
                  if (balance == null) {
                    return "Please enter a valid number";
                  }
                  if (balance < 0) {
                    return "Balance cannot be negative";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),
              DropdownButtonFormField<AccountType>(
                value: _selectedAccountType,
                decoration: const InputDecoration(
                  labelText: 'Account Type',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.account_balance),
                ),
                items: AccountType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.displayName),
                  );
                }).toList(),
                onChanged: (AccountType? value) {
                  if (value != null) {
                    setState(() {
                      _selectedAccountType = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                child: const Text("Create Account"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final account = await AccountService.instance.createAccount(
        name: _accountNameController.text,
        balance: double.parse(_balanceController.text),
        accountType: _selectedAccountType,
      );

      if (account != null) {
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => TradesScreen()),
        );
      } else {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create account. Please try again.'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }
}
