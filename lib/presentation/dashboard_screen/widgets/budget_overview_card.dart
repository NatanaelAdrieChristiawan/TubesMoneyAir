import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

// Removed unused imports after switching to Theme.of(context)

class BudgetOverviewCard extends StatefulWidget {
  final double currentSpending;
  final double monthlyBudget;
  final String currentMonth;

  const BudgetOverviewCard({
    Key? key,
    required this.currentSpending,
    required this.monthlyBudget,
    required this.currentMonth,
  }) : super(key: key);

  @override
  State<BudgetOverviewCard> createState() => _BudgetOverviewCardState();
}

class _BudgetOverviewCardState extends State<BudgetOverviewCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  late Animation<double> _countAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    final progressValue = widget.monthlyBudget > 0
        ? (widget.currentSpending / widget.monthlyBudget).clamp(0.0, 1.0)
        : 0.0;

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: progressValue,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _countAnimation = Tween<double>(
      begin: 0.0,
      end: widget.currentSpending,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant BudgetOverviewCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final spendingChanged = oldWidget.currentSpending != widget.currentSpending;
    final budgetChanged = oldWidget.monthlyBudget != widget.monthlyBudget;
    final monthChanged = oldWidget.currentMonth != widget.currentMonth;

    if (spendingChanged || budgetChanged || monthChanged) {
      // Capture current animated values before resetting
      final currentProgress = _progressAnimation.value;
      final currentCount = _countAnimation.value;

      final newProgressValue = widget.monthlyBudget > 0
          ? (widget.currentSpending / widget.monthlyBudget).clamp(0.0, 1.0)
          : 0.0;

      // Reconfigure tweens to animate from current displayed values to new ones
      _progressAnimation = Tween<double>(
        begin: currentProgress,
        end: newProgressValue,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ));

      _countAnimation = Tween<double>(
        begin: currentCount,
        end: widget.currentSpending,
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

  Color _getProgressColor() {
    final ratio = widget.monthlyBudget > 0
        ? widget.currentSpending / widget.monthlyBudget
        : 0.0;

    if (ratio <= 0.7) {
      return Theme.of(context).colorScheme.secondary;
    } else if (ratio <= 0.9) {
      return Colors.orange;
    } else {
      return Theme.of(context).colorScheme.error;
    }
  }

  String _formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }

  @override
  Widget build(BuildContext context) {
    final remainingBudget = widget.monthlyBudget - widget.currentSpending;
    final isOverBudget = remainingBudget < 0;

    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
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
                'Budget ${widget.currentMonth}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: _getProgressColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isOverBudget ? 'Over Budget' : 'On Track',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: _getProgressColor(),
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
            'dari ${_formatCurrency(widget.monthlyBudget)}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 2.h),
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return Column(
                children: [
                  LinearProgressIndicator(
                    value: _progressAnimation.value,
                    backgroundColor:
                        theme.colorScheme.outline.withValues(alpha: 0.2),
                    valueColor:
                        AlwaysStoppedAnimation<Color>(_getProgressColor()),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isOverBudget
                            ? 'Melebihi ${_formatCurrency(remainingBudget.abs())}'
                            : 'Sisa ${_formatCurrency(remainingBudget)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isOverBudget
                              ? theme.colorScheme.error
                              : theme.colorScheme.secondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${(_progressAnimation.value * 100).toInt()}%',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
