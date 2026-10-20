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
      final masterBranches = AuthController.to.branches.where((b) => b.isActive).toList();

      if (AuthController.to.branches.isEmpty && !AuthController.to.isLoadingBranches.value) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (AuthController.to.branches.isEmpty && !AuthController.to.isLoadingBranches.value) {
            AuthController.to.fetchBranches();
          }
        });
      }
      if (!canChange) {
        // Find matching branch from master if available
        String displayLabel = selectedBranch;
        final matched = masterBranches.firstWhereOrNull(
          (b) => b.shortName.equalsIgnoreCase(selectedBranch) ||
                 b.displayShortName.equalsIgnoreCase(selectedBranch) ||
                 b.code.equalsIgnoreCase(selectedBranch) ||
                 b.name.equalsIgnoreCase(selectedBranch) ||
                 b.city.equalsIgnoreCase(selectedBranch),
        );
        if (matched != null) {
          displayLabel = matched.displayShortName;
        } else if (selectedBranch != 'All') {
          displayLabel = selectedBranch;
        }

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
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 240),
                child: Text(
                  displayLabel,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.primaryTeal,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        );
      }

      // Build options list from Branch Master (with fallback to AppConfig if loading)
      final List<Map<String, String>> branchOptions = [
        {'value': 'All', 'label': 'All Branches'},
      ];

      if (masterBranches.isNotEmpty) {
        for (final b in masterBranches) {
          final sName = b.displayShortName;
          branchOptions.add({'value': sName, 'label': sName});
        }
      } else {
        // Fallback during initial load
        for (final b in AppConfig.supportedBranches) {
          branchOptions.add({'value': b, 'label': b});
        }
      }

      // Determine valid selected value
      String validValue = 'All';
      if (selectedBranch != 'All') {
        final directMatch = branchOptions.firstWhereOrNull((opt) => opt['value']!.equalsIgnoreCase(selectedBranch));
        if (directMatch != null) {
          validValue = directMatch['value']!;
        } else {
          // Check if selectedBranch matches any branch shortName, displayShortName, code, name, city or id
          final matched = masterBranches.firstWhereOrNull(
            (b) => b.shortName.equalsIgnoreCase(selectedBranch) ||
                   b.displayShortName.equalsIgnoreCase(selectedBranch) ||
                   b.code.equalsIgnoreCase(selectedBranch) ||
                   b.name.equalsIgnoreCase(selectedBranch) ||
                   b.city.equalsIgnoreCase(selectedBranch) ||
                   b.id == selectedBranch,
          );
          if (matched != null) {
            final targetVal = matched.displayShortName;
            if (branchOptions.any((opt) => opt['value'] == targetVal)) {
              validValue = targetVal;
            }
          }
        }
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.border),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: validValue,
            icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: AppTheme.textSecondary),
            isDense: true,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            items: branchOptions.map((opt) {
              return DropdownMenuItem<String>(
                value: opt['value'],
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.storefront, size: 14, color: AppTheme.primaryTeal),
                    const SizedBox(width: 6),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 240),
                      child: Text(
                        opt['label']!,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
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

extension on String {
  bool equalsIgnoreCase(String other) => toLowerCase() == other.toLowerCase();
}
