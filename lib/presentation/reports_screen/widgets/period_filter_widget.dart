import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

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

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Column(
        children: [
          // Period buttons
          Row(
            children: periods.map((period) {
              final isSelected = selectedPeriod == period;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onPeriodChanged(period),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.symmetric(horizontal: 1.w),
                    padding: EdgeInsets.symmetric(vertical: 1.h),
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
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
