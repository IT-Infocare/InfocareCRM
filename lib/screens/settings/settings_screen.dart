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
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryTealDark),
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
                                          ],
                                          rows: controller.users.map((u) {
                                            return DataRow(cells: [
                                              DataCell(Text(u.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                                              DataCell(Text(u.email)),
                                              DataCell(Text(u.role.replaceAll('_', ' ').toUpperCase())),
                                              DataCell(Text(u.branch)),
                                              DataCell(Text(u.phone ?? '-')),
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
                                            DataColumn(label: Text('BRANCH NAME')),
                                            DataColumn(label: Text('CODE / ALIAS')),
                                            DataColumn(label: Text('TIME ZONE')),
                                            DataColumn(label: Text('TELEPHONE / MOBILE')),
                                            DataColumn(label: Text('EMAIL')),
                                            DataColumn(label: Text('LOCATION')),
                                            DataColumn(label: Text('TRN')),
                                            DataColumn(label: Text('STATUS')),
                                            DataColumn(label: Text('ACTIONS')),
                                          ],
                                          rows: controller.branches.map((b) {
                                            return DataRow(cells: [
                                              DataCell(Text(b.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                                              DataCell(Text(b.code)),
                                              DataCell(Text(b.timezone.isNotEmpty ? b.timezone : 'Asia/Dubai', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500))),
                                              DataCell(Text(b.phone.isNotEmpty ? b.phone : (b.mobile.isNotEmpty ? b.mobile : '-'), style: const TextStyle(fontSize: 12))),
                                              DataCell(Text(b.email.isNotEmpty ? b.email : '-', style: const TextStyle(fontSize: 12))),
                                              DataCell(Text(b.location.isNotEmpty ? b.location : '-', style: const TextStyle(fontSize: 12))),
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
}
