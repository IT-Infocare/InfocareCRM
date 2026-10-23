import 'package:get/get.dart';
import '../models/customer_model.dart';
import '../services/api_service.dart';
import '../services/customer_service.dart';
import 'auth_controller.dart';

class CustomerController extends GetxController {
  final CustomerService _customerService = CustomerService(Get.find<ApiService>());

  // Default seed customers to guarantee immediate availability in drop-downs and offline/slow-network scenarios
  static final List<CustomerModel> defaultCustomers = [
    CustomerModel(
      id: 'cust_001',
      name: 'Ahmed Al Mansoori',
      companyName: 'Al Maya Trading LLC',
      email: 'ahmed@almaya.ae',
      phone: '+971 50 111 2222',
      whatsappNumber: '+971 50 111 2222',
      branch: 'Dubai',
      emirate: 'Dubai',
      address: 'Business Bay, Tower B, Office 1204',
      totalRevenue: 145000,
      totalDeals: 3,
    ),
    CustomerModel(
      id: 'cust_002',
      name: 'John Smith',
      companyName: 'Apex Logistics',
      email: 'jsmith@apexlogistics.com',
      phone: '+971 55 333 4444',
      whatsappNumber: '+971 55 333 4444',
      branch: 'RAK',
      emirate: 'Ras Al Khaimah',
      address: 'Al Hamra Industrial Zone, Plot 44',
      totalRevenue: 280000,
      totalDeals: 5,
    ),
    CustomerModel(
      id: 'cust_003',
      name: 'Fatima Al Hammadi',
      companyName: 'Emirates Health Clinic',
      email: 'fatima@ehclinic.ae',
      phone: '+971 52 999 8888',
      whatsappNumber: '+971 52 999 8888',
      branch: 'Dubai',
      emirate: 'Dubai',
      address: 'Jumeirah 1, Villa 88',
      totalRevenue: 95000,
      totalDeals: 2,
    ),
    CustomerModel(
      id: 'cust_004',
      name: 'Rashid Al Maktoum',
      companyName: 'Maktoum Enterprises',
      email: 'rashid@maktoum.ae',
      phone: '+971 50 123 4567',
      whatsappNumber: '+971 50 123 4567',
      branch: 'Dubai',
      emirate: 'Dubai',
    ),
    CustomerModel(
      id: 'cust_005',
      name: 'Tareq Al Nuaimi',
      companyName: 'Nuaimi Group',
      email: 'tareq@nuaimi.ae',
      phone: '+971 50 887 7665',
      whatsappNumber: '+971 50 887 7665',
      branch: 'Dubai',
      emirate: 'Dubai',
    ),
    CustomerModel(
      id: 'cust_006',
      name: 'Ali Shaban',
      companyName: 'W.J. Towell',
      email: 'alishaban@ggmail.com',
      phone: '+971 50 455 4664',
      whatsappNumber: '+971 50 455 4664',
      branch: 'Dubai',
      emirate: 'Dubai',
    ),
    CustomerModel(
      id: 'cust_007',
      name: 'Mohammed',
      companyName: 'Al Nasr Trading',
      email: 'alnasr@gmail.com',
      phone: '+971 50 837 7383',
      whatsappNumber: '+971 50 837 7383',
      branch: 'INFOCARE DXB',
      emirate: 'Dubai',
    ),
    CustomerModel(
      id: 'cust_008',
      name: 'Mr. Rex',
      companyName: 'Al Futtaim',
      email: 'rex@alfuttaim.ae',
      phone: '+971 50 444 7787',
      whatsappNumber: '+971 50 444 7787',
      branch: 'Dubai',
      emirate: 'Dubai',
    ),
  ];

  final RxBool isLoading = true.obs;
  final RxList<CustomerModel> allCustomers = RxList<CustomerModel>(defaultCustomers);
  final RxList<CustomerModel> customers = RxList<CustomerModel>(defaultCustomers);
  final Rxn<CustomerModel> selectedCustomer = Rxn<CustomerModel>();
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllCustomers();
    fetchCustomers();
    if (Get.isRegistered<AuthController>()) {
      ever(AuthController.to.selectedBranch, (_) => fetchCustomers());
    }
  }

  static bool isBranchMatch(String? customerBranch, String selectedBranch) {
    if (selectedBranch == 'All') return true;
    if (customerBranch == null || customerBranch.trim().isEmpty) return true;
    final cb = customerBranch.trim().toLowerCase();
    final sb = selectedBranch.trim().toLowerCase();
    if (cb == sb) return true;

    // Handle DXB / Dubai aliases
    final isDubaiSelected = sb.contains('dxb') || sb.contains('dubai');
    final isDubaiCustomer = cb.contains('dxb') || cb.contains('dubai');
    if (isDubaiSelected && isDubaiCustomer) return true;

    // Handle RAK aliases
    final isRakSelected = sb.contains('rak') || sb.contains('khaimah');
    final isRakCustomer = cb.contains('rak') || cb.contains('khaimah');
    if (isRakSelected && isRakCustomer) return true;

    // Handle Sharjah / FZC aliases
    final isShjSelected = sb.contains('shj') || sb.contains('fzc') || sb.contains('sharjah');
    final isShjCustomer = cb.contains('shj') || cb.contains('fzc') || cb.contains('sharjah');
    if (isShjSelected && isShjCustomer) return true;

    return false;
  }

  Future<void> fetchAllCustomers() async {
    try {
      final res = await _customerService.getCustomers();
      if (res.success && res.data != null && res.data!.isNotEmpty) {
        final serverList = res.data!;
        final merged = <CustomerModel>[...serverList];
        for (final def in defaultCustomers) {
          if (!merged.any((c) => c.id == def.id || (c.name.toLowerCase() == def.name.toLowerCase() && c.companyName == def.companyName))) {
            merged.add(def);
          }
        }
        allCustomers.assignAll(merged);
        _applyLocalFilter();
      }
    } catch (_) {
      // Keep current list
    }
  }

  void _applyLocalFilter() {
    final query = searchQuery.value.trim().toLowerCase();
    final selectedBranch = Get.isRegistered<AuthController>() ? AuthController.to.selectedBranch.value : 'All';

    final filtered = allCustomers.where((c) {
      final matchesQuery = query.isEmpty ||
          c.name.toLowerCase().contains(query) ||
          (c.companyName?.toLowerCase().contains(query) ?? false) ||
          c.phone.contains(query) ||
          c.email.toLowerCase().contains(query);

      final matchesBranch = isBranchMatch(c.branch, selectedBranch);
      return matchesQuery && matchesBranch;
    }).toList();

    customers.assignAll(filtered);
  }

  Future<void> fetchCustomers() async {
    if (allCustomers.isEmpty) {
      isLoading.value = true;
    }
    try {
      await fetchAllCustomers();
      _applyLocalFilter();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> selectCustomer(String id) async {
    final existing = allCustomers.firstWhereOrNull((c) => c.id == id) ?? customers.firstWhereOrNull((c) => c.id == id);
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
      allCustomers.insert(0, res.data!);
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
