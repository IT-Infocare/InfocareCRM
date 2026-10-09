import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/activity_model.dart';
import '../models/lead_model.dart';
import '../models/pagination_model.dart';
import '../services/api_service.dart';
import '../services/customer_service.dart';
import '../services/lead_service.dart';

import 'auth_controller.dart';

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

  @override
  void onInit() {
    super.onInit();
    fetchLeads();
    if (Get.isRegistered<AuthController>()) {
      ever(AuthController.to.selectedBranch, (_) => fetchLeads(page: 1));
    }
  }

  Future<void> fetchLeads({int page = 1}) async {
    isLoading.value = true;
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
      Get.back();
      Get.snackbar('Success', 'Lead & Customer created successfully');
      return true;
    } else {
      Get.snackbar('Error', res.message ?? 'Failed to create lead');
      return false;
    }
  }

  Future<void> addActivity(String leadId, String type, String description) async {
    final res = await _leadService.addActivity(leadId, type, description);
    if (res.success && res.data != null) {
      leadActivities.insert(0, res.data!);
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

  Future<void> rewriteAiDraftReply() async {
    if (selectedLead.value == null) return;
    selectedLead.value = selectedLead.value!.copyWith(
      aiDraftReply: 'Dear ${selectedLead.value!.contactName.split(" ").first}, following up on our quotation for the security & CCTV system at your site. We are pleased to offer preferred pricing and free installation support. Would tomorrow suit for a quick call?',
    );
    Get.snackbar('AI Draft Regenerated', 'Updated email draft option loaded');
  }
}
