import 'package:get/get.dart';
import '../models/quotation_model.dart';
import '../services/api_service.dart';
import '../services/quotation_service.dart';

import 'auth_controller.dart';

class QuotationController extends GetxController {
  final QuotationService _quotationService = QuotationService(Get.find<ApiService>());

  final RxBool isLoading = true.obs;
  final RxList<QuotationModel> quotations = <QuotationModel>[].obs;
  final Rxn<QuotationModel> selectedQuotation = Rxn<QuotationModel>();
  final RxString selectedFilterStatus = 'All'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchQuotations();
    if (Get.isRegistered<AuthController>()) {
      ever(AuthController.to.selectedBranch, (_) => fetchQuotations());
    }
  }

  Future<void> fetchQuotations() async {
    isLoading.value = true;
    try {
      final selectedBranch = Get.isRegistered<AuthController>() ? AuthController.to.selectedBranch.value : 'All';
      final res = await _quotationService.getQuotations(
        status: selectedFilterStatus.value != 'All' ? selectedFilterStatus.value : null,
        branch: selectedBranch != 'All' ? selectedBranch : null,
      );
      if (res.success && res.data != null) {
        quotations.assignAll(res.data!);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> selectQuotation(String id) async {
    final existing = quotations.firstWhereOrNull((q) => q.id == id);
    if (existing != null) {
      selectedQuotation.value = existing;
    } else {
      isLoading.value = true;
    }
    try {
      final res = await _quotationService.getQuotationById(id);
      if (res.success && res.data != null) {
        selectedQuotation.value = res.data;
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> submitApproval(String id) async {
    final res = await _quotationService.submitApproval(id);
    if (res.success && res.data != null) {
      selectedQuotation.value = res.data;
      fetchQuotations();
      Get.snackbar('Success', 'Quotation submitted for management approval');
    }
  }

  Future<void> approveQuotation(String id) async {
    final res = await _quotationService.approveQuotation(id);
    if (res.success && res.data != null) {
      selectedQuotation.value = res.data;
      fetchQuotations();
      Get.snackbar('Success', 'Quotation approved successfully');
    }
  }

  Future<void> regenerateAiDraft(String id) async {
    final res = await _quotationService.regenerateAiDraft(id);
    if (res.success && res.data != null) {
      selectedQuotation.value = res.data;
      Get.snackbar('AI regenerated', 'New AI quotation draft line suggestions loaded');
    }
  }

  Future<bool> createQuotation(Map<String, dynamic> payload) async {
    final res = await _quotationService.createQuotation(payload);
    if (res.success && res.data != null) {
      quotations.insert(0, res.data!);
      Get.back();
      Get.snackbar('Success', 'Quotation created successfully');
      return true;
    } else {
      Get.snackbar('Error', res.message ?? 'Failed to create quotation');
      return false;
    }
  }
}
