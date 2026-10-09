import 'package:get/get.dart';
import '../models/branch_model.dart';
import '../models/product_bundle_model.dart';
import '../models/product_model.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/settings_service.dart';

class SettingsController extends GetxController {
  final SettingsService _settingsService = SettingsService(Get.find<ApiService>());

  final RxBool isLoading = true.obs;
  final RxList<UserModel> users = <UserModel>[].obs;
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

      final bRes = await _settingsService.getBranches();
      if (bRes.success && bRes.data != null) branches.assignAll(bRes.data!);

      final pRes = await _settingsService.getProducts();
      if (pRes.success && pRes.data != null) products.assignAll(pRes.data!);

      final pbRes = await _settingsService.getProductBundles();
      if (pbRes.success && pbRes.data != null) productBundles.assignAll(pbRes.data!);
    } finally {
      isLoading.value = false;
    }
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
    return false;
  }

  Future<bool> createBranch(Map<String, dynamic> payload) async {
    final res = await _settingsService.createBranch(payload);
    if (res.success && res.data != null) {
      branches.insert(0, res.data!);
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
      Get.snackbar('Success', 'Branch deleted successfully');
      return true;
    }
    Get.snackbar('Error', res.message ?? 'Failed to delete branch');
    return false;
  }
}
