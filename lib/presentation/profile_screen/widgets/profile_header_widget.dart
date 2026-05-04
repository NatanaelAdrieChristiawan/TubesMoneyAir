import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ProfileHeaderWidget extends StatelessWidget {
  final String userName;
  final String profileImageUrl;
  final VoidCallback onEditUserName;
  final VoidCallback onImageTap;

  const ProfileHeaderWidget({
    Key? key,
    required this.userName,
    required this.profileImageUrl,
    required this.onEditUserName,
    required this.onImageTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile Photo (tappable)
          GestureDetector(
            onTap: onImageTap,
            child: Stack(
              children: [
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
                    child: _buildProfileImage(theme),
                  ),
                ),
                // Camera badge
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 9.w,
                    height: 9.w,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.surface,
                        width: 2,
                      ),
                    ),
                    child: CustomIconWidget(
                      iconName: 'camera_alt',
                      color: theme.colorScheme.onPrimary,
                      size: 4.w,
                    ),
                  ),
                ),
              ],
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

  Widget _buildProfileImage(ThemeData theme) {
    if (profileImageUrl.isNotEmpty) {
      if (kIsWeb) {
        return Image.network(
          profileImageUrl,
          fit: BoxFit.cover,
          width: 30.w,
          height: 30.w,
          errorBuilder: (_, __, ___) => _buildDefaultAvatar(theme),
        );
      } else {
        final file = File(profileImageUrl);
        if (file.existsSync()) {
          return Image.file(
            file,
            fit: BoxFit.cover,
            width: 30.w,
            height: 30.w,
            errorBuilder: (_, __, ___) => _buildDefaultAvatar(theme),
          );
        }
      }
    }
    return _buildDefaultAvatar(theme);
  }

  Widget _buildDefaultAvatar(ThemeData theme) {
    return Container(
      color: theme.colorScheme.primaryContainer,
      child: CustomIconWidget(
        iconName: 'person',
        color: theme.colorScheme.onPrimaryContainer,
        size: 15.w,
      ),
    );
  }
}
