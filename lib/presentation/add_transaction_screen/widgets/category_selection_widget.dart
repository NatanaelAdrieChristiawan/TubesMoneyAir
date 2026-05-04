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
        SizedBox(
          height: 12.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = selectedCategory == category['name'];

              return _CategoryChip(
                name: category['name'] as String,
                icon: category['icon'] as String,
                isSelected: isSelected,
                hasError: hasError,
                onTap: () {
                  HapticFeedback.lightImpact();
                  onCategorySelected(category['name'] as String);
                },
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

/// Individual category chip with animated selection state
class _CategoryChip extends StatefulWidget {
  final String name;
  final String icon;
  final bool isSelected;
  final bool hasError;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.name,
    required this.icon,
    required this.isSelected,
    required this.hasError,
    required this.onTap,
  });

  @override
  State<_CategoryChip> createState() => _CategoryChipState();
}

class _CategoryChipState extends State<_CategoryChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _tapController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 120),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _tapController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _tapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTapDown: (_) => _tapController.forward(),
      onTapUp: (_) {
        _tapController.reverse();
        widget.onTap();
      },
      onTapCancel: () => _tapController.reverse(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          width: 20.w,
          margin: EdgeInsets.only(right: 3.w),
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                width: 15.w,
                height: 7.h,
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: widget.isSelected
                        ? theme.colorScheme.primary
                        : widget.hasError
                            ? theme.colorScheme.error.withValues(alpha: 0.5)
                            : theme.colorScheme.outline,
                    width: widget.isSelected ? 2.0 : 1.5,
                  ),
                  boxShadow: widget.isSelected
                      ? [
                          BoxShadow(
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName: widget.icon,
                    color: widget.isSelected
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.primary,
                    size: 24,
                  ),
                ),
              ),
              SizedBox(height: 1.h),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: widget.isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: widget.isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ) ??
                    const TextStyle(),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                child: Text(widget.name),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
