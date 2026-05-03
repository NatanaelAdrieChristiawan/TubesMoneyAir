import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ExpensePieChartWidget extends StatefulWidget {
  final List<Map<String, dynamic>> expenseData;
  final String periodLabel;

  const ExpensePieChartWidget({
    Key? key,
    required this.expenseData,
    required this.periodLabel,
  }) : super(key: key);

  @override
  State<ExpensePieChartWidget> createState() => _ExpensePieChartWidgetState();
}

class _ExpensePieChartWidgetState extends State<ExpensePieChartWidget> {
  int _touchedIndex = -1;

  static const _colors = [
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

    if (widget.expenseData.isEmpty) {
      return Card(
        elevation: 2,
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        child: SizedBox(
          height: 20.h,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'pie_chart',
                  size: 8.w,
                  color: theme.colorScheme.outline,
                ),
                SizedBox(height: 2.h),
                Text(
                  'Belum ada data pengeluaran',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final total = widget.expenseData
        .fold<double>(0, (s, d) => s + (d['amount'] as double));

    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pengeluaran per Kategori',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 3.h),
            SizedBox(
              height: 30.h,
              child: Row(
                children: [
                  // Pie chart via CustomPainter
                  Expanded(
                    flex: 3,
                    child: GestureDetector(
                      onTapDown: (details) {
                        _handleTap(details.localPosition, context);
                      },
                      child: CustomPaint(
                        painter: _PieChartPainter(
                          data: widget.expenseData,
                          colors: _colors,
                          touchedIndex: _touchedIndex,
                          total: total,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  // Legend
                  Expanded(
                    flex: 2,
                    child: _buildLegend(theme, formatter, total),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleTap(Offset position, BuildContext context) {
    final size = context.size;
    if (size == null) return;
    final center = Offset(size.width * 3 / 5 / 2, size.height / 2);
    final radius = math.min(size.width * 3 / 5 / 2, size.height / 2) * 0.9;
    final dx = position.dx - center.dx;
    final dy = position.dy - center.dy;
    final dist = math.sqrt(dx * dx + dy * dy);

    if (dist > radius * 0.4 && dist < radius) {
      // calc angle
      double angle = math.atan2(dy, dx);
      if (angle < -math.pi / 2) angle += 2 * math.pi;

      final total = widget.expenseData
          .fold<double>(0, (s, d) => s + (d['amount'] as double));
      double start = -math.pi / 2;
      for (int i = 0; i < widget.expenseData.length; i++) {
        final sweep =
            (widget.expenseData[i]['amount'] as double) / total * 2 * math.pi;
        if (angle >= start && angle < start + sweep) {
          setState(() => _touchedIndex = _touchedIndex == i ? -1 : i);
          return;
        }
        start += sweep;
      }
    }
  }

  Widget _buildLegend(
      ThemeData theme, NumberFormat formatter, double total) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.expenseData.asMap().entries.map((entry) {
        final i = entry.key;
        final d = entry.value;
        final pct = (d['amount'] as double) / total * 100;
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 0.5.h),
          child: Row(
            children: [
              Container(
                width: 3.w,
                height: 3.w,
                decoration: BoxDecoration(
                  color: _colors[i % _colors.length],
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      d['category'] as String,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Rp ${formatter.format(d['amount'] as double)}',
                      style: TextStyle(
                        fontSize: 9.sp,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _PieChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  final List<Color> colors;
  final int touchedIndex;
  final double total;

  _PieChartPainter({
    required this.data,
    required this.colors,
    required this.touchedIndex,
    required this.total,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = math.min(size.width / 2, size.height / 2) * 0.9;
    const holeRatio = 0.45;

    double startAngle = -math.pi / 2;

    for (int i = 0; i < data.length; i++) {
      final sweepAngle = (data[i]['amount'] as double) / total * 2 * math.pi;
      final isTouched = i == touchedIndex;
      final radius = isTouched ? baseRadius * 1.05 : baseRadius;

      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle - 0.02,
        true,
        paint,
      );

      // Draw percentage text
      final pct = (data[i]['amount'] as double) / total * 100;
      if (pct >= 5) {
        final midAngle = startAngle + sweepAngle / 2;
        final textRadius = radius * 0.72;
        final textX = center.dx + textRadius * math.cos(midAngle);
        final textY = center.dy + textRadius * math.sin(midAngle);

        final tp = TextPainter(
          text: TextSpan(
            text: '${pct.toStringAsFixed(1)}%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: ui.TextDirection.ltr,
        )..layout();
        tp.paint(canvas,
            Offset(textX - tp.width / 2, textY - tp.height / 2));
      }

      startAngle += sweepAngle;
    }

    // Draw hole
    canvas.drawCircle(
      center,
      baseRadius * holeRatio,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(_PieChartPainter old) =>
      old.touchedIndex != touchedIndex || old.data != data;
}
