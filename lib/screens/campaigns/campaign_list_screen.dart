import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_routes.dart';
import '../../config/app_theme.dart';
import '../../controllers/campaign_controller.dart';
import '../../utils/currency_utils.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_sidebar.dart';
import '../../widgets/data_table_shell.dart';
import '../../widgets/source_badge.dart';

class CampaignListScreen extends StatelessWidget {
  const CampaignListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CampaignController());

    return Scaffold(
      body: Row(
        children: [
          const AppSidebar(currentRoute: AppRoutes.campaigns),
          Expanded(
            child: Column(
              children: [
                AppHeader(
                  title: 'Campaign & Source Attribution',
                  actions: [
                    ElevatedButton.icon(
                      onPressed: () => Get.snackbar('New Campaign', 'Opening campaign creator'),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('New Campaign'),
                    ),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Obx(() {
                            final rows = controller.campaigns.map((cmp) {
                              return DataRow(
                                cells: [
                                  DataCell(
                                    Text(cmp.name, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                                  ),
                                  DataCell(SourceBadge(source: cmp.channel)),
                                  DataCell(Text(CurrencyUtils.format(cmp.budget))),
                                  DataCell(Text('${cmp.leadCount} leads')),
                                  DataCell(Text('${cmp.conversionRate}%')),
                                  DataCell(
                                    Text(
                                      CurrencyUtils.format(cmp.revenueGenerated),
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryTeal),
                                    ),
                                  ),
                                  DataCell(
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: cmp.isActive ? AppTheme.success.withValues(alpha: 0.1) : AppTheme.background,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        cmp.isActive ? 'ACTIVE' : 'ENDED',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: cmp.isActive ? AppTheme.success : AppTheme.textMuted,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList();

                            return DataTableShell(
                              isLoading: controller.isLoading.value,
                              columns: const [
                                DataColumn(label: Text('CAMPAIGN NAME')),
                                DataColumn(label: Text('CHANNEL')),
                                DataColumn(label: Text('BUDGET')),
                                DataColumn(label: Text('LEADS GENERATED')),
                                DataColumn(label: Text('CONVERSION RATE')),
                                DataColumn(label: Text('REVENUE GENERATED')),
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
