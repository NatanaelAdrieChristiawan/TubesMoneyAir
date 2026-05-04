import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class WalletSelectorWidget extends StatelessWidget {
  final String? selectedWallet;
  final Function(String) onWalletSelected;

  const WalletSelectorWidget({
    Key? key,
    required this.selectedWallet,
    required this.onWalletSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Normalize legacy/localized wallet names to the canonical ones we use in the UI
    final displayWallet = _normalizeWalletName(selectedWallet);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dompet',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.h),
        GestureDetector(
          onTap: () => _showWalletSelector(context),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: _getWalletIcon(displayWallet),
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                SizedBox(width: 3.w),
                Text(
                  displayWallet,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Spacer(),
                CustomIconWidget(
                  iconName: 'keyboard_arrow_down',
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showWalletSelector(BuildContext context) {
    HapticFeedback.lightImpact();
    final normalizedSelected = _normalizeWalletName(selectedWallet);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                width: 10.w,
                height: 0.5.h,
                margin: EdgeInsets.symmetric(vertical: 1.h),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Text(
                  'Pilih Dompet',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
              ),
              SizedBox(height: 2.h),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: walletOptions.length,
                  itemBuilder: (context, index) {
                    final wallet = walletOptions[index];
                    return ListTile(
                      leading: CustomIconWidget(
                        iconName: wallet['icon'] as String,
                        color: Theme.of(context).colorScheme.primary,
                        size: 24,
                      ),
                      title: Text(
                        wallet['name'] as String,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                      trailing: normalizedSelected == wallet['name']
                          ? CustomIconWidget(
                              iconName: 'check',
                              color: Theme.of(context).colorScheme.primary,
                              size: 20,
                            )
                          : null,
                      onTap: () {
                        onWalletSelected(wallet['name'] as String);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 1.h),
            ],
          ),
        ),
      ),
    );
  }

  String _getWalletIcon(String walletName) {
    final normalized = _normalizeWalletName(walletName);
    final wallet = walletOptions.firstWhere(
      (w) => w['name'] == normalized,
      orElse: () => walletOptions.first,
    );
    return wallet['icon'] as String;
  }

  // Map legacy/localized names to canonical display names used in walletOptions
  String _normalizeWalletName(String? name) {
    final n = (name ?? 'Cash').trim();
    if (n.toLowerCase() == 'kas') return 'Cash';
    return n;
  }

  static final List<Map<String, dynamic>> walletOptions = [
    {'name': 'Cash', 'icon': 'account_balance_wallet'},
    {'name': 'Bank BCA', 'icon': 'account_balance'},
    {'name': 'Bank Mandiri', 'icon': 'account_balance'},
    {'name': 'Bank BRI', 'icon': 'account_balance'},
    {'name': 'Bank BNI', 'icon': 'account_balance'},
    {'name': 'GoPay', 'icon': 'payment'},
    {'name': 'OVO', 'icon': 'payment'},
    {'name': 'DANA', 'icon': 'payment'},
    {'name': 'ShopeePay', 'icon': 'payment'},
  ];
}
