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
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onTypeChanged(TransactionType.expense);
                  },
                  child: Container(
                    height: double.infinity,
                    margin: EdgeInsets.all(0.5.h),
                    decoration: BoxDecoration(
                      color: selectedType == TransactionType.expense
                          ? theme.colorScheme.error
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'trending_down',
                          color: selectedType == TransactionType.expense
                              ? theme.colorScheme.onError
                              : theme.colorScheme.error,
                          size: 20,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Pengeluaran',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: selectedType == TransactionType.expense
                                ? theme.colorScheme.onError
                                : theme.colorScheme.error,
                          ),
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
                  child: Container(
                    height: double.infinity,
                    margin: EdgeInsets.all(0.5.h),
                    decoration: BoxDecoration(
                      color: selectedType == TransactionType.income
                          ? theme.colorScheme.secondary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'trending_up',
                          color: selectedType == TransactionType.income
                              ? theme.colorScheme.onSecondary
                              : theme.colorScheme.secondary,
                          size: 20,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Pemasukan',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: selectedType == TransactionType.income
                                ? theme.colorScheme.onSecondary
                                : theme.colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
