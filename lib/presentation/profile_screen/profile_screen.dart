import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../data/models/budget_model.dart';
import '../../data/models/user_model.dart';
import '../../data/services/local_storage_service.dart';
import './widgets/budget_dialog_widget.dart';
import './widgets/edit_username_dialog_widget.dart';
import './widgets/profile_header_widget.dart';
import './widgets/profile_section_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final LocalStorageService _localStorageService = LocalStorageService();

  User? _user;
  Budget? _budget;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
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

  void _showErrorSnackBar(String message) {
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
          _buildProfileHeader(),
          SizedBox(height: 2.h),
          _buildSettingsSection(),
          SizedBox(height: 4.h),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return ProfileHeaderWidget(
      userName: _user?.username ?? 'N/A',
      onEditUserName: _showEditUsernameDialog,
    );
  }

  Widget _buildSettingsSection() {
    return ProfileSectionWidget(
      title: 'Pengaturan',
      items: [
        ProfileMenuItem(
          icon: 'account_balance_wallet',
          title: 'Budget Bulanan',
          subtitle: _formatCurrency(_budget?.amount ?? 0.0),
          onTap: _showBudgetDialog,
        ),
      ],
    );
  }
}
