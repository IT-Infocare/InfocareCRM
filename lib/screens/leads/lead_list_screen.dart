import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_constants.dart';
import '../../config/app_routes.dart';
import '../../config/app_theme.dart';
import '../../controllers/lead_controller.dart';
import '../../utils/currency_utils.dart';
import '../../utils/date_utils.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_search_bar.dart';
import '../../widgets/app_sidebar.dart';
import '../../widgets/data_table_shell.dart';
import '../../widgets/filter_chip_bar.dart';
import '../../widgets/source_badge.dart';
import '../../widgets/stage_badge.dart';
import 'forms/lead_form.dart';

class LeadListScreen extends StatelessWidget {
  const LeadListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LeadController());

    return Scaffold(
      body: Row(
        children: [
          const AppSidebar(currentRoute: AppRoutes.leads),
          Expanded(
            child: Column(
              children: [
                AppHeader(
                  title: 'Lead Inbox',
                  actions: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Get.dialog(const LeadFormDialog());
                      },
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('New Lead'),
                    ),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Search & Filter Toolbar
                        Row(
                          children: [
                            AppSearchBar(
                              hintText: 'Search leads by name, company, requirement...',
                              onChanged: (val) {
                                controller.searchQuery.value = val;
                                controller.fetchLeads(page: 1);
                              },
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Obx(() {
                                return FilterChipBar(
                                  options: ['All', ...AppConstants.leadSources],
                                  selectedOption: controller.selectedSource.value,
                                  onSelected: (val) {
                                    controller.selectedSource.value = val;
                                    controller.fetchLeads(page: 1);
                                  },
                                );
                              }),
                            ),
                            OutlinedButton.icon(
                              onPressed: () {
                                Get.snackbar('Export CSV', 'CSV export triggered via backend API');
                              },
                              icon: const Icon(Icons.download, size: 16),
                              label: const Text('Export'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Table
                        Expanded(
                          child: Obx(() {
                            final rows = controller.leads.map((lead) {
                              return DataRow(
                                onSelectChanged: (_) {
                                  Get.toNamed(AppRoutes.leadDetailWithId(lead.id));
                                },
                                cells: [
                                  DataCell(
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          lead.contactName,
                                          style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                                        ),
                                        if (lead.companyName != null)
                                          Text(
                                            lead.companyName!,
                                            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                                          ),
                                      ],
                                    ),
                                  ),
                                  DataCell(
                                    SizedBox(
                                      width: 240,
                                      child: Text(
                                        lead.requirement,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ),
                                  DataCell(SourceBadge(source: lead.source)),
                                  DataCell(Text(lead.branch)),
                                  DataCell(Text(lead.ownerName ?? 'Unassigned')),
                                  DataCell(StageBadge(stage: lead.stage)),
                                  DataCell(
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          AppDateUtils.calculateAge(lead.createdAt),
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                        ),
                                        Text(
                                          CurrencyUtils.formatCompact(lead.estimatedValue),
                                          style: const TextStyle(fontSize: 11, color: AppTheme.primaryTeal, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }).toList();

                            return DataTableShell(
                              isLoading: controller.isLoading.value,
                              pagination: controller.pagination.value,
                              onPageChanged: (page) => controller.fetchLeads(page: page),
                              columns: const [
                                DataColumn(label: Text('LEAD / COMPANY')),
                                DataColumn(label: Text('REQUIREMENT')),
                                DataColumn(label: Text('SOURCE')),
                                DataColumn(label: Text('BRANCH')),
                                DataColumn(label: Text('OWNER')),
                                DataColumn(label: Text('STAGE')),
                                DataColumn(label: Text('AGE / VALUE')),
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
