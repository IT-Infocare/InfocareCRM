import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_routes.dart';
import '../../config/app_theme.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../utils/permission_utils.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_sidebar.dart';
import '../../widgets/data_table_shell.dart';
import '../../widgets/loading_widget.dart';
import 'forms/branch_form.dart';
import 'forms/company_form.dart';
import 'forms/user_form.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SettingsController());
    final currentUser = AuthController.to.currentUser.value;
    final canManageUsers = PermissionUtils.canManageUsers(currentUser);
    final isAdmin = PermissionUtils.isAdmin(currentUser);

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
                    if (isAdmin) ...[
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryTeal, foregroundColor: Colors.white),
                        onPressed: () => Get.dialog(const CompanyFormDialog()),
                        icon: const Icon(Icons.corporate_fare, size: 18),
                        label: const Text('Add Company'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryTealDark, foregroundColor: Colors.white),
                        onPressed: () => Get.dialog(const BranchFormDialog()),
                        icon: const Icon(Icons.add_business, size: 18),
                        label: const Text('Add Branch'),
                      ),
                    ],
                  ],
                ),
                Expanded(
                  child: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingWidget(message: 'Loading system configurations...');
        }

        return DefaultTabController(
          length: 3,
          child: Column(
            children: [
              Container(
                color: AppTheme.surface,
                child: const TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  indicatorColor: AppTheme.primaryTeal,
                  labelColor: AppTheme.primaryTeal,
                  unselectedLabelColor: AppTheme.textSecondary,
                  tabs: [
                    Tab(icon: Icon(Icons.people_outlined, size: 18), text: 'Users & Roles'),
                    Tab(icon: Icon(Icons.corporate_fare_outlined, size: 18), text: 'Companies (Parent)'),
                    Tab(icon: Icon(Icons.storefront_outlined, size: 18), text: 'Branches'),
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
                                          const Expanded(
                                            child: Text(
                                              'User Accounts & Access Management',
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
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

                                // Tab 2: Companies (Parent)
                                Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'Parent Companies & Holding Entities',
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  'Parent enterprise entities (e.g. InfoCare Systems) governing subsidiary branch networks',
                                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppTheme.primaryTeal,
                                              foregroundColor: Colors.white,
                                            ),
                                            onPressed: () => Get.dialog(const CompanyFormDialog()),
                                            icon: const Icon(Icons.corporate_fare, size: 18),
                                            label: const Text('Add Company'),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Expanded(
                                        child: DataTableShell(
                                          columns: const [
                                            DataColumn(label: Text('COMPANY NAME')),
                                            DataColumn(label: Text('TRADE LICENSE & TRN')),
                                            DataColumn(label: Text('INDUSTRY & EMIRATE')),
                                            DataColumn(label: Text('BRANCHES COUNT')),
                                            DataColumn(label: Text('HEADQUARTERS & WEBSITE')),
                                            DataColumn(label: Text('CONTACT')),
                                            DataColumn(label: Text('STATUS')),
                                            DataColumn(label: Text('ACTIONS')),
                                          ],
                                          rows: controller.companies.map((c) {
                                            final branchCount = controller.branches.where((b) => b.companyId == c.id).length;
                                            return DataRow(cells: [
                                              DataCell(Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Container(
                                                    width: 36,
                                                    height: 36,
                                                    decoration: BoxDecoration(
                                                      color: AppTheme.primaryTeal.withValues(alpha: 0.1),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: const Icon(Icons.corporate_fare, color: AppTheme.primaryTeal, size: 20),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                                      if (c.code.isNotEmpty)
                                                        Container(
                                                          margin: const EdgeInsets.only(top: 2),
                                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                          decoration: BoxDecoration(
                                                            color: Colors.teal.shade50,
                                                            borderRadius: BorderRadius.circular(4),
                                                            border: Border.all(color: Colors.teal.shade200, width: 0.6),
                                                          ),
                                                          child: Text(
                                                            c.code,
                                                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.teal.shade900),
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ],
                                              )),
                                              DataCell(Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(c.tradeLicenceNo?.isNotEmpty == true ? c.tradeLicenceNo! : 'No Lic No', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                                  if (c.taxNumber?.isNotEmpty == true)
                                                    Text('TRN: ${c.taxNumber}', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                                                ],
                                              )),
                                              DataCell(Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(c.industry?.isNotEmpty == true ? c.industry! : 'General', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                                                  Text(c.emirate?.isNotEmpty == true ? '${c.emirate}, ${c.country}' : c.country, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                                                ],
                                              )),
                                              DataCell(Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: AppTheme.accentTealBg,
                                                  borderRadius: BorderRadius.circular(12),
                                                  border: Border.all(color: AppTheme.primaryTeal.withValues(alpha: 0.2)),
                                                ),
                                                child: Text(
                                                  '$branchCount ${branchCount == 1 ? "Branch" : "Branches"}',
                                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal),
                                                ),
                                              )),
                                              DataCell(Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(c.city?.isNotEmpty == true ? c.city! : c.country, style: const TextStyle(fontSize: 12)),
                                                  if (c.website?.isNotEmpty == true)
                                                    Text(c.website!, style: TextStyle(fontSize: 11, color: Colors.blue.shade700)),
                                                ],
                                              )),
                                              DataCell(Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  if (c.email?.isNotEmpty == true)
                                                    Text(c.email!, style: const TextStyle(fontSize: 11)),
                                                  if (c.phone?.isNotEmpty == true)
                                                    Text(c.phone!, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                                                ],
                                              )),
                                              DataCell(Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: c.isActive ? Colors.green.shade50 : Colors.grey.shade100,
                                                  borderRadius: BorderRadius.circular(4),
                                                  border: Border.all(color: c.isActive ? Colors.green.shade200 : Colors.grey.shade300, width: 0.6),
                                                ),
                                                child: Text(
                                                  c.isActive ? 'Active' : 'Inactive',
                                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: c.isActive ? Colors.green.shade800 : Colors.grey.shade700),
                                                ),
                                              )),
                                              DataCell(Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  IconButton(
                                                    icon: const Icon(Icons.edit_outlined, size: 18, color: AppTheme.primaryTeal),
                                                    tooltip: 'Edit Company',
                                                    onPressed: () => Get.dialog(CompanyFormDialog(company: c)),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                                    tooltip: 'Delete Company',
                                                    onPressed: () {
                                                      Get.dialog(
                                                        AlertDialog(
                                                          title: const Text('Confirm Deletion'),
                                                          content: Text('Are you sure you want to delete parent company "${c.name}"?'),
                                                          actions: [
                                                            TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
                                                            ElevatedButton(
                                                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                                                              onPressed: () => controller.deleteCompany(c.id),
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

                                // Tab 3: Branches
                                Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'Branch Master Management',
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  'Operating branches running under their respective parent companies',
                                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 12),
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
                                            DataColumn(label: Text('SHORT NAME')),
                                            DataColumn(label: Text('PARENT COMPANY')),
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
                                              DataCell(Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: AppTheme.accentTealBg,
                                                  borderRadius: BorderRadius.circular(6),
                                                  border: Border.all(color: AppTheme.primaryTeal.withValues(alpha: 0.2)),
                                                ),
                                                child: Text(
                                                  b.shortName.isNotEmpty ? b.shortName : (b.code.isNotEmpty ? b.code : '-'),
                                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.primaryTeal),
                                                ),
                                              )),
                                              DataCell(Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: AppTheme.accentTealBg,
                                                  borderRadius: BorderRadius.circular(6),
                                                  border: Border.all(color: AppTheme.primaryTeal.withValues(alpha: 0.2)),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    const Icon(Icons.apartment, size: 13, color: AppTheme.primaryTeal),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      controller.getCompanyName(b.companyId),
                                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal),
                                                    ),
                                                  ],
                                                ),
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
