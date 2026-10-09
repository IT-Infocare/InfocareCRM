import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_routes.dart';
import '../../config/app_theme.dart';
import '../../controllers/report_controller.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_sidebar.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/stat_card.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ReportController());

    return Scaffold(
      body: Row(
        children: [
          const AppSidebar(currentRoute: AppRoutes.reports),
          Expanded(
            child: Column(
              children: [
                const AppHeader(title: 'Business Intelligence & Reports'),
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const LoadingWidget(message: 'Generating analytical reports...');
                    }

                    final data = controller.reportData;

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Performance Metrics Overview',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: StatCard(
                                  title: 'Total Quotes Sent',
                                  value: '${data['quotation_performance']?['total_quotes_sent'] ?? 45}',
                                  icon: Icons.send_outlined,
                                  accentColor: AppTheme.primaryTeal,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: StatCard(
                                  title: 'Quotation Approval Rate',
                                  value: '${data['quotation_performance']?['approval_rate'] ?? 62.2}%',
                                  icon: Icons.check_circle_outline,
                                  accentColor: AppTheme.success,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: StatCard(
                                  title: 'Avg Response SLA',
                                  value: '${data['quotation_performance']?['avg_response_days'] ?? 3.5} Days',
                                  icon: Icons.timer_outlined,
                                  accentColor: AppTheme.warning,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Detailed Report Sections Grid
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: AppTheme.surface,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppTheme.border),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Pipeline Value by Branch', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 16),
                                      _buildReportItem('Dubai HQ', 'AED 485,000', 0.7, AppTheme.primaryTeal),
                                      _buildReportItem('RAK Branch', 'AED 210,000', 0.4, AppTheme.info),
                                      _buildReportItem('Kerala Back Office', 'AED 95,000', 0.2, AppTheme.warning),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: AppTheme.surface,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppTheme.border),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Conversion Rate by Sales Executive', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 16),
                                      _buildReportItem('Sarah Connor', '24.5% Won', 0.8, AppTheme.success),
                                      _buildReportItem('Rahul Verma', '19.8% Won', 0.65, AppTheme.primaryTeal),
                                      _buildReportItem('Amal Kumar', '16.2% Won', 0.5, AppTheme.info),
                                    ],
                                  ),
                                ),
                              ),
                            ],
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

  Widget _buildReportItem(String label, String val, double progress, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppTheme.background,
            color: color,
            minHeight: 6,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}
