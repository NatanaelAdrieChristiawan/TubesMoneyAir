import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

enum TransactionType { expense, income }

class TransactionTypeToggleWidget extends StatelessWidget {
  final TransactionType selectedType;
  final Function(TransactionType) onTypeChanged;

  const TransactionTypeToggleWidget({
    Key? key,
    required this.selectedType,
    required this.onTypeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Jenis Transaksi',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.h),
        Container(
          width: double.infinity,
          height: 6.h,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline,
              width: 1,
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final halfWidth = constraints.maxWidth / 2;
              return Stack(
                children: [
                  // Animated sliding indicator
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    left: selectedType == TransactionType.expense
                        ? 0.5.h
                        : halfWidth,
                    top: 0.5.h,
                    bottom: 0.5.h,
                    width: halfWidth - 0.5.h,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      decoration: BoxDecoration(
                        color: selectedType == TransactionType.expense
                            ? theme.colorScheme.error
                            : theme.colorScheme.secondary,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: (selectedType == TransactionType.expense
                                    ? theme.colorScheme.error
                                    : theme.colorScheme.secondary)
                                .withValues(alpha: 0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Tap targets
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            onTypeChanged(TransactionType.expense);
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CustomIconWidget(
                                  iconName: 'trending_down',
                                  color: selectedType == TransactionType.expense
                                      ? theme.colorScheme.onError
                                      : theme.colorScheme.error,
                                  size: 20,
                                ),
                                SizedBox(width: 2.w),
                                AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 200),
                                  style: theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: selectedType ==
                                                TransactionType.expense
                                            ? theme.colorScheme.onError
                                            : theme.colorScheme.error,
                                      ) ??
                                      const TextStyle(),
                                  child: const Text('Pengeluaran'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            onTypeChanged(TransactionType.income);
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CustomIconWidget(
                                  iconName: 'trending_up',
                                  color: selectedType == TransactionType.income
                                      ? theme.colorScheme.onSecondary
                                      : theme.colorScheme.secondary,
                                  size: 20,
                                ),
                                SizedBox(width: 2.w),
                                AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 200),
                                  style: theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: selectedType ==
                                                TransactionType.income
                                            ? theme.colorScheme.onSecondary
                                            : theme.colorScheme.secondary,
                                      ) ??
                                      const TextStyle(),
                                  child: const Text('Pemasukan'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
