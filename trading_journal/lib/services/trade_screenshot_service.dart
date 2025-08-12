import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:trading_journal/models/trade.dart';

class TradeScreenshotService {
  static const String _screenshotsFolder = 'Screenshots';

  /// Gets the screenshots directory for the app
  static Future<Directory> _getScreenshotsDir() async {
    final directory = await getApplicationDocumentsDirectory();
    final screenshotsDir = Directory(
      '${directory.path}/TradingJournal/$_screenshotsFolder',
    );
    if (!await screenshotsDir.exists()) {
      await screenshotsDir.create(recursive: true);
    }
    return screenshotsDir;
  }

  /// Saves a screenshot file and returns its path
  /// Overwrites any existing screenshot for this trade
  static Future<String?> saveScreenshot(File imageFile, int tradeId) async {
    try {
      final screenshotsDir = await _getScreenshotsDir();
      final fileName = 'trade_$tradeId.png'; // Consistent filename per trade
      final newPath = '${screenshotsDir.path}/$fileName';

      // Delete old screenshot if exists
      if (await File(newPath).exists()) {
        await File(newPath).delete();
      }

      await imageFile.copy(newPath);
      return newPath;
    } catch (e) {
      debugPrint('Error saving screenshot: $e');
      return null;
    }
  }

  /// Deletes a trade's screenshot if it exists
  static Future<void> deleteTradeScreenshot(int tradeId) async {
    try {
      final screenshotsDir = await _getScreenshotsDir();
      final path = '${screenshotsDir.path}/trade_$tradeId.png';
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Error deleting screenshot: $e');
    }
  }

  /// Gets the screenshot for a trade (if exists)
  static Future<File?> getScreenshotForTrade(Trade trade) async {
    if (trade.screenshotPath == "") return null;
    try {
      final file = File(trade.screenshotPath);
      return await file.exists() ? file : null;
    } catch (e) {
      debugPrint('Error loading screenshot: $e');
      return null;
    }
  }

  /// Cleans up orphaned screenshots (optional)
  static Future<void> cleanupOrphanedScreenshots(
    List<int> validTradeIds,
  ) async {
    try {
      final dir = await _getScreenshotsDir();
      final files = await dir
          .list()
          .where((f) => f.path.endsWith('.png'))
          .toList();

      for (final file in files.cast<File>()) {
        final fileName = file.path.split('/').last;
        final tradeId = int.tryParse(
          fileName.replaceAll('trade_', '').replaceAll('.png', ''),
        );

        if (tradeId == null || !validTradeIds.contains(tradeId)) {
          await file.delete();
        }
      }
    } catch (e) {
      debugPrint('Error during screenshot cleanup: $e');
    }
  }
}
