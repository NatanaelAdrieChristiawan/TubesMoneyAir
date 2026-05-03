import 'package:flutter/material.dart';
import 'package:tubesmoneyair/presentation/dashboard_screen/dashboard_screen.dart';
import 'package:tubesmoneyair/presentation/splash_screen/splash_screen.dart';
import 'package:tubesmoneyair/presentation/add_transaction_screen/add_transaction_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String dashboard = '/dashboard-screen';
  static const String splash = '/splash-screen';
  static const String addTransaction = '/add-transaction-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    dashboard: (context) => const DashboardScreen(),
    splash: (context) => const SplashScreen(),
    addTransaction: (context) => const AddTransactionScreen(),
  };
}
