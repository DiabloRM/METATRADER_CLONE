import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/api_service.dart';
import 'services/trading_service.dart';
import 'providers/auth_provider.dart';
import 'providers/trading_provider.dart';
import 'providers/mt5_provider.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use the singleton instance
    final apiService = MetaQuotesApiService();
    final tradingService = TradingService(apiService);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(apiService),
        ),
        ChangeNotifierProvider(
          create: (_) => TradingProvider(tradingService),
        ),
        ChangeNotifierProvider(
          create: (_) => MT5Provider(),
        ),
        // Provide the API service instance to the widget tree
        Provider<MetaQuotesApiService>.value(value: apiService),
      ],
      child: MaterialApp(
        title: 'MetaTrader Clone',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        home: const LoginScreen(),
        debugShowCheckedModeBanner: false,
        routes: {
          '/register': (context) => const RegisterScreen(),
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
        },
      ),
    );
  }
}
