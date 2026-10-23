import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/deal_model.dart';
import '../models/lead_model.dart';
import '../services/api_service.dart';
import '../services/pipeline_service.dart';
import '../utils/lead_stage_utils.dart';
import 'auth_controller.dart';
import 'lead_controller.dart';

class PipelineController extends GetxController {
  final PipelineService _pipelineService = PipelineService(Get.find<ApiService>());

  final RxBool isLoading = true.obs;
  final RxList<DealModel> deals = <DealModel>[].obs;

  final List<String> stages = [
    'new',
    'site_survey',
    'quotation_sent',
    'negotiation',
    'won',
    'lost',
  ];

  @override
  void onInit() {
    super.onInit();
    fetchPipelineDeals();
    if (Get.isRegistered<AuthController>()) {
      ever(AuthController.to.selectedBranch, (_) => fetchPipelineDeals());
    }
  }

  Future<void> fetchPipelineDeals({String? branch}) async {
    final activeBranch = branch ?? (Get.isRegistered<AuthController>() ? AuthController.to.selectedBranch.value : null);
    final effectiveBranch = activeBranch != 'All' ? activeBranch : null;

    if (deals.isEmpty) {
      isLoading.value = true;
    }
    try {
      final res = await _pipelineService.getPipelineDeals(branch: effectiveBranch);
      if (res.success && res.data != null) {
        deals.assignAll(res.data!);
      }
    } finally {
      isLoading.value = false;
    }
  }

  List<DealModel> getDealsForStage(String stage) {
    return deals.where((d) => d.stage.toLowerCase() == stage.toLowerCase()).toList();
  }

  num getStageTotalValue(String stage) {
    return getDealsForStage(stage).fold(0, (sum, item) => sum + item.estimatedValue);
  }

  Future<bool> moveDealStage(String dealId, String newStage, {String? lostReason}) async {
    final index = deals.indexWhere((d) => d.id == dealId);
    if (index == -1) return false;

    final oldDeal = deals[index];
    // Optimistic update for deals
    deals[index] = oldDeal.copyWith(stage: newStage, lostReason: lostReason);

    // Optimistically synchronize LeadController if registered
    final leadCtrl = Get.isRegistered<LeadController>() ? Get.find<LeadController>() : null;
    LeadModel? oldLead;
    int leadIdx = -1;
    final targetLeadId = oldDeal.leadId ?? dealId;
    if (leadCtrl != null) {
      leadIdx = leadCtrl.leads.indexWhere((l) => l.id == dealId || l.id == targetLeadId);
      if (leadIdx != -1) {
        oldLead = leadCtrl.leads[leadIdx];
        leadCtrl.leads[leadIdx] = oldLead.copyWith(
          stage: newStage,
          status: LeadStageUtils.deriveStatusFromStage(newStage),
        );
      }
      if (leadCtrl.selectedLead.value != null &&
          (leadCtrl.selectedLead.value!.id == dealId || leadCtrl.selectedLead.value!.id == targetLeadId)) {
        leadCtrl.selectedLead.value = leadCtrl.selectedLead.value!.copyWith(
          stage: newStage,
          status: LeadStageUtils.deriveStatusFromStage(newStage),
        );
      }
    }

    final res = await _pipelineService.updateDealStage(
      dealId,
      newStage,
      lostReason: lostReason,
    );
    if (!res.success) {
      // Rollback on failure
      deals[index] = oldDeal;
      if (leadCtrl != null && leadIdx != -1 && oldLead != null) {
        leadCtrl.leads[leadIdx] = oldLead;
      }
      if (leadCtrl?.selectedLead.value != null && oldLead != null &&
          (leadCtrl!.selectedLead.value!.id == dealId || leadCtrl.selectedLead.value!.id == targetLeadId)) {
        leadCtrl.selectedLead.value = oldLead;
      }
      Get.snackbar('Error', res.message ?? 'Failed to update deal stage');
      return false;
    }

    Get.snackbar(
      'Stage Updated',
      'Deal moved to ${LeadStageUtils.getLabel(newStage)}',
      backgroundColor: const Color(0xFF0F766E),
      colorText: Colors.white,
    );
    return true;
  }
}
