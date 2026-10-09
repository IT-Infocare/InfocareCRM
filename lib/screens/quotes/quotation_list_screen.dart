import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_constants.dart';
import '../../config/app_routes.dart';
import '../../config/app_theme.dart';
import '../../controllers/quotation_controller.dart';
import '../../utils/currency_utils.dart';
import '../../utils/date_utils.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_sidebar.dart';
import '../../widgets/data_table_shell.dart';
import '../../widgets/filter_chip_bar.dart';
import '../../widgets/status_badge.dart';
import 'forms/quotation_form.dart';

class QuotationListScreen extends StatelessWidget {
  const QuotationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(QuotationController());

    return Scaffold(
      body: Row(
        children: [
          const AppSidebar(currentRoute: AppRoutes.quotes),
          Expanded(
            child: Column(
              children: [
                AppHeader(
                  title: 'Quotation / BOQ Manager',
                  actions: [
                    ElevatedButton.icon(
                      onPressed: () => Get.dialog(const QuotationFormDialog()),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('New Quotation'),
                    ),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status Filter
                        Obx(() {
                          return FilterChipBar(
                            options: ['All', ...AppConstants.quotationStatuses],
                            selectedOption: controller.selectedFilterStatus.value,
                            onSelected: (val) {
                              controller.selectedFilterStatus.value = val;
                              controller.fetchQuotations();
                            },
                          );
                        }),
                        const SizedBox(height: 20),

                        // Table
                        Expanded(
                          child: Obx(() {
                            final rows = controller.quotations.map((q) {
                              return DataRow(
                                onSelectChanged: (_) {
                                  Get.toNamed(AppRoutes.quotationDetailWithId(q.id));
                                },
                                cells: [
                                  DataCell(
                                    Row(
                                      children: [
                                        Text(
                                          '${q.quotationNumber} v${q.version}',
                                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                                        ),
                                        if (q.isAiDraft) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppTheme.primaryTeal.withValues(alpha: 0.15),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: const Text('AI Draft', style: TextStyle(fontSize: 10, color: AppTheme.primaryTeal, fontWeight: FontWeight.bold)),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  DataCell(Text(q.customerName)),
                                  DataCell(Text(q.preparedBy)),
                                  DataCell(Text(AppDateUtils.formatDate(q.validUntil))),
                                  DataCell(
                                    Text(
                                      CurrencyUtils.format(q.totalAmount),
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryTeal),
                                    ),
                                  ),
                                  DataCell(StatusBadge(status: q.status)),
                                ],
                              );
                            }).toList();

                            return DataTableShell(
                              isLoading: controller.isLoading.value,
                              columns: const [
                                DataColumn(label: Text('QUOTATION #')),
                                DataColumn(label: Text('CUSTOMER')),
                                DataColumn(label: Text('PREPARED BY')),
                                DataColumn(label: Text('VALID UNTIL')),
                                DataColumn(label: Text('TOTAL (AED)')),
                                DataColumn(label: Text('STATUS')),
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
