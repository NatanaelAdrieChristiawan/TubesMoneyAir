import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class EditUsernameDialogWidget extends StatefulWidget {
  final String currentUsername;
  final Function(String) onSave;

  const EditUsernameDialogWidget({
    Key? key,
    required this.currentUsername,
    required this.onSave,
  }) : super(key: key);

  @override
  State<EditUsernameDialogWidget> createState() =>
      _EditUsernameDialogWidgetState();
}

class _EditUsernameDialogWidgetState extends State<EditUsernameDialogWidget> {
  late TextEditingController _controller;
  bool _isLoading = false;
  String? _errorText;
  bool _hasAttemptedSave = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentUsername);
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

  bool _validate() {
    final value = _controller.text.trim();

    if (value.isEmpty) {
      setState(() {
        _errorText = 'Nama tidak boleh kosong';
      });
      return false;
    }

    if (value.length < 3) {
      setState(() {
        _errorText = 'Nama minimal 3 karakter';
      });
      return false;
    }

    if (value.length > 50) {
      setState(() {
        _errorText = 'Nama maksimal 50 karakter (${value.length}/50)';
      });
      return false;
    }

    final nameRegex = RegExp(r'^[a-zA-Z\s.\-]+$');
    if (!nameRegex.hasMatch(value)) {
      setState(() {
        _errorText = 'Nama hanya boleh huruf, spasi, titik, dan strip';
      });
      return false;
    }

    if (value == widget.currentUsername) {
      setState(() {
        _errorText = 'Nama baru harus berbeda dari nama saat ini';
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

    setState(() => _isLoading = true);

    try {
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate API
      widget.onSave(_controller.text.trim());
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
              const Text('Nama berhasil diubah'),
            ],
          ),
          backgroundColor: Colors.green, // Fixed color for simplicity
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
              const Text('Gagal mengubah nama'),
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
              'Edit Nama',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 3.h),
            TextField(
              controller: _controller,
              enabled: !_isLoading,
              decoration: InputDecoration(
                labelText: 'Nama Lengkap',
                hintText: 'Masukkan nama lengkap',
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'person',
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
              textCapitalization: TextCapitalization.words,
              maxLength: 50,
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
}
