import '../../models/trade.dart';

import 'package:flutter/material.dart';

extension TradeExtensions on Trade {
  String get directionText {
    if (direction == TradeDirection.buy) return 'Buy';
    if (direction == TradeDirection.sell) return 'Sell';
    return 'Unknown';
  }

  String get pnlText {
    return "${pnl > 0 ? '+' : ''}${pnl.toStringAsFixed(2)}";
  }

  Color get pnlColor {
    if (pnl > 0) return Colors.green.shade700;
    if (pnl < 0) return Colors.red.shade700;
    return Colors.grey.shade600;
  }

  String get tradeDuration {
    final duration = exitTime.difference(entryTime);
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    if (days > 0) {
      return "${days}d ${hours}h";
    } else if (hours > 0) {
      return "${hours}h ${minutes}m";
    } else if (minutes > 0) {
      return "${minutes}m";
    } else {
      return "<1m";
    }
  }
}
