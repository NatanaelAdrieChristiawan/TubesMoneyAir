import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../core/animations.dart';

import '../../core/app_export.dart';
import '../../core/theme_controller.dart';
import '../../data/models/budget_model.dart';
import '../../data/models/user_model.dart';
import '../../data/services/local_storage_service.dart';
import '../../data/models/transaction_model.dart' as t_model;
import '../../data/services/pdf_export_service.dart';
import './widgets/budget_dialog_widget.dart';
import './widgets/edit_username_dialog_widget.dart';
import './widgets/image_picker_modal_widget.dart';
import './widgets/profile_header_widget.dart';
import './widgets/profile_section_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final LocalStorageService _localStorageService = LocalStorageService();
  final ImagePicker _imagePicker = ImagePicker();
  final ThemeController _themeController = ThemeController();

  User? _user;
  Budget? _budget;
  bool _isLoading = true;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID');
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      _user = await _localStorageService.getUser();
      _budget = await _localStorageService.getBudget();

      if (_user == null) {
        _user = User(username: 'Pengguna Baru');
        await _localStorageService.saveUser(_user!);
      }

      if (_budget == null) {
        _budget = Budget(amount: 2000000.0);
        await _localStorageService.saveBudget(_budget!);
      }
    } catch (e) {
      _showErrorSnackBar('Gagal memuat data');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ===== FOTO PROFIL =====

  Future<void> _handleImagePicker() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ImagePickerModalWidget(
        onCameraTap: () => _pickImage(ImageSource.camera),
        onGalleryTap: () => _pickImage(ImageSource.gallery),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      if (!kIsWeb && source == ImageSource.camera) {
        final permission = await Permission.camera.request();
        if (!permission.isGranted) {
          _showErrorSnackBar('Izin kamera diperlukan');
          return;
        }
      }

      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        await _updateProfileImage(image.path);
      }
    } catch (e) {
      _showErrorSnackBar('Gagal memilih gambar');
    }
  }

  Future<void> _updateProfileImage(String imagePath) async {
    setState(() => _isUploading = true);

    try {
      final updatedUser = User(
        username: _user!.username,
        profilePicturePath: imagePath,
      );
      await _localStorageService.saveUser(updatedUser);

      setState(() {
        _user = updatedUser;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Foto profil berhasil diubah'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    } catch (e) {
      _showErrorSnackBar('Gagal menyimpan foto profil');
    } finally {
      setState(() => _isUploading = false);
    }
  }

  // ===== EDIT USERNAME =====

  void _showEditUsernameDialog() {
    showDialog(
      context: context,
      builder: (context) => EditUsernameDialogWidget(
        currentUsername: _user?.username ?? '',
        onSave: (newName) async {
          final updatedUser = User(
            username: newName,
            profilePicturePath: _user?.profilePicturePath,
          );
          await _localStorageService.saveUser(updatedUser);
          setState(() => _user = updatedUser);
        },
      ),
    );
  }

  // ===== BUDGET =====

  void _showBudgetDialog() {
    showDialog(
      context: context,
      builder: (context) => BudgetDialogWidget(
        currentBudget: _budget?.amount ?? 0.0,
        onSave: (newBudget) async {
          final updatedBudget = Budget(amount: newBudget);
          await _localStorageService.saveBudget(updatedBudget);
          setState(() => _budget = updatedBudget);
        },
      ),
    );
  }

  // ===== MODE TAMPILAN =====

  void _showThemeModeSheet() {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final current = _themeController.themeMode;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 1.h),
              Container(
                width: 12.w,
                height: 0.4.h,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 1.h),
              ListTile(
                leading: Icon(Icons.wb_sunny_outlined,
                    color: theme.colorScheme.onSurface),
                title: Text('Terang',
                    style: TextStyle(color: theme.colorScheme.onSurface)),
                trailing: current == ThemeMode.light
                    ? Icon(Icons.check, color: theme.colorScheme.primary)
                    : null,
                onTap: () async {
                  await _themeController.setThemeMode(ThemeMode.light);
                  if (mounted) {
                    Navigator.of(ctx).pop();
                    setState(() {});
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.nights_stay_outlined,
                    color: theme.colorScheme.onSurface),
                title: Text('Gelap',
                    style: TextStyle(color: theme.colorScheme.onSurface)),
                trailing: current == ThemeMode.dark
                    ? Icon(Icons.check, color: theme.colorScheme.primary)
                    : null,
                onTap: () async {
                  await _themeController.setThemeMode(ThemeMode.dark);
                  if (mounted) {
                    Navigator.of(ctx).pop();
                    setState(() {});
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.brightness_auto,
                    color: theme.colorScheme.onSurface),
                title: Text('Sistem',
                    style: TextStyle(color: theme.colorScheme.onSurface)),
                trailing: current == ThemeMode.system
                    ? Icon(Icons.check, color: theme.colorScheme.primary)
                    : null,
                onTap: () async {
                  await _themeController.setThemeMode(ThemeMode.system);
                  if (mounted) {
                    Navigator.of(ctx).pop();
                    setState(() {});
                  }
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  // ===== EKSPOR PDF =====

  void _showExportPeriodSheet() {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final periods = ['Harian', 'Mingguan', 'Bulanan', 'Tahunan', 'Semua'];
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 1.h),
              Container(
                width: 12.w,
                height: 0.4.h,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 1.h),
              for (final p in periods)
                ListTile(
                  leading: CustomIconWidget(
                    iconName: p == 'Harian'
                        ? 'today'
                        : p == 'Mingguan'
                            ? 'date_range'
                            : p == 'Bulanan'
                                ? 'event'
                                : p == 'Tahunan'
                                    ? 'calendar_month'
                                    : 'all_inbox',
                    color: theme.colorScheme.onSurface,
                    size: 6.w,
                  ),
                  title: Text(p,
                      style: TextStyle(color: theme.colorScheme.onSurface)),
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    await _exportPdfForPeriod(p);
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _exportPdfForPeriod(String period) async {
    try {
      final txs = await _localStorageService.getTransactions();
      final expenses = _filterExpensesForPeriod(txs, period);
      if (expenses.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Tidak ada pengeluaran untuk diekspor')),
        );
        return;
      }
      final label = _buildPeriodLabelForPeriod(period);
      final service = PdfExportService();
      await service.shareExpensesPdf(expenses: expenses, periodLabel: label);
    } catch (e) {
      _showErrorSnackBar('Gagal mengekspor PDF: $e');
    }
  }

  List<t_model.Transaction> _filterExpensesForPeriod(
      List<t_model.Transaction> all, String period) {
    final now = DateTime.now();
    final expenses = all.where((t) => t.type == 'expense');
    switch (period) {
      case 'Harian':
        return expenses.where((t) => _isSameDay(t.date, now)).toList();
      case 'Mingguan':
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        return expenses
            .where((t) =>
                t.date.isAfter(
                    startOfWeek.subtract(const Duration(days: 1))) &&
                t.date.isBefore(endOfWeek.add(const Duration(days: 1))))
            .toList();
      case 'Bulanan':
        return expenses
            .where((t) =>
                t.date.month == now.month && t.date.year == now.year)
            .toList();
      case 'Tahunan':
        return expenses.where((t) => t.date.year == now.year).toList();
      case 'Semua':
      default:
        return expenses.toList();
    }
  }

  String _buildPeriodLabelForPeriod(String period) {
    final now = DateTime.now();
    switch (period) {
      case 'Harian':
        return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(now);
      case 'Mingguan':
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        return '${DateFormat('d MMM', 'id_ID').format(startOfWeek)} - ${DateFormat('d MMM yyyy', 'id_ID').format(endOfWeek)}';
      case 'Bulanan':
        return DateFormat('MMMM yyyy', 'id_ID').format(now);
      case 'Tahunan':
        return DateFormat('yyyy').format(now);
      case 'Semua':
      default:
        return 'Semua Waktu';
    }
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  // ===== HELPERS =====

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: theme.colorScheme.error,
      ),
    );
  }

  String _formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }

  String _getThemeLabel() {
    switch (_themeController.themeMode) {
      case ThemeMode.light:
        return 'Terang';
      case ThemeMode.dark:
        return 'Gelap';
      case ThemeMode.system:
        return 'Ikuti Sistem';
    }
  }

  // ===== BUILD =====

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Profil'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        leading: IconButton(
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: theme.colorScheme.onSurface,
            size: 6.w,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                ),
              )
            : _buildProfileContent(),
      ),
    );
  }

  Widget _buildProfileContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          AnimateIn(
            delay: const Duration(milliseconds: 50),
            child: _buildProfileHeader(),
          ),
          SizedBox(height: 2.h),
          AnimateIn(
            delay: const Duration(milliseconds: 150),
            child: _buildSettingsSection(),
          ),
          AnimateIn(
            delay: const Duration(milliseconds: 250),
            child: _buildDataSection(),
          ),
          SizedBox(height: 4.h),
          AnimateIn(
            delay: const Duration(milliseconds: 350),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: Text(
                'Jika ada kritik dan saran untuk MoneyAir bisa dikirim ke email natanaelac04@gmail.com, enjoy the app!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
          SizedBox(height: 4.h),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Stack(
      children: [
        ProfileHeaderWidget(
          profileImageUrl: _user?.profilePicturePath ?? '',
          userName: _user?.username ?? 'N/A',
          onImageTap: _handleImagePicker,
          onEditUserName: _showEditUsernameDialog,
        ),
        if (_isUploading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.4),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSettingsSection() {
    return ProfileSectionWidget(
      title: 'Pengaturan',
      items: [
        ProfileMenuItem(
          icon: 'dark_mode',
          title: 'Mode Tampilan',
          subtitle: _getThemeLabel(),
          onTap: _showThemeModeSheet,
        ),
        ProfileMenuItem(
          icon: 'account_balance_wallet',
          title: 'Budget Bulanan',
          subtitle: _formatCurrency(_budget?.amount ?? 0.0),
          onTap: _showBudgetDialog,
        ),
      ],
    );
  }

  Widget _buildDataSection() {
    return ProfileSectionWidget(
      title: 'Data',
      items: [
        ProfileMenuItem(
          icon: 'file_download',
          title: 'Ekspor Transaksi',
          subtitle: 'Download data transaksi',
          onTap: _showExportPeriodSheet,
        ),
      ],
    );
  }
}
