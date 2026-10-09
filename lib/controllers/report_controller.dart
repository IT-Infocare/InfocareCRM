import 'package:get/get.dart';
import '../services/api_service.dart';
import '../services/report_service.dart';

import 'auth_controller.dart';

class ReportController extends GetxController {
  final ReportService _reportService = ReportService(Get.find<ApiService>());

  final RxBool isLoading = true.obs;
  final RxMap<String, dynamic> reportData = <String, dynamic>{}.obs;
  final RxString selectedReportType = 'leads_by_source'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchReports();
    if (Get.isRegistered<AuthController>()) {
      ever(AuthController.to.selectedBranch, (_) => fetchReports());
    }
  }

  Future<void> fetchReports({String? branch}) async {
    final activeBranch = branch ?? (Get.isRegistered<AuthController>() ? AuthController.to.selectedBranch.value : null);
    final effectiveBranch = activeBranch != 'All' ? activeBranch : null;

    isLoading.value = true;
    try {
      final res = await _reportService.getReportData(
        reportType: selectedReportType.value,
        branch: effectiveBranch,
      );
      if (res.success && res.data != null) {
        reportData.assignAll(res.data!);
      }
    } finally {
      isLoading.value = false;
    }
  }
}
