import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme:
          ColorScheme.fromSeed(
            seedColor: const Color(0xFF1B263B),
            brightness: Brightness.light,
          ).copyWith(
            primary: const Color(0xFF1B263B),
            secondary: const Color(0xFF415A77),
            surface: const Color(0xFFF8F9FA),
            onSurface: const Color(0xFF2D3748),
          ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      colorScheme:
          ColorScheme.fromSeed(
            seedColor: const Color(0xFF1B263B),
            brightness: Brightness.dark,
          ).copyWith(
            primary: const Color(0xFF4A90E2),
            secondary: const Color(0xFF64B5F6),
            surface: const Color(0xFF1E1E1E),
            onSurface: const Color(0xFFE5E5E7),
          ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      cardTheme: CardThemeData(
        elevation: 4,
        color: const Color(0xFF2D2D2D),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
