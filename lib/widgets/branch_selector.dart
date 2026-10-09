import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../config/app_config.dart';
import '../config/app_theme.dart';
import '../controllers/auth_controller.dart';
import '../utils/permission_utils.dart';

class BranchSelector extends StatelessWidget {
  const BranchSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final user = AuthController.to.currentUser.value;
      final selectedBranch = AuthController.to.selectedBranch.value;
      final canChange = PermissionUtils.canChangeBranchFilter(user);

      if (!canChange) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.accentTealBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.primaryTeal.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_on, size: 14, color: AppTheme.primaryTeal),
              const SizedBox(width: 6),
              Text(
                selectedBranch,
                style: const TextStyle(
                  color: AppTheme.primaryTeal,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        );
      }

      final branches = ['All', ...AppConfig.supportedBranches];

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.border),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: branches.contains(selectedBranch) ? selectedBranch : branches.first,
            icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: AppTheme.textSecondary),
            isDense: true,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            items: branches.map((b) {
              return DropdownMenuItem<String>(
                value: b,
                child: Row(
                  children: [
                    const Icon(Icons.storefront, size: 14, color: AppTheme.primaryTeal),
                    const SizedBox(width: 6),
                    Text(b == 'All' ? 'All Branches' : '$b Branch'),
                  ],
                ),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                AuthController.to.selectedBranch.value = val;
              }
            },
          ),
        ),
      );
    });
  }
}
