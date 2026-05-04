import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

/// Widget filter periode dengan navigasi bulan/minggu/tahun.
///
/// Menggantikan filter statis lama dengan navigasi panah kiri-kanan
/// agar pengguna bisa melihat data historis.
class PeriodFilterWidget extends StatelessWidget {
  final String selectedPeriod;
  final Function(String) onPeriodChanged;
  final DateTime currentDate;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final String periodLabel;

  const PeriodFilterWidget({
    Key? key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
    required this.currentDate,
    required this.onPrevious,
    required this.onNext,
    required this.periodLabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final periods = ['Harian', 'Mingguan', 'Bulanan', 'Tahunan'];

    return Column(
      children: [
        // Baris navigasi tanggal
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: onPrevious,
                icon: Icon(
                  Icons.chevron_left_rounded,
                  color: theme.colorScheme.primary,
                  size: 7.w,
                ),
                splashRadius: 5.w,
              ),
              Expanded(
                child: Center(
                  child: Text(
                    periodLabel,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: _isCurrentPeriod() ? null : onNext,
                icon: Icon(
                  Icons.chevron_right_rounded,
                  color: _isCurrentPeriod()
                      ? theme.colorScheme.outline.withValues(alpha: 0.3)
                      : theme.colorScheme.primary,
                  size: 7.w,
                ),
                splashRadius: 5.w,
              ),
            ],
          ),
        ),
        SizedBox(height: 1.h),
        // Baris tombol periode
        Container(
          height: 5.h,
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Row(
            children: periods.map((period) {
              final isSelected = selectedPeriod == period;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onPeriodChanged(period),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.symmetric(horizontal: 1.w),
                    padding: EdgeInsets.symmetric(vertical: 0.8.h),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outline,
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          period,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : theme.colorScheme.onSurface,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  bool _isCurrentPeriod() {
    final now = DateTime.now();
    switch (selectedPeriod) {
      case 'Harian':
        return currentDate.year == now.year &&
            currentDate.month == now.month &&
            currentDate.day == now.day;
      case 'Mingguan':
        final nowWeekStart = now.subtract(Duration(days: now.weekday - 1));
        final currentWeekStart =
            currentDate.subtract(Duration(days: currentDate.weekday - 1));
        return nowWeekStart.year == currentWeekStart.year &&
            nowWeekStart.month == currentWeekStart.month &&
            nowWeekStart.day == currentWeekStart.day;
      case 'Bulanan':
        return currentDate.year == now.year &&
            currentDate.month == now.month;
      case 'Tahunan':
        return currentDate.year == now.year;
      default:
        return true;
    }
  }
}
