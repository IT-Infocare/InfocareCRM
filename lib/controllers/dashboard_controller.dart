import 'package:get/get.dart';
import '../models/api_response.dart';
import '../models/task_model.dart';
import '../services/api_service.dart';
import '../services/dashboard_service.dart';

import 'auth_controller.dart';

class DashboardController extends GetxController {
  final DashboardService _dashboardService = DashboardService(Get.find<ApiService>());

  final RxBool isLoading = true.obs;
  final Rxn<DashboardSummaryData> summary = Rxn<DashboardSummaryData>();
  final RxMap<String, int> leadsBySource = <String, int>{}.obs;
  final RxList<TaskModel> todayFollowUps = <TaskModel>[].obs;
  final RxString morningBriefing = ''.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
    if (Get.isRegistered<AuthController>()) {
      ever(AuthController.to.selectedBranch, (_) => loadDashboardData());
    }
  }

  Future<void> loadDashboardData({String? branch}) async {
    final activeBranch = branch ?? (Get.isRegistered<AuthController>() ? AuthController.to.selectedBranch.value : null);
    final effectiveBranch = activeBranch != 'All' ? activeBranch : null;

    isLoading.value = true;
    errorMessage.value = '';
    try {
      final results = await Future.wait([
        _dashboardService.getSummary(branch: effectiveBranch),
        _dashboardService.getLeadsBySource(branch: effectiveBranch),
        _dashboardService.getTodayFollowUps(branch: effectiveBranch),
        _dashboardService.getMorningBriefing(branch: effectiveBranch),
      ]);

      final summaryRes = results[0] as ApiResponse<DashboardSummaryData>;
      if (summaryRes.success) summary.value = summaryRes.data;

      final sourceRes = results[1] as ApiResponse<Map<String, int>>;
      if (sourceRes.success && sourceRes.data != null) leadsBySource.assignAll(sourceRes.data!);

      final followUpsRes = results[2] as ApiResponse<List<TaskModel>>;
      if (followUpsRes.success && followUpsRes.data != null) todayFollowUps.assignAll(followUpsRes.data!);

      final briefingRes = results[3] as ApiResponse<String>;
      if (briefingRes.success && briefingRes.data != null) morningBriefing.value = briefingRes.data!;
    } catch (e) {
      errorMessage.value = 'Failed to load dashboard data: $e';
    } finally {
      isLoading.value = false;
    }
  }
}
