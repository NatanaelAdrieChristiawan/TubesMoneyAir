import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/amount_input_widget.dart';
import './widgets/transaction_type_toggle_widget.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({Key? key}) : super(key: key);

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  TransactionType _selectedType = TransactionType.expense;
  String? _amountError;

  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _slideAnimation.value * 100.h),
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: Container(
                width: double.infinity,
                height: 100.h,
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: SafeArea(
                  top: false,
                  bottom: false,
                  child: Column(
                    children: [
                      _buildDragHandle(),
                      _buildHeader(),
                      Expanded(
                        child: _buildForm(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDragHandle() {
    return Container(
      width: 10.w,
      height: 0.5.h,
      margin: EdgeInsets.symmetric(vertical: 1.h),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.outline,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader() {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: _handleClose,
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.outline,
                  width: 1,
                ),
              ),
              child: CustomIconWidget(
                iconName: 'close',
                color: theme.colorScheme.onSurface,
                size: 20,
              ),
            ),
          ),
          SizedBox(width: 4.w),
          Text(
            'Tambah Transaksi',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 2.h),
            AmountInputWidget(
              controller: _amountController,
              onChanged: _onAmountChanged,
              errorText: _amountError,
            ),
            SizedBox(height: 3.h),
            TransactionTypeToggleWidget(
              selectedType: _selectedType,
              onTypeChanged: _onTypeChanged,
            ),
            SizedBox(height: 3.h),
            // TODO: Implementasi pemilihan kategori
            // TODO: Implementasi pemilihan tanggal
            // TODO: Implementasi input catatan
            // TODO: Implementasi pemilihan dompet
            // TODO: Implementasi tombol simpan
          ],
        ),
      ),
    );
  }

  void _onAmountChanged(String value) {
    setState(() {
      _amountError = null;
    });
    _validateAmount(value);
  }

  void _onTypeChanged(TransactionType type) {
    setState(() {
      _selectedType = type;
    });
  }

  void _validateAmount(String value) {
    if (value.isEmpty) {
      setState(() {
        _amountError = 'Jumlah tidak boleh kosong';
      });
      return;
    }

    final numericValue = value.replaceAll('.', '');
    final amount = double.tryParse(numericValue);

    if (amount == null || amount <= 0) {
      setState(() {
        _amountError = 'Jumlah harus lebih dari 0';
      });
      return;
    }

    setState(() {
      _amountError = null;
    });
  }

  Future<void> _handleClose() async {
    if (_amountController.text.isNotEmpty) {
      final shouldClose = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Batalkan Transaksi?',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          content: Text(
            'Data yang sudah diisi akan hilang. Yakin ingin membatalkan?',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Tidak'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Ya, Batalkan'),
            ),
          ],
        ),
      );

      if (shouldClose == true) {
        await _animationController.reverse();
        if (mounted) Navigator.pop(context);
      }
    } else {
      await _animationController.reverse();
      if (mounted) Navigator.pop(context);
    }
  }
}
