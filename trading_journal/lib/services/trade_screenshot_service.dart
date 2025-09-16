import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class TradeScreenshotService {
  static const String _screenshotsFolder = 'Screenshots';

  /// Gets the screenshots directory for the app
  static Future<Directory> _getScreenshotsDir() async {
    final directory = await getApplicationDocumentsDirectory();
    final screenshotsDir = Directory(
      p.join(directory.path, 'TradingJournal', _screenshotsFolder),
    );
    if (!await screenshotsDir.exists()) {
      await screenshotsDir.create(recursive: true);
    }
    return screenshotsDir;
  }

  /// Saves a screenshot file, with its associated timeframe, and returns its path.
  static Future<String?> saveScreenshot(
    File imageFile,
    int tradeId, {
    required String timeframe,
  }) async {
    try {
      final screenshotsDir = await _getScreenshotsDir();

      // Create a unique filename that includes the trade ID, timeframe, and a timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'trade_${tradeId}_${timeframe}_$timestamp.png';
      final newPath = p.join(screenshotsDir.path, fileName);

      await imageFile.copy(newPath);
      return newPath;
    } catch (e) {
      debugPrint('Error saving screenshot: $e');
      return null;
    }
  }

  /// Deletes a single screenshot file given its full path.
  /// This is used by the TradeService to delete individual files.
  static Future<void> deleteScreenshot(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Error deleting screenshot file: $e');
    }
  }

  /// Cleans up orphaned screenshots (optional)
  /// This method is now more robust due to the unique filenames
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
        final fileName = p.basenameWithoutExtension(file.path);
        // Extract trade ID from the filename format 'trade_ID_TIMEframe_TIMESTAMP'
        final parts = fileName.split('_');
        if (parts.length >= 2 && parts[0] == 'trade') {
          final tradeId = int.tryParse(parts[1]);
          if (tradeId == null || !validTradeIds.contains(tradeId)) {
            await file.delete();
          }
        }
      }
    } catch (e) {
      debugPrint('Error during screenshot cleanup: $e');
    }
  }
}
