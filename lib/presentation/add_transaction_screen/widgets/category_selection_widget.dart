import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../widgets/transaction_type_toggle_widget.dart';

class CategorySelectionWidget extends StatelessWidget {
  final String? selectedCategory;
  final Function(String) onCategorySelected;
  final TransactionType transactionType;
  final String? errorText;

  const CategorySelectionWidget({
    Key? key,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.transactionType,
    this.errorText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = transactionType == TransactionType.expense
        ? _expenseCategories
        : _incomeCategories;
    final hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Kategori',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: hasError
                    ? theme.colorScheme.error
                    : theme.colorScheme.onSurface,
              ),
            ),
            if (hasError) ...[
              SizedBox(width: 1.w),
              CustomIconWidget(
                iconName: 'error_outline',
                color: theme.colorScheme.error,
                size: 16,
              ),
            ],
          ],
        ),
        SizedBox(height: 1.h),
        Container(
          height: 12.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = selectedCategory == category['name'];

              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onCategorySelected(category['name'] as String);
                },
                child: Container(
                  width: 20.w,
                  margin: EdgeInsets.only(right: 3.w),
                  child: Column(
                    children: [
                      Container(
                        width: 15.w,
                        height: 7.h,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : hasError
                                    ? theme.colorScheme.error.withValues(alpha: 0.5)
                                    : theme.colorScheme.outline,
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: CustomIconWidget(
                            iconName: category['icon'] as String,
                            color: isSelected
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.primary,
                            size: 24,
                          ),
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        category['name'] as String,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        // Animated inline error message
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: hasError
              ? Padding(
                  padding: EdgeInsets.only(top: 0.5.h),
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'info',
                        color: theme.colorScheme.error,
                        size: 14,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        errorText!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  static final List<Map<String, dynamic>> _expenseCategories = [
    {'name': 'Makanan', 'icon': 'restaurant'},
    {'name': 'Transport', 'icon': 'directions_car'},
    {'name': 'Belanja', 'icon': 'shopping_bag'},
    {'name': 'Hiburan', 'icon': 'movie'},
    {'name': 'Kesehatan', 'icon': 'local_hospital'},
    {'name': 'Pendidikan', 'icon': 'school'},
    {'name': 'Tagihan', 'icon': 'receipt'},
    {'name': 'Lainnya', 'icon': 'more_horiz'},
  ];

  static final List<Map<String, dynamic>> _incomeCategories = [
    {'name': 'Gaji', 'icon': 'work'},
    {'name': 'Bonus', 'icon': 'card_giftcard'},
    {'name': 'Investasi', 'icon': 'trending_up'},
    {'name': 'Freelance', 'icon': 'laptop'},
    {'name': 'Bisnis', 'icon': 'business'},
    {'name': 'Hadiah', 'icon': 'redeem'},
    {'name': 'Lainnya', 'icon': 'more_horiz'},
  ];
}
