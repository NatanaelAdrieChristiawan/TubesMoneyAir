import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

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

class _DashboardScreenState extends State<DashboardScreen> {
  final LocalStorageService _localStorageService = LocalStorageService();
  final DatabaseService _db = DatabaseService.instance;

  User? _user;
  Budget? _budget;
  List<t_model.Transaction> _transactions = [];
  double _currentSpending = 0.0;
  double _currentIncome = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddTransaction,
        icon: CustomIconWidget(
          iconName: 'add',
          size: 6.w,
          color: theme.colorScheme.onPrimary,
        ),
        label: Text(
          'Tambah',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.w600,
          ),
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
    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            DashboardHeader(
              userName: _user?.username ?? 'Pengguna',
              profileImageUrl: _user?.profilePicturePath,
              onProfileTap: _navigateToProfile,
            ),
            SizedBox(height: 1.h),
            BudgetOverviewCard(
              currentSpending: _currentSpending,
              monthlyBudget: _budget?.amount ?? 0.0,
              currentMonth: _getCurrentMonth(),
            ),
            SizedBox(height: 2.h),
            if (_currentIncome > 0)
              Padding(
                padding: EdgeInsets.only(bottom: 2.h),
                child: IncomeOverviewCard(
                  totalIncome: _currentIncome,
                  currentMonth: _getCurrentMonth(),
                ),
              ),
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
            SizedBox(height: 10.h), // Space for FAB
          ],
        ),
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

  void _navigateToProfile() {
    // Profile screen not available in this version
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitur profil akan tersedia di versi selanjutnya')),
    );
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
