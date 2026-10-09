import 'package:get/get.dart';
import '../models/customer_model.dart';
import '../services/api_service.dart';
import '../services/customer_service.dart';

import 'auth_controller.dart';

class CustomerController extends GetxController {
  final CustomerService _customerService = CustomerService(Get.find<ApiService>());

  final RxBool isLoading = true.obs;
  final RxList<CustomerModel> customers = <CustomerModel>[].obs;
  final Rxn<CustomerModel> selectedCustomer = Rxn<CustomerModel>();
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCustomers();
    if (Get.isRegistered<AuthController>()) {
      ever(AuthController.to.selectedBranch, (_) => fetchCustomers());
    }
  }

  Future<void> fetchCustomers() async {
    isLoading.value = true;
    try {
      final selectedBranch = Get.isRegistered<AuthController>() ? AuthController.to.selectedBranch.value : 'All';
      final res = await _customerService.getCustomers(
        search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
        branch: selectedBranch != 'All' ? selectedBranch : null,
      );
      if (res.success && res.data != null) {
        customers.assignAll(res.data!);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> selectCustomer(String id) async {
    final existing = customers.firstWhereOrNull((c) => c.id == id);
    if (existing != null) {
      selectedCustomer.value = existing;
    } else {
      isLoading.value = true;
    }
    try {
      final res = await _customerService.getCustomerById(id);
      if (res.success && res.data != null) {
        selectedCustomer.value = res.data;
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createCustomer(Map<String, dynamic> payload) async {
    final res = await _customerService.createCustomer(payload);
    if (res.success && res.data != null) {
      customers.insert(0, res.data!);
      Get.back();
      Get.snackbar('Success', 'Customer created successfully');
      return true;
    } else {
      Get.snackbar('Error', res.message ?? 'Failed to create customer');
      return false;
    }
  }
}
