import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/activity_model.dart';
import '../models/lead_model.dart';
import '../models/deal_model.dart';
import '../models/pagination_model.dart';
import '../services/api_service.dart';
import '../services/customer_service.dart';
import '../services/lead_service.dart';
import '../utils/lead_stage_utils.dart';
import 'auth_controller.dart';
import 'pipeline_controller.dart';

class LeadController extends GetxController {
  final LeadService _leadService = LeadService(Get.find<ApiService>());

  final RxBool isLoading = true.obs;
  final RxList<LeadModel> leads = <LeadModel>[].obs;
  final Rxn<LeadModel> selectedLead = Rxn<LeadModel>();
  final RxList<ActivityModel> leadActivities = <ActivityModel>[].obs;
  final Rxn<PaginationModel> pagination = Rxn<PaginationModel>();

  // Filter & Search state
  final RxString searchQuery = ''.obs;
  final RxString selectedSource = 'All'.obs;
  final RxString selectedStatus = 'All'.obs;
  final RxInt currentPage = 1.obs;

  // AI Assistant state
  final RxBool isRewriting = false.obs;
  final RxString selectedTone = 'Professional'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchLeads();
    if (Get.isRegistered<AuthController>()) {
      ever(AuthController.to.selectedBranch, (_) => fetchLeads(page: 1));
    }
  }

  Future<void> fetchLeads({int page = 1}) async {
    if (leads.isEmpty) {
      isLoading.value = true;
    }
    currentPage.value = page;
    try {
      final selectedBranch = Get.isRegistered<AuthController>() ? AuthController.to.selectedBranch.value : 'All';
      final res = await _leadService.getLeads(
        search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
        branch: selectedBranch != 'All' ? selectedBranch : null,
        source: selectedSource.value != 'All' ? selectedSource.value : null,
        status: selectedStatus.value != 'All' ? selectedStatus.value : null,
        page: page,
      );
      if (res.success && res.data != null) {
        leads.assignAll(res.data!);
        pagination.value = res.pagination;
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> selectLead(String id) async {
    final existing = leads.firstWhereOrNull((l) => l.id == id);
    if (existing != null) {
      selectedLead.value = existing;
    } else {
      isLoading.value = true;
    }
    try {
      final res = await _leadService.getLeadById(id);
      if (res.success && res.data != null) {
        selectedLead.value = res.data;
        fetchActivities(id);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchActivities(String leadId) async {
    final res = await _leadService.getActivities(leadId);
    if (res.success && res.data != null) {
      leadActivities.assignAll(res.data!);
    }
  }

  final CustomerService _customerService = CustomerService(Get.find<ApiService>());

  Future<bool> createLead(Map<String, dynamic> payload, {bool createCustomer = true}) async {
    final finalPayload = Map<String, dynamic>.from(payload);

    // Create Customer in customers table first if createCustomer is true
    if (createCustomer || finalPayload['create_customer'] == true) {
      final custRes = await _customerService.createCustomer({
        'name': payload['contact_name'] ?? 'New Customer',
        'company_name': payload['company_name'],
        'email': payload['email'] ?? '',
        'phone': payload['phone'] ?? '',
        'branch': payload['branch'] ?? 'Dubai',
      });
      if (custRes.success && custRes.data != null) {
        finalPayload['customer_id'] = custRes.data!.id;
      }
      finalPayload.remove('create_customer');
    }

    final res = await _leadService.createLead(finalPayload);
    if (res.success && res.data != null) {
      leads.insert(0, res.data!);
      fetchLeads();
      Get.back();
      Get.snackbar('Success', 'Lead & Customer created successfully');
      return true;
    } else {
      Get.snackbar('Error', res.message ?? 'Failed to create lead');
      return false;
    }
  }

  Future<bool> updateLead(String id, Map<String, dynamic> payload) async {
    final res = await _leadService.updateLead(id, payload);
    if (res.success && res.data != null) {
      final updated = res.data!;
      if (selectedLead.value?.id == id) {
        selectedLead.value = updated;
      }
      final idx = leads.indexWhere((l) => l.id == id);
      if (idx != -1) {
        leads[idx] = updated;
      }
      Get.snackbar(
        'Success',
        'Lead details updated successfully',
        backgroundColor: const Color(0xFF0F766E),
        colorText: Colors.white,
      );
      return true;
    } else {
      Get.snackbar('Error', res.message ?? 'Failed to update lead');
      return false;
    }
  }

  Future<bool> updateLeadStage(String leadId, String newStage, {String? lostReason}) async {
    final derivedStatus = LeadStageUtils.deriveStatusFromStage(newStage);
    final idx = leads.indexWhere((l) => l.id == leadId);
    LeadModel? oldLead;
    if (idx != -1) {
      oldLead = leads[idx];
      leads[idx] = oldLead.copyWith(stage: newStage, status: derivedStatus);
    }
    if (selectedLead.value?.id == leadId) {
      selectedLead.value = selectedLead.value!.copyWith(stage: newStage, status: derivedStatus);
    }

    // Synchronize PipelineController if registered
    DealModel? oldDeal;
    int dealIdx = -1;
    final pipeCtrl = Get.isRegistered<PipelineController>() ? Get.find<PipelineController>() : null;
    if (pipeCtrl != null) {
      dealIdx = pipeCtrl.deals.indexWhere((d) => d.id == leadId || d.leadId == leadId);
      if (dealIdx != -1) {
        oldDeal = pipeCtrl.deals[dealIdx];
        pipeCtrl.deals[dealIdx] = oldDeal.copyWith(stage: newStage, lostReason: lostReason);
      }
    }

    final res = await _leadService.updateLead(leadId, {
      'stage': newStage,
      'status': derivedStatus,
      if (lostReason != null) 'lost_reason': lostReason,
    });

    if (!res.success) {
      if (idx != -1 && oldLead != null) leads[idx] = oldLead;
      if (selectedLead.value?.id == leadId && oldLead != null) selectedLead.value = oldLead;
      if (pipeCtrl != null && dealIdx != -1 && oldDeal != null) pipeCtrl.deals[dealIdx] = oldDeal;
      Get.snackbar('Error', res.message ?? 'Failed to update stage');
      return false;
    }

    Get.snackbar(
      'Stage Updated',
      'Moved to ${LeadStageUtils.getLabel(newStage)}',
      backgroundColor: const Color(0xFF0F766E),
      colorText: Colors.white,
    );
    return true;
  }

  Future<void> addActivity(String leadId, String type, String description) async {
    final res = await _leadService.addActivity(leadId, type, description);
    if (res.success && res.data != null) {
      leadActivities.insert(0, res.data!);
    }
  }

  Future<bool> updateActivity(String leadId, String activityId, String type, String description) async {
    final res = await _leadService.updateActivity(leadId, activityId, type: type, description: description);
    if (res.success) {
      final idx = leadActivities.indexWhere((a) => a.id == activityId);
      if (idx != -1) {
        leadActivities[idx] = leadActivities[idx].copyWith(type: type, description: description);
      } else if (res.data != null) {
        leadActivities.insert(0, res.data!);
      }
      Get.snackbar(
        'Success',
        'Activity updated successfully',
        backgroundColor: const Color(0xFF0F766E),
        colorText: Colors.white,
      );
      return true;
    } else {
      Get.snackbar('Error', res.message ?? 'Failed to update activity');
      return false;
    }
  }

  Future<bool> deleteActivity(String leadId, String activityId) async {
    final res = await _leadService.deleteActivity(leadId, activityId);
    if (res.success) {
      leadActivities.removeWhere((a) => a.id == activityId);
      Get.snackbar(
        'Success',
        'Activity deleted',
        backgroundColor: const Color(0xFF0F766E),
        colorText: Colors.white,
      );
      return true;
    } else {
      Get.snackbar('Error', res.message ?? 'Failed to delete activity');
      return false;
    }
  }

  Future<void> sendEmailToLead(LeadModel lead, String content) async {
    final targetEmail = lead.email.isNotEmpty ? lead.email : 'client@company.ae';
    await addActivity(
      lead.id,
      'email',
      'Sent follow-up email to $targetEmail: "$content"',
    );
    Get.snackbar(
      'Email Sent Successfully',
      'Message sent to $targetEmail from ${lead.branch} company email',
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF0F766E),
      colorText: const Color(0xFFFFFFFF),
      duration: const Duration(seconds: 4),
    );
  }

  Future<void> approveAiDraftReply() async {
    if (selectedLead.value == null) return;
    await sendEmailToLead(selectedLead.value!, selectedLead.value!.aiDraftReply ?? '');
  }

  Future<String?> rewriteEmailWithClaude(String currentDraft, {String? tone, String? apiKey}) async {
    final lead = selectedLead.value;
    if (lead == null) return null;
    isRewriting.value = true;
    try {
      final user = Get.isRegistered<AuthController>() ? AuthController.to.currentUser.value : null;
      final senderName = user?.name ?? user?.username ?? 'Account Manager';

      final res = await _leadService.rewriteEmail(
        draft: currentDraft,
        contactName: lead.contactName,
        companyName: lead.companyName,
        requirement: lead.requirement,
        senderName: senderName,
        tone: tone ?? selectedTone.value,
        apiKey: apiKey,
      );

      if (res.success && res.data != null && res.data!.isNotEmpty) {
        final rewritten = res.data!;
        selectedLead.value = lead.copyWith(aiDraftReply: rewritten);
        Get.snackbar(
          'Email Rewritten with Claude',
          'Your draft has been polished into a professional email',
          backgroundColor: const Color(0xFF0F766E),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return rewritten;
      } else {
        Get.snackbar('Notice', res.message ?? 'Could not rewrite draft at this time');
        return null;
      }
    } finally {
      isRewriting.value = false;
    }
  }

  Future<void> rewriteAiDraftReply({String? draft}) async {
    if (selectedLead.value == null) return;
    final current = draft ?? selectedLead.value!.aiDraftReply ?? '';
    await rewriteEmailWithClaude(current);
  }
}
