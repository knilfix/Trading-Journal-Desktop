import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'layouts/main_layout.dart';
import 'services/user_service.dart';
import 'services/account_service.dart';
import 'services/trade_service.dart';
import 'services/theme_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await UserService.instance.initialize();
  runApp(const TradingJournalApp());
}

class TradingJournalApp extends StatelessWidget {
  const TradingJournalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserService>.value(value: UserService.instance),
        ChangeNotifierProvider<AccountService>.value(
          value: AccountService.instance,
        ),
        ChangeNotifierProvider<TradeService>.value(
          value: TradeService.instance,
        ),
        ChangeNotifierProvider<ThemeService>.value(
          value: ThemeService.instance,
        ),
      ],
      child: Consumer<ThemeService>(
        builder: (context, value, child) {
          return MaterialApp(
            title: 'Trading Journal Pro',
            debugShowCheckedModeBanner: true,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: value.themeMode,
            home: const MainLayout(),
          );
        },
      ),
    );
  }
}
