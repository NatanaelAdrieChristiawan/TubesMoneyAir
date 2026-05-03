import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

// Removed app_export dependency; use Theme.of(context) for theming

class IncomeOverviewCard extends StatefulWidget {
  final double totalIncome;
  final String currentMonth;

  const IncomeOverviewCard({
    super.key,
    required this.totalIncome,
    required this.currentMonth,
  });

  @override
  State<IncomeOverviewCard> createState() => _IncomeOverviewCardState();
}

class _IncomeOverviewCardState extends State<IncomeOverviewCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _countAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _countAnimation = Tween<double>(
      begin: 0.0,
      end: widget.totalIncome,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void didUpdateWidget(covariant IncomeOverviewCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.totalIncome != widget.totalIncome ||
        oldWidget.currentMonth != widget.currentMonth) {
      final currentCount = _countAnimation.value;
      _countAnimation = Tween<double>(
        begin: currentCount,
        end: widget.totalIncome,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ));
      _animationController
        ..reset()
        ..forward();
      setState(() {});
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pemasukan ${widget.currentMonth}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Aktif',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          AnimatedBuilder(
            animation: _countAnimation,
            builder: (context, child) {
              return Text(
                _formatCurrency(_countAnimation.value),
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              );
            },
          ),
          SizedBox(height: 0.5.h),
          Text(
            'Total pemasukan bulan ini',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
