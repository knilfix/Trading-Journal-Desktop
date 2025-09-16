import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:trading_journal/components/tradesScreen/add_trade/sub_components/helpers.dart';
import 'package:trading_journal/components/tradesScreen/add_trade/sub_components/money_management_section.dart';
import 'package:trading_journal/components/tradesScreen/add_trade/trade_submission_controller.dart';
import 'package:trading_journal/models/trade_screenshot.dart';
import 'package:trading_journal/services/account_service.dart';
import 'package:trading_journal/models/trade.dart';
import 'package:trading_journal/components/tradesScreen/add_trade/modern_text_field.dart';
import 'package:trading_journal/components/tradesScreen/add_trade/modern_dropdown.dart';
import 'package:trading_journal/components/tradesScreen/add_trade/modern_date_time_picker.dart';

class AddTradeScreen extends StatefulWidget {
  final double width;
  final TradeSubmissionController controller;
  const AddTradeScreen({
    super.key,
    this.width = 0.35,
    required this.controller,
  });

  @override
  State<AddTradeScreen> createState() => _AddTradeScreenState();
}

class _AddTradeScreenState extends State<AddTradeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _riskController = TextEditingController();
  final _pnlController = TextEditingController();
  final _notesController = TextEditingController();
  final _riskPercentageController = TextEditingController();
  final _feesController = TextEditingController();
  bool _isSubmitting = false;
  bool _isResetting = false; // Flag to skip didChangeDependencies
  double? _latestBalance; // Store latest balance

  DateTime _entryTime = DateTime.now();
  DateTime _exitTime = DateTime.now();
  TradeDirection _direction = TradeDirection.buy;
  CurrencyPair? _selectedCurrencyPair;
  CurrencyPair? _lastSelectedCurrencyPair;
  TradeDirection _lastDirection = TradeDirection.buy;
  double _lastRiskPercentage = 1.0; // Default risk percentage of 1%
  double _lastFees = 0.0;
  final List<TradeScreenshot> _screenshots = [];
  // Possible timeframes for a trade
  List<String> timeframes = [
    '1m',
    '5m',
    '15m',
    '30m',
    '1h',
    '2h',
    '4h',
    'D',
    'W',
    'M',
  ];

  @override
  void initState() {
    super.initState();
    _feesController.text = _lastFees.toStringAsFixed(2);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isResetting) {
      debugPrint('[DEBUG] Skipping didChangeDependencies due to reset');
      return;
    }
    debugPrint('[DEBUG] didChangeDependencies called');
    final activeAccount = AccountService.instance.activeAccount;
    if (activeAccount != null) {
      final newRiskAmount = activeAccount.balance * (_lastRiskPercentage / 100);
      setState(() {
        _riskController.text = newRiskAmount.toStringAsFixed(2);
        _pnlController.text = (-newRiskAmount).toStringAsFixed(2);
      });
    } else {
      setState(() {
        _riskController.text = '0.00';
        _pnlController.text = '0.00';
      });
    }
  }

  @override
  void dispose() {
    _riskController.dispose();
    _pnlController.dispose();
    _notesController.dispose();
    _riskPercentageController.dispose();
    _feesController.dispose();
    super.dispose();
  }

  Future<void> _showTimeframeDialogAndPickImage() async {
    String? selectedTimeframe;

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Timeframe'),
          content: SingleChildScrollView(
            child: ListBody(
              children: timeframes.map((timeframe) {
                return ListTile(
                  title: Text(timeframe),
                  onTap: () {
                    selectedTimeframe = timeframe;
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );

    // If a timeframe was selected, proceed to pick the image
    if (selectedTimeframe != null) {
      await _captureScreenshot(selectedTimeframe!);
    }
  }

  Future<void> _captureScreenshot(String timeframe) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.single.path != null) {
        final newFile = File(result.files.single.path!);
        setState(() {
          _screenshots.add(
            TradeScreenshot(file: newFile, timeframe: timeframe),
          );
        });
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: ${e.toString()}')),
      );
    }
  }

  void _removeScreenshot(int index) {
    setState(() {
      _screenshots.removeAt(index);
    });
  }

  void _resetForm({required double updatedBalance}) {
    if (!mounted) return;

    debugPrint('[DEBUG] Using updated balance in resetForm: $updatedBalance');
    final newRiskAmount = updatedBalance * (_lastRiskPercentage / 100);
    debugPrint(
      '[DEBUG] Calculated new risk amount: ${newRiskAmount.toStringAsFixed(2)}',
    );

    setState(() {
      _isResetting = true;
      _riskController.clear();
      _riskController.text = newRiskAmount.toStringAsFixed(2);
      debugPrint(
        '[DEBUG] After setting riskController: ${_riskController.text}',
      );
      _pnlController.text = (-newRiskAmount).toStringAsFixed(2);
      _riskPercentageController.clear();
      _notesController.clear();
      _direction = _lastDirection;
      _entryTime = DateTime.now();
      _exitTime = DateTime.now();
      _selectedCurrencyPair =
          _lastSelectedCurrencyPair ?? _selectedCurrencyPair;
      _formKey.currentState?.reset(); // Moved to end
      // Re-set controllers to persist after Form.reset
      _riskController.text = newRiskAmount.toStringAsFixed(2);
      _pnlController.text = (-newRiskAmount).toStringAsFixed(2);
      _feesController.text = _lastFees.toStringAsFixed(2);
      _screenshots.clear();
      _isResetting = false;

      debugPrint(
        '[DEBUG] Risk amount field after reset: ${_riskController.text}',
      );
    });
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
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTradeSetupSection(),
                    const SizedBox(height: 32),
                    MoneyManagementSection(
                      riskController: _riskController,
                      pnlController: _pnlController,
                      riskPercentageController: _riskPercentageController,
                      feesController: _feesController,
                      setStateCallback: () {
                        debugPrint('[DEBUG] setStateCallback triggered');
                        setState(() {});
                      },
                      parentContext: context,
                      showErrorCallback: (message) =>
                          showError(context, message),
                      accountType:
                          AccountService.instance.activeAccount?.accountType,
                      // Pass updated balance
                    ),
                    const SizedBox(height: 32),
                    _buildTimingSection(),
                    const SizedBox(height: 32),
                    _buildNotesSection(),
                    const SizedBox(height: 32),
                    _buildScreenShotSection(),
                  ],
                ),
              ),
            ),
          ),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Future<void> _submitTrade() async {
    if (_isSubmitting) {
      debugPrint('Trade submission already in progress');
      return;
    }
    setState(() => _isSubmitting = true);

    try {
      if (!_formKey.currentState!.validate()) {
        debugPrint('[DEBUG] Form validation failed');
        showError(context, 'Please fix the errors in the form');
        return;
      }

      final activeAccount = AccountService.instance.activeAccount;
      if (activeAccount == null) {
        showError(context, 'No active account selected.');
        return;
      }
      if (_selectedCurrencyPair == null) {
        showError(context, 'Please select a currency pair');
        return;
      }

      _lastRiskPercentage =
          double.tryParse(_riskPercentageController.text) ??
          _lastRiskPercentage;

      final fees = double.tryParse(_feesController.text) ?? 0.0;
      _lastFees = fees;

      final pnl = double.parse(_pnlController.text);
      final totalPnl = pnl - fees;

      final success = await widget.controller.submitTrade(
        accountId: activeAccount.id,
        currencyPair: _selectedCurrencyPair!,
        direction: _direction,
        riskAmount: double.parse(_riskController.text),
        pnl: totalPnl,
        entryTime: _entryTime,
        exitTime: _exitTime,
        notes: _notesController.text,
        screenshots: _screenshots,
        context: context,
      );

      if (success && mounted) {
        final refreshedAccount = AccountService.instance.activeAccount;
        _latestBalance = refreshedAccount?.balance ?? 0.0;
        debugPrint('[DEBUG] Account balance after trade: $_latestBalance');
        debugPrint(
          '[DEBUG] Expected risk amount (USD): ${(_latestBalance! * (_lastRiskPercentage / 100)).toStringAsFixed(2)}',
        );
        _resetForm(updatedBalance: _latestBalance!);
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Widget _buildTradeSetupSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        buildSectionHeader('Trade Setup', context),
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
          validator: (value) =>
              value == null ? 'Please select a currency pair' : null,
        ),
        const SizedBox(height: 20),
        buildSectionHeader('Direction', context),
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
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return Theme.of(context).colorScheme.primary.withAlpha(36);
              }
              return Theme.of(context).colorScheme.surface;
            }),
            foregroundColor: WidgetStateProperty.all(
              Theme.of(context).colorScheme.onSurface,
            ),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        buildSectionHeader('Timing', context),
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
      ],
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        buildSectionHeader('Notes', context),
        const SizedBox(height: 16),
        ModernTextField(
          controller: _notesController,
          label: 'Trade Notes (Optional)',
          icon: Icons.note_outlined,
          maxLines: 3,
          hintText: 'Add any observations or strategy notes...',
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor.withAlpha(36),
            width: 1,
          ),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          onPressed: _isSubmitting ? null : _submitTrade,
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
    );
  }

  Widget _buildScreenShotSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        buildSectionHeader('Screenshots', context),
        const SizedBox(height: 16),
        // Display the list of screenshots
        if (_screenshots.isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _screenshots.length,
            itemBuilder: (context, index) {
              final screenshot = _screenshots[index];
              return _buildScreenshotCard(screenshot, index);
            },
          ),

        const SizedBox(height: 16),

        // Button to add more screenshots
        OutlinedButton.icon(
          icon: const Icon(Icons.add_a_photo_outlined),
          label: const Text('Add Screenshot'),
          onPressed: _showTimeframeDialogAndPickImage,
        ),
      ],
    );
  }

  Widget _buildScreenshotCard(TradeScreenshot screenshot, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: Image.file(
              screenshot.file,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 150,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  label: Text(screenshot.timeframe),
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primary.withOpacity(0.1),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => _removeScreenshot(index),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
