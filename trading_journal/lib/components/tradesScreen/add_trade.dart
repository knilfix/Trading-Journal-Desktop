import 'package:flutter/material.dart';
import 'package:trading_journal/services/account_service.dart';
import '../../models/trade.dart';
import '../../services/trade_service.dart';
import '../../models/account.dart';
import 'package:trading_journal/components/tradesScreen/charts/profit_and_loss.dart';

class AddTradeScreen extends StatefulWidget {
  const AddTradeScreen({super.key});

  @override
  State<AddTradeScreen> createState() => _AddTradeScreenState();
}

class _AddTradeScreenState extends State<AddTradeScreen> {
  final _formKey = GlobalKey<FormState>();

  final _pairController = TextEditingController();
  final _riskController = TextEditingController();
  final _pnlController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _entryTime = DateTime.now();
  DateTime _exitTime = DateTime.now();
  TradeDirection _direction = TradeDirection.buy;
  CurrencyPair? _selectedCurrencyPair;

  @override
  void dispose() {
    _pairController.dispose();
    _riskController.dispose();
    _pnlController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left: Trade Entry Form
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.35,
          child: _buildTradeEntryForm(context),
        ),
        // Right: Performance Chart
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: ProfitLossChart(),
          ),
        ),
      ],
    );
  }

  Widget _buildTradeEntryForm(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
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
                  color: Theme.of(
                    context,
                  ).dividerColor.withOpacity(0.1),
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
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w600),
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

                    // Currency Pair with modern styling
                    _buildModernDropdown<CurrencyPair>(
                      label: 'Currency Pair',
                      value: _selectedCurrencyPair,
                      icon: Icons.currency_exchange,
                      items: CurrencyPair.values.map((pair) {
                        return DropdownMenuItem(
                          value: pair,
                          child: Text(
                            pair.symbol,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCurrencyPair = value;
                        });
                      },
                      validator: (value) => value == null
                          ? 'Please select a currency pair'
                          : null,
                    ),
                    const SizedBox(height: 20),

                    // Direction with enhanced styling
                    _buildModernDropdown<TradeDirection>(
                      label: 'Direction',
                      value: _direction,
                      icon: _direction == TradeDirection.buy
                          ? Icons.trending_up
                          : Icons.trending_down,
                      iconColor: _direction == TradeDirection.buy
                          ? Colors.green
                          : Colors.red,
                      items: TradeDirection.values.map((direction) {
                        final isBuy = direction == TradeDirection.buy;
                        return DropdownMenuItem(
                          value: direction,
                          child: Row(
                            children: [
                              Icon(
                                isBuy
                                    ? Icons.trending_up
                                    : Icons.trending_down,
                                size: 16,
                                color: isBuy
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                direction
                                    .toString()
                                    .split('.')
                                    .last
                                    .toUpperCase(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: isBuy
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => _direction = value!),
                    ),
                    const SizedBox(height: 32),

                    // Money Management Section
                    _buildSectionHeader('Money Management'),
                    const SizedBox(height: 16),

                    // Risk and PnL with modern cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildModernTextField(
                            controller: _riskController,
                            label: 'Risk Amount',
                            prefix: '\$',
                            icon: Icons.warning_amber_outlined,
                            iconColor: Colors.orange,
                            keyboardType:
                                const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Required';
                              }
                              if (double.tryParse(value!) == null) {
                                return 'Invalid number';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildModernTextField(
                            controller: _pnlController,
                            label: 'P&L',
                            prefix: '\$',
                            icon:
                                Icons.account_balance_wallet_outlined,
                            iconColor: Colors.blue,
                            keyboardType:
                                const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Required';
                              }
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

                    // Enhanced Date/Time Pickers
                    _ModernDateTimePicker(
                      label: 'Entry Time',
                      dateTime: _entryTime,
                      icon: Icons.login_outlined,
                      iconColor: Colors.green,
                      onChanged: (dt) =>
                          setState(() => _entryTime = dt),
                    ),
                    const SizedBox(height: 16),
                    _ModernDateTimePicker(
                      label: 'Exit Time',
                      dateTime: _exitTime,
                      icon: Icons.logout_outlined,
                      iconColor: Colors.red,
                      onChanged: (dt) =>
                          setState(() => _exitTime = dt),
                    ),
                    const SizedBox(height: 32),

                    // Notes Section
                    _buildSectionHeader('Notes'),
                    const SizedBox(height: 16),
                    _buildModernTextField(
                      controller: _notesController,
                      label: 'Trade Notes (Optional)',
                      icon: Icons.note_outlined,
                      maxLines: 3,
                      hintText:
                          'Add any observations or strategy notes...',
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Modern Submit Button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Theme.of(
                    context,
                  ).dividerColor.withOpacity(0.1),
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
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
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
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    String? prefix,
    String? hintText,
    IconData? icon,
    Color? iconColor,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixText: prefix,
        prefixIcon: icon != null
            ? Icon(icon, size: 20, color: iconColor)
            : null,
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  Widget _buildModernDropdown<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
    IconData? icon,
    Color? iconColor,
    String? Function(T?)? validator,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null
            ? Icon(icon, size: 20, color: iconColor)
            : null,
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      dropdownColor: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
    );
  }

  void _resetForm({bool keepCurrencyPair = true}) {
    if (!mounted) return;

    setState(() {
      _formKey.currentState?.reset();
      _riskController.clear();
      _pnlController.clear();
      _notesController.clear();
      _direction = TradeDirection.buy;
      _entryTime = DateTime.now();
      _exitTime = DateTime.now();

      // Only keep currency pair if explicitly requested
      if (!keepCurrencyPair) {
        _selectedCurrencyPair = null;
      }
    });
  }

  Future<void> _submitTrade() async {
    debugPrint('[DEBUG] Submit Trade initiated'); // Debug 1

    final activeAccount = AccountService.instance.activeAccount;

    debugPrint(
      '[DEBUG] Active Account: ${activeAccount?.id ?? "NULL"}',
    ); // Debug 2

    if (activeAccount == null) {
      debugPrint(
        '[DEBUG] No active account - showing error',
      ); // Debug 3
      _showError('No active account selected.');
      return;
    }

    if (_selectedCurrencyPair == null) {
      debugPrint(
        '[DEBUG] No currency pair selected - showing error',
      ); // Debug 4
      _showError('Please select a currency pair');
      return;
    }

    if (!_formKey.currentState!.validate()) {
      debugPrint('[DEBUG] Form validation failed'); // Debug 5
      return;
    }

    try {
      debugPrint(
        '[DEBUG] Attempting to record trade with data:',
      ); // Debug 6
      debugPrint('  - Account: ${activeAccount.id}');
      debugPrint('  - Pair: ${_selectedCurrencyPair!.symbol}');
      debugPrint('  - Risk: ${_riskController.text}');
      debugPrint('  - PnL: ${_pnlController.text}');

      final trade = await TradeService.instance.recordTrade(
        accountId: activeAccount.id,
        currencyPair: _selectedCurrencyPair!,
        direction: _direction,
        riskAmount: double.parse(_riskController.text),
        pnl: double.parse(_pnlController.text),
        entryTime: _entryTime,
        exitTime: _exitTime,
        notes: _notesController.text,
      );

      if (trade != null) {
        debugPrint(
          '[DEBUG] Trade recorded successfully: ${trade.id}',
        ); // Debug 7
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Trade recorded!')));
        // Reset the form
        if (mounted) {
          final isBacktesting =
              AccountService.instance.activeAccount?.accountType ==
              AccountType.backtesting;

          _resetForm(keepCurrencyPair: isBacktesting);
        }
        if (!mounted) {
          debugPrint(
            '[WARNING] Widget not mounted after successful trade',
          ); // Debug 8
          return;
        }
      } else {
        debugPrint('[ERROR] TradeService returned null'); // Debug 9
        if (!mounted) return;
        _showError('Failed to record trade');
      }
    } catch (e, stackTrace) {
      debugPrint('[EXCEPTION] Error recording trade: $e'); // Debug 10
      debugPrint(stackTrace.toString());
      _showError('Error: ${e.toString()}');
    }
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

// Enhanced date/time picker widget
class _ModernDateTimePicker extends StatelessWidget {
  final String label;
  final DateTime dateTime;
  final Function(DateTime) onChanged;
  final IconData? icon;
  final Color? iconColor;

  const _ModernDateTimePicker({
    required this.label,
    required this.dateTime,
    required this.onChanged,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDateTimePicker(context, dateTime);
        if (picked != null) onChanged(picked);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon!, size: 20, color: iconColor),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelMedium
                        ?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                        ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${dateTime.day}/${dateTime.month}/${dateTime.year}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }
}

Future<DateTime?> showDateTimePicker(
  BuildContext context,
  DateTime initialDate,
) async {
  final date = await showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: DateTime(2000),
    lastDate: DateTime.now(),
  );

  if (date == null) return null;

  final time = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.fromDateTime(initialDate),
  );

  if (time == null) return null;

  return DateTime(
    date.year,
    date.month,
    date.day,
    time.hour,
    time.minute,
  );
}
