import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TransactionDetailModal extends StatelessWidget {
  final Map<String, dynamic> transaction;
  final VoidCallback onDelete;
  final VoidCallback onUpdated;

  const TransactionDetailModal({
    super.key,
    required this.transaction,
    required this.onDelete,
    required this.onUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isExpense = transaction['type'] == 'expense';
    final amountColor =
        isExpense ? theme.colorScheme.error : const Color(0xFF2ECC71);
    final amountPrefix = isExpense ? '- Rp' : '+ Rp';
    final formattedAmount =
        NumberFormat('#,##0', 'id_ID').format(transaction['amount']);

    final categoryIcons = {
      'Makanan': 'restaurant',
      'Transportasi': 'directions_car',
      'Belanja': 'shopping_bag',
      'Hiburan': 'movie',
      'Kesehatan': 'local_hospital',
      'Pendidikan': 'school',
      'Tagihan': 'receipt',
      'Gaji': 'wallet',
      'Investasi': 'trending_up',
      'Lainnya': 'more_horiz',
    };

    return Container(
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Wrap(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Header ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 12.w,
                    height: 12.w,
                    decoration: BoxDecoration(
                      color:
                          theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: CustomIconWidget(
                        iconName: categoryIcons[transaction['category']] ??
                            'category',
                        size: 7.w,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction['description'],
                          style: theme.textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          '${transaction['category']} • ${DateFormat('d/MM/yyyy').format(transaction['date'])}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    '$amountPrefix $formattedAmount',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: amountColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Divider(height: 5.h),

              // --- Details ---
              _buildDetailRow(
                theme,
                icon: 'account_balance_wallet',
                title: 'Dompet',
                value: transaction['wallet'] ?? 'Tidak diketahui',
              ),
              SizedBox(height: 2.h),
              _buildDetailRow(
                theme,
                icon: 'swap_horiz',
                title: 'Tipe',
                value: isExpense ? 'Pengeluaran' : 'Pemasukan',
              ),
              if (transaction['notes'] != null &&
                  transaction['notes'].isNotEmpty) ...[
                SizedBox(height: 2.h),
                _buildDetailRow(
                  theme,
                  icon: 'notes',
                  title: 'Catatan',
                  value: transaction['notes'],
                ),
              ],

              SizedBox(height: 4.h),

              // --- Actions ---
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context); // Close modal first
                        onDelete();
                      },
                      icon: CustomIconWidget(
                        iconName: 'delete',
                        size: 5.w,
                        color: theme.colorScheme.error,
                      ),
                      label: Text(
                        'Hapus',
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: theme.colorScheme.error),
                        padding: EdgeInsets.symmetric(vertical: 1.5.h),
                      ),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        // Edit feature not available in this version
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Fitur ubah transaksi akan tersedia di versi selanjutnya')),
                        );
                      },
                      icon: CustomIconWidget(
                        iconName: 'edit',
                        size: 5.w,
                        color: theme.colorScheme.onPrimary,
                      ),
                      label: Text(
                        'Ubah',
                        style: TextStyle(color: theme.colorScheme.onPrimary),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        padding: EdgeInsets.symmetric(vertical: 1.5.h),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(ThemeData theme,
      {required String icon, required String title, required String value}) {
    return Row(
      children: [
        CustomIconWidget(
          iconName: icon,
          size: 5.w,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        SizedBox(width: 4.w),
        Text(
          title,
          style: theme.textTheme.bodyLarge
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const Spacer(),
        Text(
          value,
          style:
              theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          textAlign: TextAlign.end,
        ),
      ],
    );
  }
}
