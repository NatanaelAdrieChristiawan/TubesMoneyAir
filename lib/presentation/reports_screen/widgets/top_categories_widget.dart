import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TopCategoriesWidget extends StatelessWidget {
  final List<Map<String, dynamic>> categoriesData;

  const TopCategoriesWidget({
    Key? key,
    required this.categoriesData,
  }) : super(key: key);

  static const _categoryIcons = {
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

  static const _categoryColors = [
    Color(0xFF2196F3),
    Color(0xFFFF5722),
    Color(0xFF4CAF50),
    Color(0xFF9C27B0),
    Color(0xFFFF9800),
    Color(0xFF607D8B),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatter = NumberFormat('#,##0', 'id_ID');
    final total = categoriesData.fold<double>(
      0,
      (s, d) => s + (d['amount'] as double),
    );
    final top = categoriesData.take(5).toList();

    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kategori Teratas',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            ...top.asMap().entries.map((entry) {
              final i = entry.key;
              final d = entry.value;
              final pct =
                  total > 0 ? (d['amount'] as double) / total * 100 : 0.0;
              final color = _categoryColors[i % _categoryColors.length];

              return Padding(
                padding: EdgeInsets.only(bottom: 1.5.h),
                child: Row(
                  children: [
                    Container(
                      width: 10.w,
                      height: 10.w,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: CustomIconWidget(
                        iconName: _categoryIcons[d['category']] ?? 'category',
                        color: color,
                        size: 5.w,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                d['category'] as String,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    '#${i + 1}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color:
                                          theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 0.5.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Rp ${formatter.format(d['amount'] as double)}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: color,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${pct.toStringAsFixed(1)}%',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 0.5.h),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: pct / 100,
                              backgroundColor:
                                  color.withValues(alpha: 0.12),
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(color),
                              minHeight: 0.6.h,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
