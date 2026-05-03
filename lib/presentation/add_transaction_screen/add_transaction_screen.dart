import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../data/models/transaction_model.dart' as t_model;
import '../../data/services/local_storage_service.dart';
import './widgets/amount_input_widget.dart';
import './widgets/category_selection_widget.dart';
import './widgets/date_picker_widget.dart';
import './widgets/notes_input_widget.dart';
import './widgets/transaction_type_toggle_widget.dart';
import './widgets/wallet_selector_widget.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({Key? key}) : super(key: key);

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final _localStorageService = LocalStorageService();

  TransactionType _selectedType = TransactionType.expense;
  String? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  String _selectedWallet = 'Cash';
  String? _amountError;
  String? _categoryError;
  String? _notesError;
  bool _isLoading = false;
  bool _hasAttemptedSubmit = false;

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
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          final mediaQuery = MediaQuery.of(context);
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
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: mediaQuery.padding.bottom,
                        ),
                        child: _buildSaveButton(),
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
            CategorySelectionWidget(
              selectedCategory: _selectedCategory,
              onCategorySelected: _onCategorySelected,
              transactionType: _selectedType,
              errorText: _categoryError,
            ),
            SizedBox(height: 3.h),
            DatePickerWidget(
              selectedDate: _selectedDate,
              onDateSelected: _onDateSelected,
            ),
            SizedBox(height: 3.h),
            NotesInputWidget(
              controller: _notesController,
              onChanged: _onNotesChanged,
              errorText: _notesError,
            ),
            SizedBox(height: 3.h),
            WalletSelectorWidget(
              selectedWallet: _selectedWallet,
              onWalletSelected: _onWalletSelected,
            ),
            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(4.w),
      child: SizedBox(
        width: double.infinity,
        height: 6.h,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _saveTransaction,
          style: ElevatedButton.styleFrom(
            backgroundColor: _isFormValid() && !_isLoading
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
            foregroundColor: theme.colorScheme.onPrimary,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.onPrimary,
                    ),
                  ),
                )
              : Text(
                  'Simpan',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
        ),
      ),
    );
  }

  void _onAmountChanged(String value) {
    setState(() {
      _amountError = null;
    });
    if (_hasAttemptedSubmit) {
      _validateAmount(value);
    }
  }

  void _onTypeChanged(TransactionType type) {
    setState(() {
      _selectedType = type;
      _selectedCategory = null; // Reset category when type changes
      _categoryError = null;
    });
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
      _categoryError = null;
    });
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  void _onWalletSelected(String wallet) {
    setState(() {
      _selectedWallet = wallet;
    });
  }

  void _onNotesChanged(String value) {
    if (_hasAttemptedSubmit || value.length > 100) {
      _validateNotes(value);
    }
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

    if (amount > 999999999999) {
      setState(() {
        _amountError = 'Jumlah terlalu besar (maks 999.999.999.999)';
      });
      return;
    }

    setState(() {
      _amountError = null;
    });
  }

  void _validateCategory() {
    if (_selectedCategory == null) {
      setState(() {
        _categoryError = 'Pilih kategori terlebih dahulu';
      });
    } else {
      setState(() {
        _categoryError = null;
      });
    }
  }

  void _validateNotes(String value) {
    if (value.length > 100) {
      setState(() {
        _notesError = 'Catatan maksimal 100 karakter (${value.length}/100)';
      });
    } else {
      setState(() {
        _notesError = null;
      });
    }
  }

  bool _isFormValid() {
    return _amountController.text.isNotEmpty &&
        _amountError == null &&
        _selectedCategory != null &&
        _categoryError == null &&
        _notesError == null;
  }

  /// Validates all fields and returns true if all pass
  bool _validateAll() {
    _validateAmount(_amountController.text);
    _validateCategory();
    _validateNotes(_notesController.text);
    return _amountError == null &&
        _amountController.text.isNotEmpty &&
        _selectedCategory != null &&
        _categoryError == null &&
        _notesError == null;
  }

  Future<void> _saveTransaction() async {
    setState(() {
      _hasAttemptedSubmit = true;
    });

    if (!_validateAll()) {
      // Show a summary snackbar for accessibility
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                CustomIconWidget(
                  iconName: 'warning',
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    'Mohon perbaiki data yang belum sesuai',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                ),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final transaction = t_model.Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        amount: double.parse(_amountController.text.replaceAll('.', '')),
        type: _selectedType == TransactionType.expense ? 'expense' : 'income',
        category: _selectedCategory!,
        date: _selectedDate,
        notes: _notesController.text.trim(),
        wallet: _selectedWallet,
      );

      await _localStorageService.addTransaction(transaction);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                CustomIconWidget(
                  iconName: 'check_circle',
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Transaksi berhasil disimpan',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                      ),
                ),
              ],
            ),
            backgroundColor: AppTheme.getSuccessColor(
              Theme.of(context).brightness == Brightness.light,
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );

        await _animationController.reverse();
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                CustomIconWidget(
                  iconName: 'error',
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Gagal menyimpan transaksi. Coba lagi.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                      ),
                ),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleClose() async {
    if (_amountController.text.isNotEmpty ||
        _selectedCategory != null ||
        _notesController.text.isNotEmpty) {
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
