import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _exitController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startSplashSequence();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    _exitController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutBack,
    ));
  }

  Future<void> _startSplashSequence() async {
    // Start animations
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 150));
    _scaleController.forward();

    // Simulate Firebase initialization and authentication check
    await _initializeApp();

    // Wait for minimum splash duration
    await Future.delayed(const Duration(milliseconds: 1200));

    if (mounted) {
      // Smooth exit fade
      await _exitController.forward();
      _navigateToNextScreen();
    }
  }

  Future<void> _initializeApp() async {
    try {
      // Simulate Firebase initialization
      await Future.delayed(const Duration(milliseconds: 500));

      // Simulate authentication status check
      await Future.delayed(const Duration(milliseconds: 300));

      // Simulate user preferences loading
      await Future.delayed(const Duration(milliseconds: 200));

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      // Handle initialization errors gracefully
      setState(() {
        _isInitialized = true;
      });
    }
  }

  void _navigateToNextScreen() {
    Navigator.pushReplacementNamed(context, '/dashboard-screen');
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: FadeTransition(
        opacity: ReverseAnimation(_exitController),
        child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.primaryColor,
              theme.primaryColor.withValues(alpha: 0.8),
              theme.colorScheme.primaryContainer,
            ],
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 3,
                child: Center(
                  child: AnimatedBuilder(
                    animation:
                        Listenable.merge([_fadeAnimation, _scaleAnimation]),
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // App Logo
                              Image.asset(
                                'assets/images/wallet.png',
                                width: 30.w,
                              ),
                              SizedBox(height: 3.h),
                              // App Name
                              Text(
                                'MoneyAir',
                                style: AppTheme
                                    .lightTheme.textTheme.headlineLarge
                                    ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              SizedBox(height: 1.h),
                              // App Tagline
                              Text(
                                'Kelola Keuangan dengan Mudah',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontWeight: FontWeight.w400,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              // Loading Indicator Section
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _fadeAnimation,
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: _fadeAnimation,
                          child: Column(
                            children: [
                              // Loading Indicator
                              SizedBox(
                                width: 8.w,
                                height: 8.w,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white.withValues(alpha: 0.8),
                                  ),
                                ),
                              ),
                              SizedBox(height: 2.h),
                              // Loading Text
                              Text(
                                _isInitialized
                                    ? 'Siap digunakan!'
                                    : 'Memuat aplikasi...',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              // Version Info
              Padding(
                padding: EdgeInsets.only(bottom: 2.h),
                child: AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        'Versi 1.1.0',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 10.sp,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
