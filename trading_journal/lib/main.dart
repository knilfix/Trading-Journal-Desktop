import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'layouts/main_layout.dart';
import 'services/user_service.dart';
import 'services/account_service.dart';
import 'services/trade_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TradingJournalApp());
}

class TradingJournalApp extends StatelessWidget {
  const TradingJournalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserService>.value(
          value: UserService.instance,
        ),
        ChangeNotifierProvider<AccountService>.value(
          value: AccountService.instance,
        ),
        ChangeNotifierProvider<TradeService>.value(
          // Add this provider
          value: TradeService.instance,
        ),
      ],

      child: MaterialApp(
        title: 'Trading Journal Pro',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
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
        ),
        darkTheme: ThemeData(
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
        ),
        themeMode: ThemeMode.system,
        home: const MainLayout(),
      ),
    );
  }
}
