import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../config/app_routes.dart';
import '../config/app_theme.dart';
import '../controllers/auth_controller.dart';
import '../utils/formatters.dart';
import 'branch_selector.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const AppHeader({
    super.key,
    required this.title,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64.0);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: preferredSize.height,
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          bottom: BorderSide(color: AppTheme.border, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(width: 24),
          const BranchSelector(),
          const Spacer(),
          if (actions != null) ...actions!,
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppTheme.textSecondary),
            onPressed: () {
              Get.snackbar(
                'Notifications',
                'You have 3 unread tasks and follow-up reminders.',
                snackPosition: SnackPosition.TOP,
                margin: const EdgeInsets.all(16),
                duration: const Duration(seconds: 3),
              );
            },
          ),
          const SizedBox(width: 12),
          const VerticalDivider(indent: 16, endIndent: 16),
          const SizedBox(width: 12),
          Obx(() {
            final user = AuthController.to.currentUser.value;
            final initials = AppFormatters.getInitials(user?.name ?? 'User');

            return PopupMenuButton<String>(
              offset: const Offset(0, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  enabled: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? 'User',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                      ),
                      Text(
                        'Role: ${AppFormatters.enumToHuman(user?.role ?? '')}',
                        style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                      ),
                      const Divider(),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'settings',
                  child: const Row(
                    children: [
                      Icon(Icons.settings_outlined, size: 18),
                      SizedBox(width: 8),
                      Text('Settings'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'logout',
                  child: const Row(
                    children: [
                      Icon(Icons.logout, size: 18, color: AppTheme.danger),
                      SizedBox(width: 8),
                      Text('Logout', style: TextStyle(color: AppTheme.danger)),
                    ],
                  ),
                ),
              ],
              onSelected: (val) {
                if (val == 'settings') {
                  Get.toNamed(AppRoutes.settings);
                } else if (val == 'logout') {
                  AuthController.to.logout();
                }
              },
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppTheme.primaryTeal,
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? 'User',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        AppFormatters.enumToHuman(user?.role ?? ''),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const Icon(Icons.keyboard_arrow_down, size: 16, color: AppTheme.textSecondary),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
