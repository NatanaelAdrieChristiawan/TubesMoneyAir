import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sizer/sizer.dart';

import '../../core/animations.dart';

import '../../core/app_export.dart';
import '../../data/models/transaction_model.dart' as t_model;
import '../../data/services/database_service.dart';
import '../../data/services/local_storage_service.dart';
import '../../data/services/pdf_export_service.dart';
import '../dashboard_screen/widgets/transaction_detail_modal.dart';
import 'widgets/expense_pie_chart_widget.dart';
import 'widgets/period_filter_widget.dart';
import 'widgets/top_categories_widget.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  final DatabaseService _db = DatabaseService.instance;
  final LocalStorageService _localStorageService = LocalStorageService();

  String _selectedPeriod = 'Harian';
  DateTime _currentDate = DateTime.now();

  double _totalExpense = 0;
  List<Map<String, dynamic>> _categoryData = [];
  List<t_model.Transaction> _transactions = [];

  bool _isLoading = true;
  late AnimationController _animationController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID');
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _loadReportData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  ({DateTime start, DateTime end}) _getDateRange() {
    switch (_selectedPeriod) {
      case 'Harian':
        final start =
            DateTime(_currentDate.year, _currentDate.month, _currentDate.day);
        final end =
            start.add(const Duration(hours: 23, minutes: 59, seconds: 59));
        return (start: start, end: end);
      case 'Mingguan':
        final weekday = _currentDate.weekday;
        final start = DateTime(
          _currentDate.year,
          _currentDate.month,
          _currentDate.day - (weekday - 1),
        );
        final end = start
            .add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
        return (start: start, end: end);
      case 'Bulanan':
        final start = DateTime(_currentDate.year, _currentDate.month, 1);
        final end =
            DateTime(_currentDate.year, _currentDate.month + 1, 0, 23, 59, 59);
        return (start: start, end: end);
      case 'Tahunan':
        final start = DateTime(_currentDate.year, 1, 1);
        final end = DateTime(_currentDate.year, 12, 31, 23, 59, 59);
        return (start: start, end: end);
      default:
        final start =
            DateTime(_currentDate.year, _currentDate.month, _currentDate.day);
        final end =
            start.add(const Duration(hours: 23, minutes: 59, seconds: 59));
        return (start: start, end: end);
    }
  }

  Future<void> _loadReportData() async {
    setState(() => _isLoading = true);
    try {
      final range = _getDateRange();
      final results = await Future.wait([
        _db.getTotalByType('expense', range.start, range.end),
        _db.getExpenseSummaryByCategory(range.start, range.end),
        _db.getTransactionsByDateRange(range.start, range.end),
      ]);

      if (mounted) {
        setState(() {
          _totalExpense = results[0] as double;
          _categoryData = results[1] as List<Map<String, dynamic>>;
          _transactions = (results[2] as List<t_model.Transaction>)
              .where((t) => t.type == 'expense')
              .toList();
          _isLoading = false;
        });
        _animationController.forward(from: 0.0);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data laporan: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _onPeriodChanged(String period) {
    setState(() {
      _selectedPeriod = period;
      _currentDate = DateTime.now();
    });
    _loadReportData();
  }

  void _onPrevious() {
    setState(() {
      switch (_selectedPeriod) {
        case 'Harian':
          _currentDate = _currentDate.subtract(const Duration(days: 1));
          break;
        case 'Mingguan':
          _currentDate = _currentDate.subtract(const Duration(days: 7));
          break;
        case 'Bulanan':
          _currentDate = DateTime(
            _currentDate.year,
            _currentDate.month - 1,
            _currentDate.day,
          );
          break;
        case 'Tahunan':
          _currentDate = DateTime(
            _currentDate.year - 1,
            _currentDate.month,
            _currentDate.day,
          );
          break;
      }
    });
    _loadReportData();
  }

  void _onNext() {
    setState(() {
      switch (_selectedPeriod) {
        case 'Harian':
          _currentDate = _currentDate.add(const Duration(days: 1));
          break;
        case 'Mingguan':
          _currentDate = _currentDate.add(const Duration(days: 7));
          break;
        case 'Bulanan':
          _currentDate = DateTime(
            _currentDate.year,
            _currentDate.month + 1,
            _currentDate.day,
          );
          break;
        case 'Tahunan':
          _currentDate = DateTime(
            _currentDate.year + 1,
            _currentDate.month,
            _currentDate.day,
          );
          break;
      }
    });
    _loadReportData();
  }

  String _getPeriodLabel() {
    switch (_selectedPeriod) {
      case 'Harian':
        return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(_currentDate);
      case 'Mingguan':
        final weekday = _currentDate.weekday;
        final startOfWeek = _currentDate.subtract(Duration(days: weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        return '${DateFormat('d MMM', 'id_ID').format(startOfWeek)} - ${DateFormat('d MMM yyyy', 'id_ID').format(endOfWeek)}';
      case 'Bulanan':
        return DateFormat('MMMM yyyy', 'id_ID').format(_currentDate);
      case 'Tahunan':
        return 'Tahun ${_currentDate.year}';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatter = NumberFormat('#,##0', 'id_ID');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan'),
        centerTitle: false,
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        leading: IconButton(
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: theme.colorScheme.onSurface,
            size: 6.w,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadReportData,
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Period filter
                    PeriodFilterWidget(
                      selectedPeriod: _selectedPeriod,
                      onPeriodChanged: _onPeriodChanged,
                      currentDate: _currentDate,
                      onPrevious: _onPrevious,
                      onNext: _onNext,
                      periodLabel: _getPeriodLabel(),
                    ),
                    SizedBox(height: 1.h),
                    // Summary card
                    AnimateIn(
                      delay: const Duration(milliseconds: 100),
                      child: FadeTransition(
                        opacity: _animationController,
                        child: _buildSummaryCard(theme, formatter),
                      ),
                    ),
                    SizedBox(height: 1.h),
                    // Charts
                    if (_categoryData.isNotEmpty) ...[
                      AnimateIn(
                        delay: const Duration(milliseconds: 200),
                        child: FadeTransition(
                          opacity: _animationController,
                          child: Column(
                            children: [
                              ExpensePieChartWidget(
                                expenseData: _categoryData,
                                periodLabel: _getPeriodLabel(),
                              ),
                              TopCategoriesWidget(
                                categoriesData: _categoryData,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    // Transactions list
                    _buildTransactionListHeader(theme),
                    if (_transactions.isEmpty)
                      _buildEmptyState(theme)
                    else
                      _buildTransactionList(theme, formatter),
                    SizedBox(height: 12.h),
                  ],
                ),
              ),
            ),
      floatingActionButton: _isLoading ? null : _buildFab(theme),
    );
  }

  Widget _buildSummaryCard(ThemeData theme, NumberFormat formatter) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_downward, color: Colors.white),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Pengeluaran',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'Rp ${formatter.format(_totalExpense)}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 0.3.h),
                Text(
                  _getPeriodLabel(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${_transactions.length} transaksi',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionListHeader(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 1.h),
      child: Text(
        'Ringkasan ${_selectedPeriod}: ${_transactions.length} transaksi',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildTransactionList(ThemeData theme, NumberFormat formatter) {
    // Group by day
    final grouped = <DateTime, List<t_model.Transaction>>{};
    for (final t in _transactions) {
      final key = DateTime(t.date.year, t.date.month, t.date.day);
      grouped.putIfAbsent(key, () => []).add(t);
    }
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return Column(
      children: sortedKeys.map((dateKey) {
        final dayTxs = grouped[dateKey]!;
        final dayTotal = dayTxs.fold<double>(0, (s, t) => s + t.amount);

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.h),
          child: Column(
            children: [
              // Date header row (expandable)
              _DateGroupTile(
                dateKey: dateKey,
                dayTotal: dayTotal,
                transactions: dayTxs,
                theme: theme,
                formatter: formatter,
                onTransactionTap: _showTransactionDetail,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _showTransactionDetail(t_model.Transaction t) {
    final map = {
      'id': t.id,
      'amount': t.amount,
      'type': t.type,
      'category': t.category,
      'date': t.date,
      'description': (t.notes.trim().isNotEmpty) ? t.notes.trim() : t.category,
      'notes': t.notes,
      'wallet': t.wallet,
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TransactionDetailModal(
        transaction: map,
        onDelete: () async {
          await _localStorageService.deleteTransaction(t.id);
          if (!mounted) return;
          await _loadReportData();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Transaksi dihapus'),
              backgroundColor: Theme.of(context).colorScheme.secondary,
            ),
          );
        },
        onUpdated: () async {
          await _loadReportData();
        },
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.history, size: 12.w, color: theme.colorScheme.outline),
            SizedBox(height: 2.h),
            Text(
              'Belum ada transaksi.',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Tidak ada catatan untuk periode ini.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFab(ThemeData theme) {
    return FloatingActionButton.extended(
      onPressed: _handleExportPdf,
      backgroundColor: theme.colorScheme.secondary,
      foregroundColor: theme.colorScheme.onSecondary,
      icon: CustomIconWidget(
        iconName: 'file_download',
        color: theme.colorScheme.onSecondary,
        size: 5.w,
      ),
      label: const Text('Export PDF'),
    );
  }

  Future<void> _handleExportPdf() async {
    if (_transactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak ada pengeluaran untuk diekspor'),
        ),
      );
      return;
    }

    try {
      final service = PdfExportService();
      await service.shareExpensesPdf(
        expenses: _transactions,
        periodLabel: _getPeriodLabel(),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengekspor PDF: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}

// Collapsible date group tile
class _DateGroupTile extends StatefulWidget {
  final DateTime dateKey;
  final double dayTotal;
  final List<t_model.Transaction> transactions;
  final ThemeData theme;
  final NumberFormat formatter;
  final Function(t_model.Transaction)? onTransactionTap;

  const _DateGroupTile({
    required this.dateKey,
    required this.dayTotal,
    required this.transactions,
    required this.theme,
    required this.formatter,
    this.onTransactionTap,
  });

  @override
  State<_DateGroupTile> createState() => _DateGroupTileState();
}

class _DateGroupTileState extends State<_DateGroupTile>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _expandController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final formatter = widget.formatter;
    final dateLabel =
        DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(widget.dateKey);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() => _isExpanded = !_isExpanded);
              if (_isExpanded) {
                _expandController.forward();
              } else {
                _expandController.reverse();
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      dateLabel,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    'Total: - Rp ${formatter.format(widget.dayTotal)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    child: Icon(
                        Icons.keyboard_arrow_down,
                      color: theme.colorScheme.onSurfaceVariant,
                      size: 5.w,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: _buildExpandedContent(theme, formatter),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedContent(ThemeData theme, NumberFormat formatter) {
    return Column(
      children: widget.transactions.map((t) {
        return Column(
          children: [
            const Divider(height: 1, thickness: 0.5),
            InkWell(
              onTap: () => widget.onTransactionTap?.call(t),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                child: Row(
                  children: [
                    Container(
                      width: 9.w,
                      height: 9.w,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: CustomIconWidget(
                        iconName: _getCategoryIcon(t.category),
                        color: theme.colorScheme.error,
                        size: 4.5.w,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.category,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (t.notes.isNotEmpty)
                            Text(
                              t.notes,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    Text(
                      '- Rp ${formatter.format(t.amount)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  String _getCategoryIcon(String category) {
    const icons = {
      'Makanan': 'restaurant',
      'Transportasi': 'directions_car',
      'Belanja': 'shopping_bag',
      'Hiburan': 'movie',
      'Kesehatan': 'local_hospital',
      'Pendidikan': 'school',
      'Tagihan': 'receipt',
      'Gaji': 'account_balance_wallet',
      'Freelance': 'work',
      'Investasi': 'trending_up',
      'Lainnya': 'more_horiz',
    };
    return icons[category] ?? 'category';
  }
}
