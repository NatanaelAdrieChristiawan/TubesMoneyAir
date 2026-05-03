import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ProfileHeaderWidget extends StatelessWidget {
  final String userName;
  final VoidCallback onEditUserName;

  const ProfileHeaderWidget({
    Key? key,
    required this.userName,
    required this.onEditUserName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile Photo Placeholder (No Interaction)
          Container(
            width: 30.w,
            height: 30.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.colorScheme.primary,
                width: 3,
              ),
            ),
            child: ClipOval(
              child: Container(
                color: theme.colorScheme.primaryContainer,
                child: CustomIconWidget(
                  iconName: 'person',
                  color: theme.colorScheme.onPrimaryContainer,
                  size: 15.w,
                ),
              ),
            ),
          ),
          SizedBox(height: 2.h),
          // Username with Edit Icon
          GestureDetector(
            onTap: onEditUserName,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    userName.isNotEmpty ? userName : 'Nama Pengguna',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 2.w),
                CustomIconWidget(
                  iconName: 'edit',
                  color: theme.colorScheme.primary,
                  size: 5.w,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
