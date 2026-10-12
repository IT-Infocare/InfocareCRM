import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_routes.dart';
import '../../config/app_theme.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../utils/currency_utils.dart';
import '../../utils/permission_utils.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_sidebar.dart';
import '../../widgets/data_table_shell.dart';
import '../../widgets/loading_widget.dart';
import 'forms/branch_form.dart';
import 'forms/product_form.dart';
import 'forms/user_form.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SettingsController());
    final currentUser = AuthController.to.currentUser.value;
    final canSeeCost = PermissionUtils.canSeeProductCost(currentUser);
    final canManageUsers = PermissionUtils.canManageUsers(currentUser);

    return Scaffold(
      body: Row(
        children: [
          const AppSidebar(currentRoute: AppRoutes.settings),
          Expanded(
            child: Column(
              children: [
                AppHeader(
                  title: 'Admin Settings & Configuration',
                  actions: [
                    if (canManageUsers)
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryTeal, foregroundColor: Colors.white),
                        onPressed: () => Get.dialog(const UserFormDialog()),
                        icon: const Icon(Icons.person_add_alt, size: 18),
                        label: const Text('Add User'),
                      ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryTealDark, foregroundColor: Colors.white),
                      onPressed: () => Get.dialog(const ProductFormDialog()),
                      icon: const Icon(Icons.add_shopping_cart, size: 18),
                      label: const Text('Add Product'),
                    ),
                  ],
                ),
                Expanded(
                  child: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingWidget(message: 'Loading system configurations...');
        }

        return DefaultTabController(
          length: 4,
          child: Column(
            children: [
              Container(
                color: AppTheme.surface,
                child: const TabBar(
                  isScrollable: false,
                  indicatorColor: AppTheme.primaryTeal,
                  labelColor: AppTheme.primaryTeal,
                  unselectedLabelColor: AppTheme.textSecondary,
                  tabs: [
                    Tab(icon: Icon(Icons.people_outlined, size: 18), text: 'Users & Roles'),
                    Tab(icon: Icon(Icons.storefront_outlined, size: 18), text: 'Branches'),
                    Tab(icon: Icon(Icons.inventory_2_outlined, size: 18), text: 'Products Catalog'),
                    Tab(icon: Icon(Icons.category_outlined, size: 18), text: 'Product Bundles'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    // Tab 1: Users
                    Padding(
                      padding: const EdgeInsets.all(24),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'User Accounts & Access Management',
                                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                                          ),
                                          ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppTheme.primaryTeal,
                                              foregroundColor: Colors.white,
                                            ),
                                            onPressed: () => Get.dialog(const UserFormDialog()),
                                            icon: const Icon(Icons.person_add_alt, size: 18),
                                            label: const Text('Create User'),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Expanded(
                                        child: DataTableShell(
                                          columns: const [
                                            DataColumn(label: Text('USER NAME')),
                                            DataColumn(label: Text('EMAIL')),
                                            DataColumn(label: Text('ROLE')),
                                            DataColumn(label: Text('BRANCH')),
                                            DataColumn(label: Text('PHONE')),
                                            DataColumn(label: Text('ACTIONS')),
                                          ],
                                          rows: controller.users.map((u) {
                                            return DataRow(cells: [
                                              DataCell(Text(u.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                                              DataCell(Text(u.email)),
                                              DataCell(Text(u.role.replaceAll('_', ' ').toUpperCase())),
                                              DataCell(Text(u.branch)),
                                              DataCell(Text(u.phone ?? '-')),
                                              DataCell(Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  IconButton(
                                                    icon: const Icon(Icons.edit_outlined, size: 18, color: AppTheme.primaryTeal),
                                                    tooltip: 'Edit User',
                                                    onPressed: () => Get.dialog(UserFormDialog(user: u)),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                                    tooltip: 'Delete User',
                                                    onPressed: () {
                                                      Get.dialog(
                                                        AlertDialog(
                                                          title: const Text('Confirm User Deletion'),
                                                          content: Text('Are you sure you want to delete user "${u.name}" (${u.email})?'),
                                                          actions: [
                                                            TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
                                                            ElevatedButton(
                                                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                                                              onPressed: () {
                                                                Get.back();
                                                                controller.deleteUser(u.id);
                                                              },
                                                              child: const Text('Delete'),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ],
                                              )),
                                            ]);
                                          }).toList(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Tab 2: Branches
                                Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Branch Master Management',
                                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                                          ),
                                          ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppTheme.primaryTeal,
                                              foregroundColor: Colors.white,
                                            ),
                                            onPressed: () => Get.dialog(const BranchFormDialog()),
                                            icon: const Icon(Icons.add_business_outlined, size: 18),
                                            label: const Text('Add Branch'),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Expanded(
                                        child: DataTableShell(
                                          columns: const [
                                            DataColumn(label: Text('LOGO')),
                                            DataColumn(label: Text('BRANCH NAME')),
                                            DataColumn(label: Text('MANAGER')),
                                            DataColumn(label: Text('LOCATION & COUNTRY')),
                                            DataColumn(label: Text('CURRENCY & VAT')),
                                            DataColumn(label: Text('CONTACT')),
                                            DataColumn(label: Text('WEBSITE & PO BOX')),
                                            DataColumn(label: Text('TRN')),
                                            DataColumn(label: Text('STATUS')),
                                            DataColumn(label: Text('ACTIONS')),
                                          ],
                                          rows: controller.branches.map((b) {
                                            return DataRow(cells: [
                                              DataCell(_buildBranchLogoAvatar(b.logoUrl, b.code)),
                                              DataCell(Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(b.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                                  const SizedBox(height: 3),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: Colors.blueGrey.shade50,
                                                      borderRadius: BorderRadius.circular(4),
                                                      border: Border.all(color: Colors.blueGrey.shade200, width: 0.6),
                                                    ),
                                                    child: Text(
                                                      b.code.isNotEmpty ? b.code : 'CODE',
                                                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade800),
                                                    ),
                                                  ),
                                                ],
                                              )),
                                              DataCell(Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.person_outline, size: 14, color: Colors.grey.shade600),
                                                  const SizedBox(width: 4),
                                                  Text(b.manager.isNotEmpty ? b.manager : '-', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                                                ],
                                              )),
                                              DataCell(Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    b.city.isNotEmpty ? '${b.city}, ${b.country}' : (b.location.isNotEmpty ? b.location : b.country),
                                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                                  ),
                                                  if (b.timezone.isNotEmpty)
                                                    Text(b.timezone, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                                                ],
                                              )),
                                              DataCell(Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: AppTheme.primaryTeal.withValues(alpha: 0.1),
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                    child: Text(
                                                      b.currency,
                                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    '${b.vatPercent.toStringAsFixed(b.vatPercent.truncateToDouble() == b.vatPercent ? 0 : 1)}% VAT',
                                                    style: TextStyle(fontSize: 11, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                                                  ),
                                                ],
                                              )),
                                              DataCell(Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(b.phone.isNotEmpty ? b.phone : (b.mobile.isNotEmpty ? b.mobile : '-'), style: const TextStyle(fontSize: 12)),
                                                  if (b.email.isNotEmpty)
                                                    Text(b.email, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                                                ],
                                              )),
                                              DataCell(Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(b.website.isNotEmpty ? b.website : '-', style: const TextStyle(fontSize: 12, color: AppTheme.primaryTeal)),
                                                  if (b.poBox.isNotEmpty)
                                                    Text(b.poBox, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                                                ],
                                              )),
                                              DataCell(Text(b.trNumber.isNotEmpty ? b.trNumber : '-', style: const TextStyle(fontSize: 12))),
                                              DataCell(Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: (b.isActive ? Colors.green : Colors.grey).withValues(alpha: 0.1),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  b.isActive ? 'Active' : 'Inactive',
                                                  style: TextStyle(color: b.isActive ? Colors.green.shade800 : Colors.grey.shade700, fontWeight: FontWeight.w600, fontSize: 12),
                                                ),
                                              )),
                                              DataCell(Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  IconButton(
                                                    icon: const Icon(Icons.edit_outlined, size: 18, color: AppTheme.primaryTeal),
                                                    tooltip: 'Edit Branch',
                                                    onPressed: () => Get.dialog(BranchFormDialog(branch: b)),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                                    tooltip: 'Delete Branch',
                                                    onPressed: () {
                                                      Get.dialog(
                                                        AlertDialog(
                                                          title: const Text('Confirm Branch Deletion'),
                                                          content: Text('Are you sure you want to delete branch "${b.name}"?'),
                                                          actions: [
                                                            TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
                                                            ElevatedButton(
                                                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                                                              onPressed: () => controller.deleteBranch(b.id),
                                                              child: const Text('Delete'),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ],
                                              )),
                                            ]);
                                          }).toList(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Tab 3: Products Catalog
                                Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: DataTableShell(
                                    columns: [
                                      const DataColumn(label: Text('PRODUCT NAME')),
                                      const DataColumn(label: Text('SKU')),
                                      const DataColumn(label: Text('CATEGORY')),
                                      const DataColumn(label: Text('UNIT PRICE')),
                                      if (canSeeCost) const DataColumn(label: Text('COST PRICE')),
                                    ],
                                    rows: controller.products.map((p) {
                                      return DataRow(cells: [
                                        DataCell(Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                                        DataCell(Text(p.sku)),
                                        DataCell(Text(p.category ?? 'General')),
                                        DataCell(Text(CurrencyUtils.format(p.unitPrice))),
                                        if (canSeeCost) DataCell(Text(CurrencyUtils.format(p.costPrice ?? 0))),
                                      ]);
                                    }).toList(),
                                  ),
                                ),

                                // Tab 4: Product Bundles
                                Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: DataTableShell(
                                    columns: const [
                                      DataColumn(label: Text('BUNDLE NAME')),
                                      DataColumn(label: Text('DESCRIPTION')),
                                      DataColumn(label: Text('PACKAGE PRICE')),
                                    ],
                                    rows: controller.productBundles.map((b) {
                                      return DataRow(cells: [
                                        DataCell(Text(b.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                                        DataCell(Text(b.description ?? '-')),
                                        DataCell(Text(CurrencyUtils.format(b.bundlePrice), style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryTeal))),
                                      ]);
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildBranchLogoAvatar(String logoUrl, String branchCode) {
    Widget child;
    final url = logoUrl.trim();
    if (url.isNotEmpty) {
      if (url.startsWith('data:')) {
        try {
          final commaIdx = url.indexOf(',');
          final base64Content = commaIdx != -1 ? url.substring(commaIdx + 1) : url;
          final bytes = base64Decode(base64Content);
          child = Image.memory(
            bytes,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => _fallbackLogoIcon(branchCode),
          );
        } catch (_) {
          child = _fallbackLogoIcon(branchCode);
        }
      } else if (url.startsWith('http://') || url.startsWith('https://')) {
        child = Image.network(
          url,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => _fallbackLogoIcon(branchCode),
        );
      } else {
        child = _fallbackLogoIcon(branchCode);
      }
    } else {
      child = _fallbackLogoIcon(branchCode);
    }

    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: AppTheme.primaryTeal.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300, width: 0.8),
      ),
      clipBehavior: Clip.antiAlias,
      child: Center(child: child),
    );
  }

  static Widget _fallbackLogoIcon(String branchCode) {
    if (branchCode.isNotEmpty) {
      return Text(
        branchCode.length > 3 ? branchCode.substring(0, 3).toUpperCase() : branchCode.toUpperCase(),
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal),
      );
    }
    return const Icon(Icons.storefront, size: 18, color: AppTheme.primaryTeal);
  }
}
