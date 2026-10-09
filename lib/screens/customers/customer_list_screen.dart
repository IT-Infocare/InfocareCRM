import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_routes.dart';
import '../../config/app_theme.dart';
import '../../controllers/customer_controller.dart';
import '../../utils/currency_utils.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_search_bar.dart';
import '../../widgets/app_sidebar.dart';
import '../../widgets/data_table_shell.dart';
import 'forms/customer_form.dart';

class CustomerListScreen extends StatelessWidget {
  const CustomerListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CustomerController());

    return Scaffold(
      body: Row(
        children: [
          const AppSidebar(currentRoute: AppRoutes.customers),
          Expanded(
            child: Column(
              children: [
                AppHeader(
                  title: 'Customer Directory',
                  actions: [
                    ElevatedButton.icon(
                      onPressed: () => Get.dialog(const CustomerFormDialog()),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Customer'),
                    ),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppSearchBar(
                          hintText: 'Search customers, companies, email...',
                          onChanged: (val) {
                            controller.searchQuery.value = val;
                            controller.fetchCustomers();
                          },
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: Obx(() {
                            final rows = controller.customers.map((c) {
                              return DataRow(
                                onSelectChanged: (_) {
                                  Get.toNamed(AppRoutes.customerDetailWithId(c.id));
                                },
                                cells: [
                                  DataCell(
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                                        if (c.companyName != null)
                                          Text(c.companyName!, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                                      ],
                                    ),
                                  ),
                                  DataCell(Text(c.email)),
                                  DataCell(Text(c.phone)),
                                  DataCell(Text(c.branch)),
                                  DataCell(Text('${c.totalDeals} deals')),
                                  DataCell(
                                    Text(
                                      CurrencyUtils.format(c.totalRevenue),
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryTeal),
                                    ),
                                  ),
                                ],
                              );
                            }).toList();

                            return DataTableShell(
                              isLoading: controller.isLoading.value,
                              columns: const [
                                DataColumn(label: Text('CUSTOMER / COMPANY')),
                                DataColumn(label: Text('EMAIL')),
                                DataColumn(label: Text('PHONE')),
                                DataColumn(label: Text('BRANCH')),
                                DataColumn(label: Text('TOTAL DEALS')),
                                DataColumn(label: Text('TOTAL REVENUE')),
                              ],
                              rows: rows,
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
