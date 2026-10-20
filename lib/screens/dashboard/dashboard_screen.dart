import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_routes.dart';
import '../../config/app_theme.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/dashboard_controller.dart';
import '../../utils/currency_utils.dart';
import '../../utils/date_utils.dart';
import '../../utils/lead_source_utils.dart';
import '../../utils/responsive_utils.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_sidebar.dart';
import '../../widgets/stat_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DashboardController());

    return Scaffold(
      body: Row(
        children: [
          const AppSidebar(currentRoute: AppRoutes.dashboard),
          Expanded(
            child: Column(
              children: [
                const AppHeader(title: 'Executive Dashboard'),
                Expanded(
                  child: Obx(() {
                    final summary = controller.summary.value;
                    final isDesktop = ResponsiveUtils.isDesktop(context);

                    return Stack(
                      children: [
                        SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          // Executive Welcome Header
                          Obx(() {
                            final user = AuthController.to.currentUser.value;
                            final fullName = (user?.name.isNotEmpty == true
                                    ? user!.name
                                    : (user?.username.isNotEmpty == true ? user!.username : 'User'))
                                .trim();
                            String displayName = fullName;
                            if (fullName.toLowerCase() == 'system administrator' || fullName.toLowerCase() == 'system admin') {
                              displayName = 'Admin';
                            } else if (fullName.contains(' ')) {
                              displayName = fullName.split(' ').first;
                            }
                            final hour = DateTime.now().hour;
                            final greeting = hour < 12
                                ? 'Good morning'
                                : (hour < 17 ? 'Good afternoon' : 'Good evening');
                            final dateFormatted = AppDateUtils.formatDate(DateTime.now(), format: 'EEEE, d MMMM yyyy');

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$greeting, $displayName',
                                    style: const TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.textPrimary,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Obx(() {
                                    final sel = Get.isRegistered<AuthController>()
                                        ? AuthController.to.selectedBranch.value
                                        : 'All';
                                    final label = sel == 'All' ? 'All branches' : '$sel branch';
                                    return Text(
                                      '$dateFormatted • $label',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppTheme.textSecondary,
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            );
                          }),

                          // KPI Cards Grid
                          GridView.count(
                            crossAxisCount: isDesktop ? 4 : 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            shrinkWrap: true,
                            childAspectRatio: isDesktop ? 2.0 : 1.6,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              StatCard(
                                title: 'New Leads This Week',
                                value: '${summary?.newLeadsThisWeek ?? 0}',
                                icon: Icons.person_add_alt_1_outlined,
                                accentColor: AppTheme.primaryTeal,
                                subtitle: summary?.newLeadsSubtitle?.isNotEmpty == true
                                    ? summary!.newLeadsSubtitle
                                    : '${summary?.newLeadsThisWeek ?? 0} new this week',
                              ),
                              StatCard(
                                title: 'Open Pipeline Value',
                                value: CurrencyUtils.formatCompact(summary?.openPipelineValue ?? 0),
                                icon: Icons.trending_up,
                                accentColor: AppTheme.info,
                                subtitle: summary?.openPipelineSubtitle?.isNotEmpty == true
                                    ? summary!.openPipelineSubtitle
                                    : ((summary?.openDealsCount ?? 0) == 0 ? 'No open deals' : 'Across ${summary?.openDealsCount} open deals'),
                              ),
                              StatCard(
                                title: 'Quotes Awaiting Reply',
                                value: '${summary?.quotesAwaitingReply ?? 0}',
                                icon: Icons.request_quote_outlined,
                                accentColor: AppTheme.warning,
                                subtitle: summary?.quotesSubtitle?.isNotEmpty == true
                                    ? summary!.quotesSubtitle
                                    : ((summary?.quotesAwaitingReply ?? 0) == 0 ? 'All quotations up to date' : '${summary?.quotesAwaitingReply} require follow-up'),
                              ),
                              StatCard(
                                title: 'Follow-ups Due Today',
                                value: '${summary?.followUpsDue ?? 0}',
                                icon: (summary?.followUpsDue ?? 0) > 0 ? Icons.alarm_outlined : Icons.check_circle_outline,
                                accentColor: (summary?.followUpsDue ?? 0) > 0 ? AppTheme.danger : AppTheme.success,
                                subtitle: summary?.followUpsSubtitle?.isNotEmpty == true
                                    ? summary!.followUpsSubtitle
                                    : ((summary?.followUpsDue ?? 0) == 0 ? 'All follow-ups completed' : '${summary?.followUpsDue} action required today'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Main Content (Leads by Source + Today's Follow-ups)
                          Builder(
                            builder: (context) {
                              final leadsCard = Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: AppTheme.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppTheme.border),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Leads by Source',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.textPrimary,
                                          ),
                                        ),
                                        Icon(Icons.pie_chart_outline, color: AppTheme.textSecondary, size: 20),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    ...controller.leadsBySource.entries.map((entry) {
                                      final source = entry.key;
                                      final count = entry.value;
                                      final total = controller.leadsBySource.values.fold(0, (a, b) => a + b);
                                      final percentage = total > 0 ? (count / total) : 0.0;

                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Flexible(
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        LeadSourceUtils.getIcon(source),
                                                        size: 16,
                                                        color: LeadSourceUtils.getColor(source),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Flexible(
                                                        child: Text(
                                                          LeadSourceUtils.getLabel(source),
                                                          overflow: TextOverflow.ellipsis,
                                                          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  '$count leads (${(percentage * 100).toStringAsFixed(0)}%)',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color: AppTheme.textSecondary,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            LinearProgressIndicator(
                                              value: percentage,
                                              backgroundColor: AppTheme.background,
                                              color: LeadSourceUtils.getColor(source),
                                              minHeight: 6,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              );

                              final followUpsCard = Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: AppTheme.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppTheme.border),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          "Today's Action Follow-ups",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.textPrimary,
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () => Get.toNamed(AppRoutes.tasks),
                                          child: const Text('View All Tasks'),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    if (controller.todayFollowUps.isEmpty)
                                      const Padding(
                                        padding: EdgeInsets.all(24),
                                        child: Center(child: Text('No follow-ups due today')),
                                      )
                                    else
                                      ListView.separated(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemCount: controller.todayFollowUps.length,
                                        separatorBuilder: (_, __) => const Divider(height: 16),
                                        itemBuilder: (context, index) {
                                          final task = controller.todayFollowUps[index];
                                          return ListTile(
                                            contentPadding: EdgeInsets.zero,
                                            leading: CircleAvatar(
                                              backgroundColor: task.priority == 'high'
                                                  ? AppTheme.danger.withValues(alpha: 0.1)
                                                  : AppTheme.warning.withValues(alpha: 0.1),
                                              child: Icon(
                                                Icons.task_alt,
                                                color: task.priority == 'high' ? AppTheme.danger : AppTheme.warning,
                                                size: 20,
                                              ),
                                            ),
                                            title: Text(
                                              task.title,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                            ),
                                            subtitle: Text(
                                              'Related to: ${task.relatedToTitle ?? "Lead"} • Assigned: ${task.assignedUserName}',
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                                            ),
                                            trailing: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  AppDateUtils.formatDateTime(task.dueDate, format: 'hh:mm a'),
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: AppTheme.textPrimary,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: AppTheme.accentTealBg,
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: Text(
                                                    task.priority.toUpperCase(),
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                      color: AppTheme.primaryTeal,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                  ],
                                ),
                              );

                              if (isDesktop) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(flex: 5, child: leadsCard),
                                    const SizedBox(width: 20),
                                    Expanded(flex: 7, child: followUpsCard),
                                  ],
                                );
                              } else {
                                return Column(
                                  children: [
                                    leadsCard,
                                    const SizedBox(height: 20),
                                    followUpsCard,
                                  ],
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    if (controller.isSyncing.value)
                      const Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: LinearProgressIndicator(
                          minHeight: 2.5,
                          color: AppTheme.primaryTeal,
                          backgroundColor: Colors.transparent,
                        ),
                      ),
                  ],
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
