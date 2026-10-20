import 'package:get/get.dart';
import 'auth_controller.dart';
import '../models/branch_model.dart';
import '../models/company_model.dart';
import '../models/product_bundle_model.dart';
import '../models/product_model.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/settings_service.dart';

class SettingsController extends GetxController {
  final SettingsService _settingsService = SettingsService(Get.find<ApiService>());

  final RxBool isLoading = true.obs;
  final RxList<UserModel> users = <UserModel>[].obs;
  final RxList<CompanyModel> companies = <CompanyModel>[].obs;
  final RxList<BranchModel> branches = <BranchModel>[].obs;
  final RxList<ProductModel> products = <ProductModel>[].obs;
  final RxList<ProductBundleModel> productBundles = <ProductBundleModel>[].obs;
  final RxInt selectedTabIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadSettingsData();
  }

  Future<void> loadSettingsData() async {
    isLoading.value = true;
    try {
      final uRes = await _settingsService.getUsers();
      if (uRes.success && uRes.data != null) users.assignAll(uRes.data!);

      final cRes = await _settingsService.getCompanies();
      if (cRes.success && cRes.data != null) companies.assignAll(cRes.data!);

      final bRes = await _settingsService.getBranches();
      if (bRes.success && bRes.data != null) {
        branches.assignAll(bRes.data!);
        if (Get.isRegistered<AuthController>()) {
          AuthController.to.branches.assignAll(bRes.data!);
        }
      }

      final pRes = await _settingsService.getProducts();
      if (pRes.success && pRes.data != null) products.assignAll(pRes.data!);

      final pbRes = await _settingsService.getProductBundles();
      if (pbRes.success && pbRes.data != null) productBundles.assignAll(pbRes.data!);
    } finally {
      isLoading.value = false;
    }
  }

  String getCompanyName(String companyId) {
    if (companyId.isEmpty) {
      return companies.isNotEmpty ? companies.first.name : 'InfoCare Systems';
    }
    final found = companies.where((c) => c.id == companyId).firstOrNull;
    return found?.name ?? (companies.isNotEmpty ? companies.first.name : 'InfoCare Systems');
  }

  Future<bool> createCompany(Map<String, dynamic> payload) async {
    final res = await _settingsService.createCompany(payload);
    if (res.success && res.data != null) {
      companies.insert(0, res.data!);
      Get.back();
      Get.snackbar('Success', 'Parent Company "${res.data!.name}" created successfully');
      return true;
    }
    Get.snackbar('Error', res.message ?? 'Failed to create company');
    return false;
  }

  Future<bool> updateCompany(String id, Map<String, dynamic> payload) async {
    final res = await _settingsService.updateCompany(id, payload);
    if (res.success && res.data != null) {
      final index = companies.indexWhere((c) => c.id == id);
      if (index != -1) {
        companies[index] = res.data!;
      }
      Get.back();
      Get.snackbar('Success', 'Company updated successfully');
      return true;
    }
    Get.snackbar('Error', res.message ?? 'Failed to update company');
    return false;
  }

  Future<bool> deleteCompany(String id) async {
    final res = await _settingsService.deleteCompany(id);
    if (res.success) {
      companies.removeWhere((c) => c.id == id);
      Get.snackbar('Success', 'Company removed');
      return true;
    }
    Get.snackbar('Error', res.message ?? 'Failed to delete company');
    return false;
  }

  Future<bool> createProduct(Map<String, dynamic> payload) async {
    final res = await _settingsService.createProduct(payload);
    if (res.success && res.data != null) {
      products.insert(0, res.data!);
      Get.back();
      Get.snackbar('Success', 'Product catalog updated');
      return true;
    }
    return false;
  }

  Future<bool> createUser(Map<String, dynamic> payload) async {
    final res = await _settingsService.createUser(payload);
    if (res.success && res.data != null) {
      users.insert(0, res.data!);
      Get.back();
      Get.snackbar('Success', 'New user account created');
      return true;
    }
    Get.snackbar('Error', res.message ?? 'Failed to create user');
    return false;
  }

  Future<bool> updateUser(String id, Map<String, dynamic> payload) async {
    final res = await _settingsService.updateUser(id, payload);
    if (res.success && res.data != null) {
      final index = users.indexWhere((u) => u.id == id);
      if (index != -1) {
        users[index] = res.data!;
      }
      Get.back();
      Get.snackbar('Success', 'User updated successfully');
      return true;
    }
    Get.snackbar('Error', res.message ?? 'Failed to update user');
    return false;
  }

  Future<bool> deleteUser(String id) async {
    final res = await _settingsService.deleteUser(id);
    if (res.success) {
      users.removeWhere((u) => u.id == id);
      Get.snackbar('Success', 'User deleted successfully');
      return true;
    }
    Get.snackbar('Error', res.message ?? 'Failed to delete user');
    return false;
  }

  Future<bool> createBranch(Map<String, dynamic> payload) async {
    final res = await _settingsService.createBranch(payload);
    if (res.success && res.data != null) {
      branches.insert(0, res.data!);
      if (Get.isRegistered<AuthController>()) {
        AuthController.to.branches.insert(0, res.data!);
      }
      Get.back();
      Get.snackbar('Success', 'New branch created successfully');
      return true;
    }
    Get.snackbar('Error', res.message ?? 'Failed to create branch');
    return false;
  }

  Future<bool> updateBranch(String id, Map<String, dynamic> payload) async {
    final res = await _settingsService.updateBranch(id, payload);
    if (res.success && res.data != null) {
      final index = branches.indexWhere((b) => b.id == id);
      if (index != -1) {
        branches[index] = res.data!;
      }
      if (Get.isRegistered<AuthController>()) {
        final aIdx = AuthController.to.branches.indexWhere((b) => b.id == id);
        if (aIdx != -1) {
          AuthController.to.branches[aIdx] = res.data!;
        }
      }
      Get.back();
      Get.snackbar('Success', 'Branch updated successfully');
      return true;
    }
    Get.snackbar('Error', res.message ?? 'Failed to update branch');
    return false;
  }

  Future<bool> deleteBranch(String id) async {
    final res = await _settingsService.deleteBranch(id);
    if (res.success) {
      branches.removeWhere((b) => b.id == id);
      if (Get.isRegistered<AuthController>()) {
        AuthController.to.branches.removeWhere((b) => b.id == id);
      }
      Get.snackbar('Success', 'Branch deleted successfully');
      return true;
    }
    Get.snackbar('Error', res.message ?? 'Failed to delete branch');
    return false;
  }
}
