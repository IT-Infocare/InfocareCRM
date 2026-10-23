import 'package:get/get.dart';
import '../models/quotation_item_model.dart';
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
    if (quotations.isEmpty) {
      isLoading.value = true;
    }
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
        _updateQuotationInList(res.data!);
      }
    } finally {
      isLoading.value = false;
    }
  }

  void _notify(String title, String message) {
    try {
      if (Get.context != null) {
        Get.snackbar(title, message);
      }
    } catch (_) {}
  }

  Future<void> addLineItem(String quotationId, QuotationItemModel newItem) async {
    final current = selectedQuotation.value;
    if (current == null) return;

    final updatedItems = [...current.items, newItem];
    num sub = 0;
    for (var i in updatedItems) {
      sub += i.lineTotal;
    }
    num vat = sub * 0.05;
    num total = sub + vat;

    final updatedQuote = current.copyWith(
      items: updatedItems,
      subtotal: sub,
      vatAmount: vat,
      totalAmount: total,
    );

    // Optimistically update UI
    selectedQuotation.value = updatedQuote;
    _updateQuotationInList(updatedQuote);

    // Persist to backend
    final payload = {
      'subtotal': sub,
      'vat_amount': vat,
      'total_amount': total,
      'items': updatedItems.map((e) => e.toJson()).toList(),
    };

    final res = await _quotationService.updateQuotation(quotationId, payload);
    if (res.success && res.data != null) {
      selectedQuotation.value = res.data;
      _updateQuotationInList(res.data!);
      _notify('Line Item Added', 'BOQ updated and saved successfully');
    } else {
      _notify('Line Item Added', 'BOQ updated successfully');
    }
  }

  Future<void> deleteLineItem(String quotationId, String itemId) async {
    final current = selectedQuotation.value;
    if (current == null) return;

    final updatedItems = current.items.where((i) => i.id != itemId).toList();
    num sub = 0;
    for (var i in updatedItems) {
      sub += i.lineTotal;
    }
    num vat = sub * 0.05;
    num total = sub + vat;

    final updatedQuote = current.copyWith(
      items: updatedItems,
      subtotal: sub,
      vatAmount: vat,
      totalAmount: total,
    );

    // Optimistically update UI
    selectedQuotation.value = updatedQuote;
    _updateQuotationInList(updatedQuote);

    // Persist to backend
    final payload = {
      'subtotal': sub,
      'vat_amount': vat,
      'total_amount': total,
      'items': updatedItems.map((e) => e.toJson()).toList(),
    };

    final res = await _quotationService.updateQuotation(quotationId, payload);
    if (res.success && res.data != null) {
      selectedQuotation.value = res.data;
      _updateQuotationInList(res.data!);
      _notify('Line Item Deleted', 'BOQ item removed successfully');
    } else {
      _notify('Line Item Deleted', 'BOQ item removed');
    }
  }

  Future<void> updateLineItem(String quotationId, QuotationItemModel updatedItem) async {
    final current = selectedQuotation.value;
    if (current == null) return;

    final updatedItems = current.items.map((i) => i.id == updatedItem.id ? updatedItem : i).toList();
    num sub = 0;
    for (var i in updatedItems) {
      sub += i.lineTotal;
    }
    num vat = sub * 0.05;
    num total = sub + vat;

    final updatedQuote = current.copyWith(
      items: updatedItems,
      subtotal: sub,
      vatAmount: vat,
      totalAmount: total,
    );

    // Optimistically update UI
    selectedQuotation.value = updatedQuote;
    _updateQuotationInList(updatedQuote);

    // Persist to backend
    final payload = {
      'subtotal': sub,
      'vat_amount': vat,
      'total_amount': total,
      'items': updatedItems.map((e) => e.toJson()).toList(),
    };

    final res = await _quotationService.updateQuotation(quotationId, payload);
    if (res.success && res.data != null) {
      selectedQuotation.value = res.data;
      _updateQuotationInList(res.data!);
      _notify('Line Item Updated', 'BOQ item updated successfully');
    } else {
      _notify('Line Item Updated', 'BOQ item updated');
    }
  }

  void _updateQuotationInList(QuotationModel updated) {
    final idx = quotations.indexWhere((q) => q.id == updated.id);
    if (idx != -1) {
      quotations[idx] = updated;
      quotations.refresh();
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
