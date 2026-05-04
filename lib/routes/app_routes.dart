import 'package:flutter/material.dart';
import 'package:tubesmoneyair/core/page_transitions.dart';
import 'package:tubesmoneyair/presentation/dashboard_screen/dashboard_screen.dart';
import 'package:tubesmoneyair/presentation/splash_screen/splash_screen.dart';
import 'package:tubesmoneyair/presentation/add_transaction_screen/add_transaction_screen.dart';
import 'package:tubesmoneyair/presentation/profile_screen/profile_screen.dart';
import 'package:tubesmoneyair/presentation/reports_screen/reports_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String dashboard = '/dashboard-screen';
  static const String splash = '/splash-screen';
  static const String addTransaction = '/add-transaction-screen';
  static const String profile = '/profile-screen';
  static const String reports = '/reports-screen';

  /// Named routes fallback (used only for initial route)
  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
  };

  /// Generate custom animated routes for every navigation
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case dashboard:
        return FadeScaleRoute(page: const DashboardScreen());
      case splash:
        return FadeScaleRoute(page: const SplashScreen());
      case addTransaction:
        return SlideUpRoute(page: const AddTransactionScreen());
      case profile:
        return SlideRightRoute(page: const ProfileScreen());
      case reports:
        return SlideRightRoute(page: const ReportsScreen());
      default:
        return null;
    }
  }
}
