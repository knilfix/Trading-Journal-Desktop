import 'package:flutter/material.dart';
import 'package:trading_journal/components/tradesScreen/add_trade/sub_components/helpers.dart';
import 'package:trading_journal/models/trade.dart';
import 'package:trading_journal/services/account_service.dart';
import 'package:trading_journal/services/trade_service.dart';
import '../../../models/trade_screenshot.dart';

class TradeSubmissionController {
  Future<bool> submitTrade({
    required int accountId,
    required CurrencyPair currencyPair,
    required TradeDirection direction,
    required double riskAmount,
    required double pnl,
    required DateTime entryTime,
    required DateTime exitTime,
    String? notes,
    List<TradeScreenshot>? screenshots,
    required BuildContext context,
  }) async {
    debugPrint('[DEBUG] Submit Trade initiated');
    debugPrint('[DEBUG] Active Account: $accountId');

    // Validate account
    final account = AccountService.instance.getAccountById(accountId);
    if (account == null) {
      debugPrint('[DEBUG] No active account - showing error');
      showError(context, 'No active account selected.');
      return false;
    }

    // Validate times
    if (!exitTime.isAfter(entryTime)) {
      debugPrint('[DEBUG] Exit time must be after entry time');
      showError(context, 'Exit time must be after entry time');
      return false;
    }

    // Validate risk amount
    if (riskAmount < 0) {
      debugPrint('[DEBUG] Risk amount must be non-negative');
      showError(context, 'Risk amount must be non-negative');
      return false;
    }

    try {
      debugPrint('[DEBUG] Attempting to record trade with data:');
      debugPrint('  - Account: $accountId');
      debugPrint('  - Pair: ${currencyPair.symbol}');
      debugPrint('  - Risk: $riskAmount');
      debugPrint('  - PnL: $pnl');
      debugPrint('  - Entry Time: $entryTime');
      debugPrint('  - Number of screenshots: ${screenshots?.length}');

      final trade = await TradeService.instance.recordTrade(
        accountId: accountId,
        currencyPair: currencyPair,
        direction: direction,
        riskAmount: riskAmount,
        pnl: pnl,
        entryTime: entryTime,
        exitTime: exitTime,
        notes: notes, // Fixed: Include notes
        screenshots: screenshots,
      );

      if (trade != null) {
        debugPrint('[DEBUG] Trade recorded successfully: ${trade.id}');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Trade recorded!')));
        return true;
      } else {
        debugPrint('[ERROR] TradeService returned null');
        showError(context, 'Error recording trade');
        return false;
      }
    } catch (e, stackTrace) {
      debugPrint('[EXCEPTION] Error recording trade: $e');
      debugPrint(stackTrace.toString());
      showError(context, 'Error: ${e.toString()}');
      return false;
    }
  }
}
