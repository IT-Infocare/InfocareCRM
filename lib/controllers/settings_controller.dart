import 'package:get/get.dart';
import 'auth_controller.dart';
import '../models/api_response.dart';
import '../models/branch_model.dart';
import '../models/company_model.dart';
import '../models/product_bundle_model.dart';
import '../models/product_model.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/settings_service.dart';

class SettingsController extends GetxController {
  final SettingsService _settingsService = SettingsService(Get.find<ApiService>());

  // Default seed products to guarantee immediate availability in drop-downs and offline/slow-network scenarios
  static final List<ProductModel> defaultProducts = [
    ProductModel(
      id: 'prod_001',
      name: 'Hikvision 4MP IP Dome Camera',
      sku: 'HIK-CAM-4MP',
      category: 'CCTV',
      unitPrice: 350,
      costPrice: 220,
      description: '4MP Outdoor/Indoor IR Network Dome Camera with PoE',
    ),
    ProductModel(
      id: 'prod_002',
      name: 'Yeastar S50 IP PBX Phone System',
      sku: 'YST-S50',
      category: 'Telecom',
      unitPrice: 4500,
      costPrice: 3100,
      description: 'Up to 50 users, 25 concurrent calls, unified communications',
    ),
    ProductModel(
      id: 'prod_003',
      name: 'Dahua 8-Channel 4K NVR Recorder',
      sku: 'DH-NVR-4K',
      category: 'CCTV',
      unitPrice: 850,
      costPrice: 550,
      description: '8-Channel 4K PoE Network Video Recorder with 2TB HDD',
    ),
    ProductModel(
      id: 'prod_004',
      name: 'Fanvil X3U Enterprise IP Phone',
      sku: 'FNV-X3U',
      category: 'Telecom',
      unitPrice: 220,
      costPrice: 150,
      description: 'Gigabit color screen IP phone with HD audio and PoE',
    ),
    ProductModel(
      id: 'prod_005',
      name: 'Cisco Catalyst 24-Port PoE+ Gigabit Switch',
      sku: 'CS-C9200-24P',
      category: 'Networking',
      unitPrice: 3200,
      costPrice: 2400,
      description: '24 ports PoE+ (370W), 4x 1G SFP uplinks, managed layer 3',
    ),
    ProductModel(
      id: 'prod_006',
      name: 'Ubiquiti UniFi U6 Pro Access Point',
      sku: 'UBNT-U6-PRO',
      category: 'Networking',
      unitPrice: 650,
      costPrice: 480,
      description: 'Dual-band WiFi 6 ceiling-mounted AP with PoE support',
    ),
    ProductModel(
      id: 'prod_007',
      name: 'ZKTeco Biometric Time Attendance & Access Control',
      sku: 'ZK-BIO-A1',
      category: 'Access Control',
      unitPrice: 950,
      costPrice: 650,
      description: 'Fingerprint, RFID & PIN standalone access controller with TCP/IP',
    ),
    ProductModel(
      id: 'prod_008',
      name: 'Electro-Magnetic Lock 600lbs with Bracket',
      sku: 'EM-LOCK-600',
      category: 'Access Control',
      unitPrice: 280,
      costPrice: 160,
      description: 'Fail-safe 280kg / 600lbs magnetic lock with ZL bracket & LED',
    ),
    ProductModel(
      id: 'prod_009',
      name: 'CommScope Cat6 UTP Cable Box (305m)',
      sku: 'CAB-CAT6-305M',
      category: 'Cabling',
      unitPrice: 420,
      costPrice: 310,
      description: 'Pure copper 4-pair 23AWG Cat6 network cable roll 305m',
    ),
    ProductModel(
      id: 'prod_010',
      name: 'Structured Cabling & Termination (per point)',
      sku: 'SRV-CAB-PNT',
      category: 'Services',
      unitPrice: 120,
      costPrice: 60,
      description: 'Pulling, routing, labeling, faceplate termination & testing per point',
    ),
    ProductModel(
      id: 'prod_011',
      name: 'CCTV Installation & Configuration (per camera)',
      sku: 'SRV-CCTV-INST',
      category: 'Services',
      unitPrice: 150,
      costPrice: 75,
      description: 'Mounting, angling, IP configuration, remote view setup & testing',
    ),
    ProductModel(
      id: 'prod_012',
      name: 'Annual Maintenance Contract (AMC) - 1 Year',
      sku: 'SRV-AMC-1YR',
      category: 'Services',
      unitPrice: 2500,
      costPrice: 1200,
      description: 'Quarterly preventive maintenance visits, on-call emergency support',
    ),
  ];

  final RxBool isLoading = true.obs;
  final RxList<UserModel> users = <UserModel>[].obs;
  final RxList<CompanyModel> companies = <CompanyModel>[].obs;
  final RxList<BranchModel> branches = <BranchModel>[].obs;
  final RxList<ProductModel> products = RxList<ProductModel>(defaultProducts);
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
      final results = await Future.wait([
        _settingsService.getUsers(),
        _settingsService.getCompanies(),
        _settingsService.getBranches(),
        _settingsService.getProducts(),
        _settingsService.getProductBundles(),
      ]);

      final uRes = results[0] as ApiResponse<List<UserModel>>;
      if (uRes.success && uRes.data != null) users.assignAll(uRes.data!);

      final cRes = results[1] as ApiResponse<List<CompanyModel>>;
      if (cRes.success && cRes.data != null) companies.assignAll(cRes.data!);

      final bRes = results[2] as ApiResponse<List<BranchModel>>;
      if (bRes.success && bRes.data != null) {
        branches.assignAll(bRes.data!);
        if (Get.isRegistered<AuthController>()) {
          AuthController.to.branches.assignAll(bRes.data!);
        }
      }

      final pRes = results[3] as ApiResponse<List<ProductModel>>;
      if (pRes.success && pRes.data != null) {
        final serverList = pRes.data!;
        final merged = <ProductModel>[...serverList];
        for (final def in defaultProducts) {
          if (!merged.any((p) => p.id == def.id || (p.sku.isNotEmpty && p.sku == def.sku))) {
            merged.add(def);
          }
        }
        products.assignAll(merged);
      }

      final pbRes = results[4] as ApiResponse<List<ProductBundleModel>>;
      if (pbRes.success && pbRes.data != null) productBundles.assignAll(pbRes.data!);
    } catch (_) {
      // keep current data on network failure
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
