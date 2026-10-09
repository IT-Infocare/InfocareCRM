import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_constants.dart';
import '../../config/app_routes.dart';
import '../../config/app_theme.dart';
import '../../controllers/task_controller.dart';
import '../../utils/date_utils.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_sidebar.dart';
import '../../widgets/data_table_shell.dart';
import '../../widgets/filter_chip_bar.dart';
import '../../widgets/status_badge.dart';
import '../leads/forms/task_quick_form.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TaskController());

    return Scaffold(
      body: Row(
        children: [
          const AppSidebar(currentRoute: AppRoutes.tasks),
          Expanded(
            child: Column(
              children: [
                AppHeader(
                  title: 'Task & Follow-up Manager',
                  actions: [
                    ElevatedButton.icon(
                      onPressed: () => Get.dialog(const TaskQuickFormDialog()),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Task'),
                    ),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(() {
                          return FilterChipBar(
                            options: ['All', ...AppConstants.taskStatuses],
                            selectedOption: controller.selectedStatusFilter.value,
                            onSelected: (val) {
                              controller.selectedStatusFilter.value = val;
                              controller.fetchTasks();
                            },
                          );
                        }),
                        const SizedBox(height: 20),
                        Expanded(
                          child: Obx(() {
                            final rows = controller.tasks.map((t) {
                              return DataRow(
                                cells: [
                                  DataCell(
                                    Text(
                                      t.title,
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                                    ),
                                  ),
                                  DataCell(Text(t.relatedToTitle ?? 'Lead / Deal')),
                                  DataCell(Text(t.assignedUserName)),
                                  DataCell(Text(AppDateUtils.formatDateTime(t.dueDate, format: 'MMM dd, hh:mm a'))),
                                  DataCell(
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppTheme.accentTealBg,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        t.priority.toUpperCase(),
                                        style: const TextStyle(fontSize: 10, color: AppTheme.primaryTeal, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  DataCell(StatusBadge(status: t.status)),
                                  DataCell(
                                    t.status != 'completed'
                                        ? TextButton.icon(
                                            onPressed: () => controller.updateTaskStatus(t.id, 'completed'),
                                            icon: const Icon(Icons.check_circle_outline, size: 16),
                                            label: const Text('Mark Done'),
                                          )
                                        : const Icon(Icons.check_circle, color: AppTheme.success, size: 20),
                                  ),
                                ],
                              );
                            }).toList();

                            return DataTableShell(
                              isLoading: controller.isLoading.value,
                              columns: const [
                                DataColumn(label: Text('TASK TITLE')),
                                DataColumn(label: Text('RELATED TO')),
                                DataColumn(label: Text('ASSIGNED TO')),
                                DataColumn(label: Text('DUE DATE')),
                                DataColumn(label: Text('PRIORITY')),
                                DataColumn(label: Text('STATUS')),
                                DataColumn(label: Text('ACTION')),
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
