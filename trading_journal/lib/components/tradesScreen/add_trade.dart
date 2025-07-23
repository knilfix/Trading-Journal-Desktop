import 'package:flutter/material.dart';
import 'package:trading_journal/services/account_service.dart';
import 'package:trading_journal/models/trade.dart';

import 'package:trading_journal/services/trade_service.dart';
import 'package:trading_journal/components/tradesScreen/add_trade/modern_text_field.dart';
import 'package:trading_journal/components/tradesScreen/add_trade/modern_dropdown.dart';
import 'package:trading_journal/components/tradesScreen/add_trade/modern_date_time_picker.dart';

class AddTradeScreen extends StatefulWidget {
  final double width;
  const AddTradeScreen({super.key, this.width = 0.25});

  @override
  State<AddTradeScreen> createState() => _AddTradeScreenState();
}

class _AddTradeScreenState extends State<AddTradeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _riskController = TextEditingController();
  final _pnlController = TextEditingController();
  final _notesController = TextEditingController();
  final _riskPercentageController = TextEditingController();

  DateTime _entryTime = DateTime.now();
  DateTime _exitTime = DateTime.now();
  TradeDirection _direction = TradeDirection.buy;
  CurrencyPair? _selectedCurrencyPair;
  CurrencyPair? _lastSelectedCurrencyPair;
  TradeDirection _lastDirection = TradeDirection.buy;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final activeAccount = AccountService.instance.activeAccount;
    if (activeAccount != null) {
      final lastPercentage =
          double.tryParse(_riskPercentageController.text) ??
          1.0; // Default to 1.0% if null
      final newRiskAmount = activeAccount.balance * (lastPercentage / 100);
      setState(() {
        _riskController.text = newRiskAmount.toStringAsFixed(2);
      });
    } else {
      setState(() {
        _riskController.text = '0.00'; // Default if no account
      });
    }
  }

  @override
  void dispose() {
    _riskController.dispose();
    _pnlController.dispose();
    _notesController.dispose();
    _riskPercentageController.dispose();
    super.dispose();
  }

  void _showRiskModal() {
    final activeAccount = AccountService.instance.activeAccount;
    if (activeAccount == null) {
      _showError('No active account selected.');
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
                controller: _riskPercentageController,
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
                'Balance: \$${activeAccount.balance.toStringAsFixed(2)}',
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
                final percentage = double.tryParse(
                  _riskPercentageController.text,
                );
                if (percentage == null || percentage <= 0 || percentage > 100) {
                  _showError('Please enter a valid percentage (0-100).');
                  return;
                }
                final riskAmount = activeAccount.balance * (percentage / 100);
                setState(() {
                  _riskController.text = riskAmount.toStringAsFixed(2);
                });
                Navigator.pop(context);
              },
              child: const Text('Set'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (MediaQuery.of(context).size.width * widget.width).clamp(200, 400),

      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.white
            : Theme.of(context).colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: Theme.of(context).dividerColor.withAlpha(25),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.add_circle_outline,
                  size: 24,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 12),
                Text(
                  'New Trade',
                  style:
                      Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ) ??
                      const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
          // Form Content
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Trade Setup Section
                    _buildSectionHeader('Trade Setup'),
                    const SizedBox(height: 16),
                    ModernDropDown<CurrencyPair>(
                      label: 'Currency Pair',
                      value: _selectedCurrencyPair,
                      icon: Icons.currency_exchange,
                      items: CurrencyPair.values.map((pair) {
                        return DropdownMenuItem(
                          value: pair,
                          child: Text(
                            pair.symbol,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCurrencyPair = value;
                          if (value != null) _lastSelectedCurrencyPair = value;
                        });
                      },
                      validator: (value) => value == null
                          ? 'Please select a currency pair'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    _buildSectionHeader('Direction'),
                    const SizedBox(height: 16),
                    SegmentedButton<TradeDirection>(
                      segments: TradeDirection.values.map((direction) {
                        final isBuy = direction == TradeDirection.buy;
                        return ButtonSegment<TradeDirection>(
                          value: direction,
                          icon: Icon(
                            isBuy ? Icons.trending_up : Icons.trending_down,
                            size: 48,
                            color: isBuy ? Colors.green : Colors.red,
                          ),
                          label: Text(
                            direction.toString().split('.').last.toUpperCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: isBuy ? Colors.green : Colors.red,
                            ),
                          ),
                        );
                      }).toList(),
                      selected: {_direction},
                      onSelectionChanged: (newSelection) {
                        setState(() {
                          _direction = newSelection.first;
                          _lastDirection = newSelection.first;
                        });
                      },
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.resolveWith((
                          states,
                        ) {
                          if (states.contains(WidgetState.selected)) {
                            return Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.1);
                          }
                          return Theme.of(context).colorScheme.surface;
                        }),
                        foregroundColor: WidgetStateProperty.all(
                          Theme.of(context).colorScheme.onSurface,
                        ),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Money Management Section
                    _buildSectionHeader('Money Management'),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ModernTextField(
                            controller: _riskController,
                            label: 'Risk Amount',
                            prefix: '\$',
                            icon: Icons.warning_amber_outlined,
                            iconColor: Colors.orange,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (value) {
                              if (value?.isEmpty ?? true) return 'Required';
                              if (double.tryParse(value!) == null) {
                                return 'Invalid number';
                              }
                              return null;
                            },
                            onIconTap: _showRiskModal,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ModernTextField(
                            controller: _pnlController,
                            label: 'P&L',
                            prefix: '\$',
                            icon: Icons.account_balance_wallet_outlined,
                            iconColor: Colors.blue,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (value) {
                              if (value?.isEmpty ?? true) return 'Required';
                              if (double.tryParse(value!) == null) {
                                return 'Invalid number';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // Timing Section
                    _buildSectionHeader('Timing'),
                    const SizedBox(height: 16),
                    ModernDateTimePicker(
                      label: 'Entry Time',
                      dateTime: _entryTime,
                      icon: Icons.login_outlined,
                      iconColor: Colors.green,
                      onChanged: (dt) => setState(() {
                        _entryTime = dt;
                        _exitTime = dt;
                      }),
                    ),
                    const SizedBox(height: 16),
                    ModernDateTimePicker(
                      label: 'Exit Time',
                      dateTime: _exitTime,
                      icon: Icons.logout_outlined,
                      iconColor: Colors.red,
                      onChanged: (dt) => setState(() => _exitTime = dt),
                    ),
                    const SizedBox(height: 32),
                    // Notes Section
                    _buildSectionHeader('Notes'),
                    const SizedBox(height: 16),
                    ModernTextField(
                      controller: _notesController,
                      label: 'Trade Notes (Optional)',
                      icon: Icons.note_outlined,
                      maxLines: 3,
                      hintText: 'Add any observations or strategy notes...',
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Submit Button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).dividerColor.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _submitTrade,
                icon: const Icon(Icons.save_outlined),
                label: const Text(
                  'Record Trade',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
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

  Future<void> _submitTrade() async {
    debugPrint('[DEBUG] Submit Trade initiated');

    final activeAccount = AccountService.instance.activeAccount;

    debugPrint('[DEBUG] Active Account: ${activeAccount?.id ?? "NULL"}');

    if (activeAccount == null) {
      debugPrint('[DEBUG] No active account - showing error');
      _showError('No active account selected.');
      return;
    }

    if (_selectedCurrencyPair == null) {
      debugPrint('[DEBUG] No currency pair selected - showing error');
      _showError('Please select a currency pair');
      return;
    }

    if (!_formKey.currentState!.validate()) {
      debugPrint('[DEBUG] Form validation failed');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fix the errors in the form')),
      );
      return;
    }

    try {
      debugPrint('[DEBUG] Attempting to record trade with data:');
      debugPrint('  - Account: ${activeAccount.id}');
      debugPrint('  - Pair: ${_selectedCurrencyPair!.symbol}');
      debugPrint('  - Risk: ${_riskController.text}');
      debugPrint('  - PnL: ${_pnlController.text}');
      debugPrint('  - Entry Time: $_entryTime');

      final riskAmount = double.parse(_riskController.text);
      final pnl = double.parse(_pnlController.text);
      final trade = await TradeService.instance.recordTrade(
        accountId: activeAccount.id,
        currencyPair: _selectedCurrencyPair!,
        direction: _direction,
        riskAmount: riskAmount,
        pnl: pnl,
        entryTime: _entryTime,
        exitTime: _exitTime,
        notes: _notesController.text,
      );
      if (trade != null) {
        debugPrint('[DEBUG] Trade recorded successfully: ${trade.id}');
        // Update account balance based on trade outcome
        final newBalance = activeAccount.balance + pnl - riskAmount;
        AccountService.instance.updateAccountBalance(
          activeAccount.id,
          newBalance,
        );

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Trade recorded!')));
        if (mounted) {
          _resetForm();
        }
        if (!mounted) {
          debugPrint('[WARNING] Widget not mounted after successful trade');
          return;
        }
      } else {
        debugPrint('[ERROR] TradeService returned null');
        if (!mounted) return;
        _showError('Failed to record trade');
      }
    } catch (e, stackTrace) {
      debugPrint('[EXCEPTION] Error recording trade: $e');
      debugPrint(stackTrace.toString());
      _showError('Error: ${e.toString()}');
    }
  }

  void _resetForm() {
    if (!mounted) return;

    final activeAccount = AccountService.instance.activeAccount;
    if (activeAccount != null) {
      //recalculate risk based on last percentage..default is 1%
      final lastPercentage =
          double.tryParse(_riskPercentageController.text) ?? 1.0;
      final newRiskAmount = activeAccount.balance * lastPercentage / 100.0;
      _riskController.text = newRiskAmount.toStringAsFixed(2);
      _riskPercentageController.clear();
    }

    setState(() {
      _formKey.currentState?.reset();
      _pnlController.clear();
      _notesController.clear();
      _direction = _lastDirection; // Persist last direction
      _entryTime = DateTime.now();
      _exitTime = DateTime.now();
      _selectedCurrencyPair =
          _lastSelectedCurrencyPair ??
          _selectedCurrencyPair; // Persist last pair
    });
  }

  void _showError(String message) {
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
}
