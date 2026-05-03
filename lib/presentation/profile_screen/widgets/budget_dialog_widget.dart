import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class BudgetDialogWidget extends StatefulWidget {
  final double currentBudget;
  final Function(double) onSave;

  const BudgetDialogWidget({
    Key? key,
    required this.currentBudget,
    required this.onSave,
  }) : super(key: key);

  @override
  State<BudgetDialogWidget> createState() => _BudgetDialogWidgetState();
}

class _BudgetDialogWidgetState extends State<BudgetDialogWidget> {
  late TextEditingController _controller;
  bool _isLoading = false;
  String? _errorText;
  bool _hasAttemptedSave = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.currentBudget > 0
          ? _formatCurrency(widget.currentBudget.toStringAsFixed(0))
          : '',
    );
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (_hasAttemptedSave || _errorText != null) {
      _validate();
    }
  }

  String _formatCurrency(String value) {
    if (value.isEmpty) return '';

    final number = double.tryParse(value.replaceAll('.', '')) ?? 0;
    return number.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  bool _validate() {
    final budgetText = _controller.text.replaceAll('.', '');

    if (budgetText.isEmpty) {
      setState(() {
        _errorText = 'Budget tidak boleh kosong';
      });
      return false;
    }

    final budget = double.tryParse(budgetText);

    if (budget == null) {
      setState(() {
        _errorText = 'Masukkan angka yang valid';
      });
      return false;
    }

    if (budget <= 0) {
      setState(() {
        _errorText = 'Budget harus lebih dari Rp 0';
      });
      return false;
    }

    if (budget < 50000) {
      setState(() {
        _errorText = 'Budget minimal Rp 50.000';
      });
      return false;
    }

    if (budget > 999999999999) {
      setState(() {
        _errorText = 'Budget terlalu besar (maks Rp 999.999.999.999)';
      });
      return false;
    }

    setState(() {
      _errorText = null;
    });
    return true;
  }

  Future<void> _handleSave() async {
    final theme = Theme.of(context);

    setState(() {
      _hasAttemptedSave = true;
    });

    if (!_validate()) {
      return;
    }

    final budgetText = _controller.text.replaceAll('.', '');
    final budget = double.tryParse(budgetText) ?? 0;

    setState(() => _isLoading = true);

    try {
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate API call
      widget.onSave(budget);
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              CustomIconWidget(
                iconName: 'check_circle',
                color: Colors.white,
                size: 5.w,
              ),
              SizedBox(width: 2.w),
              const Text('Budget berhasil diubah'),
            ],
          ),
          backgroundColor: Colors.green, // Fixed for simplicity
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              CustomIconWidget(
                iconName: 'error',
                color: Colors.white,
                size: 5.w,
              ),
              SizedBox(width: 2.w),
              const Text('Gagal mengubah budget'),
            ],
          ),
          backgroundColor: theme.colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasError = _errorText != null;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Atur Budget Bulanan',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Tetapkan batas pengeluaran bulanan Anda',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h),
            TextField(
              controller: _controller,
              enabled: !_isLoading,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                TextInputFormatter.withFunction((oldValue, newValue) {
                  if (newValue.text.isEmpty) return newValue;

                  final formatted = _formatCurrency(newValue.text);
                  return TextEditingValue(
                    text: formatted,
                    selection:
                        TextSelection.collapsed(offset: formatted.length),
                  );
                }),
              ],
              decoration: InputDecoration(
                labelText: 'Budget Bulanan',
                hintText: '0',
                prefixText: 'Rp ',
                prefixStyle: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'account_balance_wallet',
                    color: hasError
                        ? theme.colorScheme.error
                        : theme.colorScheme.primary,
                    size: 5.w,
                  ),
                ),
                errorText: _errorText,
                errorMaxLines: 2,
                labelStyle: TextStyle(
                  color: hasError
                      ? theme.colorScheme.error
                      : theme.colorScheme.onSurfaceVariant,
                ),
                suffixIcon: hasError
                    ? Padding(
                        padding: EdgeInsets.all(3.w),
                        child: CustomIconWidget(
                          iconName: 'error_outline',
                          color: theme.colorScheme.error,
                          size: 5.w,
                        ),
                      )
                    : null,
              ),
            ),
            SizedBox(height: 1.h),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              child: !hasError
                  ? Wrap(
                      spacing: 2.w,
                      runSpacing: 1.h,
                      children: [
                        _buildSuggestionChip(theme, 500000, 'Rp 500rb'),
                        _buildSuggestionChip(theme, 1000000, 'Rp 1jt'),
                        _buildSuggestionChip(theme, 2000000, 'Rp 2jt'),
                        _buildSuggestionChip(theme, 5000000, 'Rp 5jt'),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
            SizedBox(height: 2.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    child: const Text('Batal'),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSave,
                    child: _isLoading
                        ? SizedBox(
                            width: 5.w,
                            height: 5.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                theme.colorScheme.onPrimary,
                              ),
                            ),
                          )
                        : const Text('Simpan'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(ThemeData theme, double amount, String label) {
    return GestureDetector(
      onTap: _isLoading
          ? null
          : () {
              _controller.text = _formatCurrency(amount.toStringAsFixed(0));
              setState(() {
                _errorText = null;
              });
            },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
