import 'package:get/get.dart';
import '../models/task_model.dart';
import '../services/api_service.dart';
import '../services/task_service.dart';

import 'auth_controller.dart';

class TaskController extends GetxController {
  final TaskService _taskService = TaskService(Get.find<ApiService>());

  final RxBool isLoading = true.obs;
  final RxList<TaskModel> tasks = <TaskModel>[].obs;
  final RxString selectedStatusFilter = 'All'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTasks();
    if (Get.isRegistered<AuthController>()) {
      ever(AuthController.to.selectedBranch, (_) => fetchTasks());
    }
  }

  Future<void> fetchTasks() async {
    isLoading.value = true;
    try {
      final selectedBranch = Get.isRegistered<AuthController>() ? AuthController.to.selectedBranch.value : 'All';
      final res = await _taskService.getTasks(
        status: selectedStatusFilter.value != 'All' ? selectedStatusFilter.value : null,
        branch: selectedBranch != 'All' ? selectedBranch : null,
      );
      if (res.success && res.data != null) {
        tasks.assignAll(res.data!);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateTaskStatus(String id, String status) async {
    final res = await _taskService.updateTaskStatus(id, status);
    if (res.success && res.data != null) {
      final index = tasks.indexWhere((t) => t.id == id);
      if (index != -1) {
        tasks[index] = res.data!;
      }
      Get.snackbar('Success', 'Task status updated');
    }
  }

  Future<bool> createTask(Map<String, dynamic> payload) async {
    final res = await _taskService.createTask(payload);
    if (res.success && res.data != null) {
      tasks.insert(0, res.data!);
      Get.back();
      Get.snackbar('Success', 'Task created');
      return true;
    }
    return false;
  }
}
