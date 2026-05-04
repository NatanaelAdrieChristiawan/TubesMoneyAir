import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/animations.dart';
import '../../core/app_export.dart';
import '../../data/models/budget_model.dart';
import '../../data/models/transaction_model.dart' as t_model;
import '../../data/models/user_model.dart';
import '../../data/services/database_service.dart';
import '../../data/services/local_storage_service.dart';
import './widgets/budget_overview_card.dart';
import './widgets/dashboard_header.dart';
import './widgets/income_overview_card.dart';
import './widgets/recent_transactions_list.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  final LocalStorageService _localStorageService = LocalStorageService();
  final DatabaseService _db = DatabaseService.instance;

  User? _user;
  Budget? _budget;
  List<t_model.Transaction> _transactions = [];
  double _currentSpending = 0.0;
  double _currentIncome = 0.0;
  bool _isLoading = true;

  // Stagger animation controllers
  late AnimationController _staggerController;
  final int _itemCount = 5; // header, budget, income, transactions title, list

  @override
  void initState() {
    super.initState();
    _initStagger();
    _loadDashboardData();
  }

  void _initStagger() {
    const delayMs = 80;
    final totalDuration = 400 + (_itemCount * delayMs);
    _staggerController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: totalDuration),
    );
  }

  List<Animation<double>> _buildFadeAnimations() {
    const delayMs = 80;
    final totalDuration = 400 + (_itemCount * delayMs);
    return List.generate(_itemCount, (i) {
      final startFraction = (i * delayMs) / totalDuration;
      final endFraction =
          ((i * delayMs) + 400).clamp(0, totalDuration) / totalDuration;
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _staggerController,
          curve: Interval(startFraction, endFraction, curve: Curves.easeOut),
        ),
      );
    });
  }

  List<Animation<Offset>> _buildSlideAnimations() {
    const delayMs = 80;
    final totalDuration = 400 + (_itemCount * delayMs);
    return List.generate(_itemCount, (i) {
      final startFraction = (i * delayMs) / totalDuration;
      final endFraction =
          ((i * delayMs) + 400).clamp(0, totalDuration) / totalDuration;
      return Tween<Offset>(
        begin: const Offset(0, 0.04),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _staggerController,
          curve: Interval(startFraction, endFraction,
              curve: Curves.easeOutCubic),
        ),
      );
    });
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    try {
      _user = await _localStorageService.getUser();
      _budget = await _localStorageService.getBudget();

      // Hanya query transaksi bulan ini (efisien, tidak load semua data)
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      final results = await Future.wait([
        _db.getTransactionsByDateRange(startOfMonth, endOfMonth),
        _db.getTotalByType('expense', startOfMonth, endOfMonth),
        _db.getTotalByType('income', startOfMonth, endOfMonth),
      ]);

      _transactions = results[0] as List<t_model.Transaction>;
      _currentSpending = results[1] as double;
      _currentIncome = results[2] as double;

      // Sort transactions by date, newest first
      _transactions.sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Gagal memuat data dashboard');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        _staggerController.forward(from: 0.0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: _isLoading ? _buildLoadingIndicator() : _buildDashboardContent(),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
      floatingActionButton: _buildFAB(theme),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: 0,
      onTap: (index) {
        if (index == 1) _navigateToReports();
        if (index == 2) _navigateToProfile();
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart_outlined),
          activeIcon: Icon(Icons.bar_chart),
          label: 'Laporan',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
    );
  }

  Widget _buildFAB(ThemeData theme) {
    return TapBounce(
      onTap: _navigateToAddTransaction,
      child: FloatingActionButton(
        onPressed: null, // Handled by TapBounce
        heroTag: 'dashboard_fab',
        child: CustomIconWidget(
          iconName: 'add',
          size: 6.w,
          color: theme.colorScheme.onPrimary,
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: theme.colorScheme.primary,
            strokeWidth: 2.5,
          ),
          SizedBox(height: 2.h),
          Text(
            'Memuat data...',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent() {
    final fades = _buildFadeAnimations();
    final slides = _buildSlideAnimations();

    return AnimatedBuilder(
      animation: _staggerController,
      builder: (context, _) {
        return RefreshIndicator(
          onRefresh: _loadDashboardData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // Header with stagger
                _staggerWrap(0, fades, slides,
                  DashboardHeader(
                    userName: _user?.username ?? 'Pengguna',
                    profileImageUrl: _user?.profilePicturePath,
                    onProfileTap: _navigateToProfile,
                  ),
                ),
                SizedBox(height: 1.h),
                // Budget card with stagger
                _staggerWrap(1, fades, slides,
                  BudgetOverviewCard(
                    currentSpending: _currentSpending,
                    monthlyBudget: _budget?.amount ?? 0.0,
                    currentMonth: _getCurrentMonth(),
                  ),
                ),
                SizedBox(height: 2.h),
                // Income card with stagger
                if (_currentIncome > 0)
                  _staggerWrap(2, fades, slides,
                    Padding(
                      padding: EdgeInsets.only(bottom: 2.h),
                      child: IncomeOverviewCard(
                        totalIncome: _currentIncome,
                        currentMonth: _getCurrentMonth(),
                      ),
                    ),
                  ),
                // Recent transactions with stagger
                _staggerWrap(3, fades, slides,
                  RecentTransactionsList(
                    transactions: _transactions
                        .take(8)
                        .map((t) => {
                              'id': t.id,
                              'amount': t.amount,
                              'type': t.type,
                              'category': t.category,
                              'date': t.date,
                              // Use notes if present for better preview; fallback to category
                              'description': (t.notes.trim().isNotEmpty)
                                  ? t.notes.trim()
                                  : t.category,
                              'notes': t.notes,
                              'wallet': t.wallet,
                              'isRecurring': false,
                            })
                        .toList(),
                    onRefresh: _loadDashboardData,
                    onDeleteTransaction: _deleteTransaction,
                  ),
                ),
                SizedBox(height: 10.h), // Space for FAB
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _staggerWrap(
    int index,
    List<Animation<double>> fades,
    List<Animation<Offset>> slides,
    Widget child,
  ) {
    if (index >= fades.length) return child;
    return SlideTransition(
      position: slides[index],
      child: FadeTransition(
        opacity: fades[index],
        child: child,
      ),
    );
  }

  Future<void> _deleteTransaction(String transactionId) async {
    try {
      await _localStorageService.deleteTransaction(transactionId);
      await _loadDashboardData(); // Refresh data

      if (!mounted) return;
      final theme = Theme.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Transaksi berhasil dihapus'),
          backgroundColor: theme.colorScheme.secondary,
        ),
      );
    } catch (e) {
      _showErrorSnackBar('Gagal menghapus transaksi');
    }
  }

  void _navigateToProfile() async {
    await Navigator.pushNamed(context, AppRoutes.profile);
    if (!mounted) return;
    await _loadDashboardData();
  }

  void _navigateToReports() async {
    await Navigator.pushNamed(context, AppRoutes.reports);
    if (!mounted) return;
    await _loadDashboardData();
  }

  void _navigateToAddTransaction() async {
    await Navigator.pushNamed(context, AppRoutes.addTransaction);
    if (!mounted) return;
    await _loadDashboardData();
  }

  String _getCurrentMonth() {
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return months[DateTime.now().month - 1];
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Theme.of(context).colorScheme.error),
    );
  }
}
