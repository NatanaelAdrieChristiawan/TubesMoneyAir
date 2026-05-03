import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import 'transaction_detail_modal.dart';

class RecentTransactionsList extends StatelessWidget {
  final List<Map<String, dynamic>> transactions;
  final Function(String) onDeleteTransaction;
  final VoidCallback onRefresh;

  const RecentTransactionsList({
    super.key,
    required this.transactions,
    required this.onDeleteTransaction,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Transaksi Terbaru',
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Navigate to all transactions screen
                },
                child: const Text('Lihat Semua'),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          if (transactions.isEmpty)
            _buildEmptyState(context)
          else
            _buildTransactionListView(),
        ],
      ),
    );
  }

  Widget _buildTransactionListView() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      separatorBuilder: (context, index) => SizedBox(height: 1.5.h),
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return _buildTransactionItem(context, transaction);
      },
    );
  }

  Widget _buildTransactionItem(
      BuildContext context, Map<String, dynamic> transaction) {
    final theme = Theme.of(context);
    final isExpense = transaction['type'] == 'expense';
    final amountColor =
        isExpense ? theme.colorScheme.error : const Color(0xFF2ECC71);
    final amountPrefix = isExpense ? '-Rp' : '+Rp';
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

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => _showDetailModal(context, transaction),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
          child: Row(
            children: [
              Container(
                width: 10.w,
                height: 10.w,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName:
                        categoryIcons[transaction['category']] ?? 'category',
                    size: 5.w,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction['description'],
                      style: theme.textTheme.bodyLarge
                          ?.copyWith(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      '${transaction['category']} • ${DateFormat('d/MM/yyyy').format(transaction['date'])}',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 2.w),
              Text(
                '$amountPrefix $formattedAmount',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: amountColor,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetailModal(
      BuildContext context, Map<String, dynamic> transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TransactionDetailModal(
        transaction: transaction,
        onDelete: () => onDeleteTransaction(transaction['id']),
        onUpdated: onRefresh,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 5.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'receipt_long',
            size: 10.w,
            color: theme.colorScheme.outline,
          ),
          SizedBox(height: 2.h),
          Text(
            'Belum Ada Transaksi',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 1.h),
          Text(
            'Mulai catat pengeluaran dan pemasukanmu.',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
