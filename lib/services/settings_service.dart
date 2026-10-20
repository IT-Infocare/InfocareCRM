import '../config/api_endpoints.dart';
import '../config/app_config.dart';
import '../models/api_response.dart';
import '../models/branch_model.dart';
import '../models/company_model.dart';
import '../models/product_bundle_model.dart';
import '../models/product_model.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class SettingsService {
  final ApiService _apiService;

  SettingsService(this._apiService);

  final List<CompanyModel> _mockCompanies = [
    CompanyModel(
      id: 'cmp_01',
      name: 'InfoCare Systems',
      code: 'INFOCARE',
      tradeLicenceNo: 'CN-1029384',
      industry: 'IT, Security & Surveillance Systems',
      country: 'UAE',
      emirate: 'Dubai',
      city: 'Dubai',
      address: 'Business Bay, Tower B, Office 1204, Dubai, UAE',
      website: 'https://infocaresystems.com',
      phone: '+971 4 321 0000',
      email: 'info@infocaresystems.com',
      taxNumber: '100293847500001',
      notes: 'Parent enterprise entity managing InfoCare regional branches across UAE and the Middle East.',
      isActive: true,
      branchCount: 3,
    ),
  ];

  final List<UserModel> _mockUsers = [
    UserModel(id: 'a0000000-0000-4000-a000-000000000001', username: 'Admin', name: 'System Administrator', email: 'admin@infocare.ae', role: 'admin', branch: 'Dubai', phone: '+971 50 100 0000'),
    UserModel(id: 'usr_1001', username: 'sarah.c', name: 'Sarah Connor', email: 'sarah.c@infocare.ae', role: 'admin', branch: 'Dubai', phone: '+971 50 123 4567'),
    UserModel(id: 'usr_1002', username: 'ali.m', name: 'Ali Mansoor', email: 'ali.m@infocare.ae', role: 'branch_sales', branch: 'Iraq', phone: '+964 770 123 4567'),
    UserModel(id: 'usr_1003', username: 'rashid.n', name: 'Rashid Al Nuaimi', email: 'rashid.n@infocare.ae', role: 'branch_sales', branch: 'Sharjah', phone: '+971 52 888 9999'),
    UserModel(id: 'usr_1004', username: 'dir', name: 'Management Director', email: 'dir@infocare.ae', role: 'management', branch: 'Dubai', phone: '+971 50 999 0000'),
  ];

  final List<BranchModel> _mockBranches = [
    BranchModel(
      id: 'br_dxb',
      companyId: 'cmp_01',
      companyName: 'InfoCare Systems',
      name: 'InfoCare System Dubai',
      shortName: 'Dubai',
      code: 'DXB',
      manager: 'Sarah Connor',
      country: 'UAE',
      city: 'Dubai',
      currency: 'AED',
      vatPercent: 5.0,
      website: 'https://infocare.ae',
      poBox: 'P.O. Box 12345, Dubai',
      timezone: 'Asia/Dubai',
      phone: '+971 4 321 0000',
      mobile: '+971 50 111 2222',
      email: 'dubai@infocare.ae',
      location: 'Dubai, UAE',
      trNumber: '100293847500003',
      address: 'Business Bay, Tower B, Office 1204, Dubai, UAE',
      isActive: true,
    ),
    BranchModel(
      id: 'br_irq',
      companyId: 'cmp_01',
      companyName: 'InfoCare Systems',
      name: 'InfoCare System Iraq',
      shortName: 'Iraq',
      code: 'IRQ',
      manager: 'Ali Mansoor',
      country: 'Iraq',
      city: 'Baghdad',
      currency: 'USD',
      vatPercent: 0.0,
      website: 'https://infocare.iq',
      poBox: 'P.O. Box 1001, Baghdad',
      timezone: 'Asia/Baghdad',
      phone: '+964 1 719 0000',
      mobile: '+964 770 123 4567',
      email: 'iraq@infocare.ae',
      location: 'Baghdad, Iraq',
      trNumber: 'IRQ-9928172',
      address: 'Al-Mansour District, Street 14, Building 22, Baghdad, Iraq',
      isActive: true,
    ),
    BranchModel(
      id: 'br_shj',
      companyId: 'cmp_01',
      companyName: 'InfoCare Systems',
      name: 'InfoCare Systems Sharjah',
      shortName: 'Sharjah',
      code: 'SHJ',
      manager: 'Rashid Al Nuaimi',
      country: 'UAE',
      city: 'Sharjah',
      currency: 'AED',
      vatPercent: 5.0,
      website: 'https://infocare.ae',
      poBox: 'P.O. Box 4500, Sharjah',
      timezone: 'Asia/Dubai',
      phone: '+971 6 555 0000',
      mobile: '+971 52 888 9999',
      email: 'sharjah@infocare.ae',
      location: 'Sharjah, UAE',
      trNumber: '100293847500005',
      address: 'Al Majaz 3, Corniche Road, Crystal Tower, Suite 501, Sharjah, UAE',
      isActive: true,
    ),
  ];

  final List<ProductModel> _mockProducts = [
    ProductModel(id: 'prod_cctv_4k', name: 'Hikvision 4K IP Dome Camera 4MP', sku: 'HIK-4K-DOME', category: 'CCTV', unitPrice: 450, costPrice: 280),
    ProductModel(id: 'prod_nvr_64ch', name: 'Hikvision 64-Channel NVR recorder 4K', sku: 'HIK-NVR-64', category: 'CCTV', unitPrice: 8500, costPrice: 5800),
    ProductModel(id: 'prod_wifi_ap', name: 'Aruba Wi-Fi 6 Enterprise Access Point', sku: 'ARUBA-AP6', category: 'Networking', unitPrice: 2800, costPrice: 1950),
    ProductModel(id: 'prod_poe_switch', name: 'Cisco 48-Port Gigabit Managed PoE+ Switch', sku: 'CISCO-48POE', category: 'Networking', unitPrice: 15500, costPrice: 11000),
    ProductModel(id: 'prod_pabx_system', name: 'Yeastar P560 IP PBX System 100 Ext', sku: 'YEASTAR-P560', category: 'Telecom', unitPrice: 6200, costPrice: 4100),
  ];

  Future<ApiResponse<List<UserModel>>> getUsers() async {
    if (AppConfig.enableMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return ApiResponse<List<UserModel>>(success: true, data: _mockUsers);
    }
    return _apiService.get<List<UserModel>>(
      '/users',
      fromJson: (json) => (json as List<dynamic>).map((e) => UserModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  // Companies Management (Parent)
  Future<ApiResponse<List<CompanyModel>>> getCompanies() async {
    if (AppConfig.enableMockData) {
      await Future.delayed(const Duration(milliseconds: 200));
      // update branch counts
      final updated = _mockCompanies.map((c) {
        final count = _mockBranches.where((b) => b.companyId == c.id).length;
        return c.copyWith(branchCount: count > 0 ? count : c.branchCount);
      }).toList();
      return ApiResponse<List<CompanyModel>>(success: true, data: updated);
    }
    return _apiService.get<List<CompanyModel>>(
      ApiEndpoints.companies,
      fromJson: (json) => (json as List<dynamic>).map((e) => CompanyModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Future<ApiResponse<CompanyModel>> createCompany(Map<String, dynamic> payload) async {
    if (AppConfig.enableMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      final c = CompanyModel.fromJson({
        'id': 'cmp_${DateTime.now().millisecondsSinceEpoch}',
        ...payload,
        'branch_count': 0,
      });
      _mockCompanies.insert(0, c);
      return ApiResponse<CompanyModel>(success: true, message: 'Company created successfully', data: c);
    }
    return _apiService.post<CompanyModel>(
      ApiEndpoints.companies,
      data: payload,
      fromJson: (json) => CompanyModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<CompanyModel>> updateCompany(String id, Map<String, dynamic> payload) async {
    if (AppConfig.enableMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      final idx = _mockCompanies.indexWhere((c) => c.id == id);
      if (idx != -1) {
        final old = _mockCompanies[idx];
        final updated = CompanyModel.fromJson({
          ...old.toJson(),
          ...payload,
          'id': id,
        });
        _mockCompanies[idx] = updated;
        return ApiResponse<CompanyModel>(success: true, message: 'Company updated successfully', data: updated);
      }
    }
    return _apiService.put<CompanyModel>(
      ApiEndpoints.companyDetail(id),
      data: payload,
      fromJson: (json) => CompanyModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<void>> deleteCompany(String id) async {
    if (AppConfig.enableMockData) {
      await Future.delayed(const Duration(milliseconds: 200));
      _mockCompanies.removeWhere((c) => c.id == id);
      return ApiResponse<void>(success: true, message: 'Company deleted successfully');
    }
    return _apiService.delete<void>(ApiEndpoints.companyDetail(id));
  }

  // Branches Management (Child of Companies)
  Future<ApiResponse<List<BranchModel>>> getBranches() async {
    if (AppConfig.enableMockData) {
      await Future.delayed(const Duration(milliseconds: 200));
      return ApiResponse<List<BranchModel>>(success: true, data: _mockBranches);
    }
    return _apiService.get<List<BranchModel>>(
      ApiEndpoints.branches,
      fromJson: (json) => (json as List<dynamic>).map((e) => BranchModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Future<ApiResponse<BranchModel>> createBranch(Map<String, dynamic> payload) async {
    if (AppConfig.enableMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      final companyId = payload['company_id'] as String? ?? 'cmp_01';
      final comp = _mockCompanies.where((c) => c.id == companyId).firstOrNull;
      final b = BranchModel.fromJson({
        'id': 'br_${DateTime.now().millisecondsSinceEpoch}',
        ...payload,
        'company_id': companyId,
        'company_name': comp?.name ?? 'InfoCare Systems',
      });
      _mockBranches.insert(0, b);
      return ApiResponse<BranchModel>(success: true, message: 'Branch created', data: b);
    }
    return _apiService.post<BranchModel>(
      ApiEndpoints.branches,
      data: payload,
      fromJson: (json) => BranchModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<BranchModel>> updateBranch(String id, Map<String, dynamic> payload) async {
    if (AppConfig.enableMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      final idx = _mockBranches.indexWhere((b) => b.id == id);
      if (idx != -1) {
        final old = _mockBranches[idx];
        final companyId = payload['company_id'] as String? ?? old.companyId;
        final comp = _mockCompanies.where((c) => c.id == companyId).firstOrNull;
        final updated = BranchModel.fromJson({
          ...old.toJson(),
          ...payload,
          'id': id,
          'company_id': companyId,
          'company_name': comp?.name ?? old.companyName,
        });
        _mockBranches[idx] = updated;
        return ApiResponse<BranchModel>(success: true, message: 'Branch updated', data: updated);
      }
    }
    return _apiService.put<BranchModel>(
      ApiEndpoints.branchDetail(id),
      data: payload,
      fromJson: (json) => BranchModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<void>> deleteBranch(String id) async {
    if (AppConfig.enableMockData) {
      await Future.delayed(const Duration(milliseconds: 200));
      _mockBranches.removeWhere((b) => b.id == id);
      return ApiResponse<void>(success: true, message: 'Branch deleted');
    }
    return _apiService.delete<void>(ApiEndpoints.branchDetail(id));
  }

  Future<ApiResponse<List<ProductModel>>> getProducts() async {
    if (AppConfig.enableMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return ApiResponse<List<ProductModel>>(success: true, data: _mockProducts);
    }
    return _apiService.get<List<ProductModel>>(
      ApiEndpoints.products,
      fromJson: (json) => (json as List<dynamic>).map((e) => ProductModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Future<ApiResponse<List<ProductBundleModel>>> getProductBundles() async {
    if (AppConfig.enableMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return ApiResponse<List<ProductBundleModel>>(
        success: true,
        data: [
          ProductBundleModel(
            id: 'bndl_01',
            name: 'Standard 16-Camera IP CCTV Package',
            description: '16 IP cameras + 16-ch NVR + 2TB Hard Disk + Installation',
            items: [
              ProductBundleItem(product: _mockProducts[0], quantity: 16),
            ],
            bundlePrice: 14500,
          ),
          ProductBundleModel(
            id: 'bndl_02',
            name: 'Small Office Wi-Fi & Telecom Bundle',
            description: '2 Aruba APs + Yeastar PBX + 5 IP Phones',
            items: [
              ProductBundleItem(product: _mockProducts[2], quantity: 2),
            ],
            bundlePrice: 11800,
          ),
        ],
      );
    }

    return _apiService.get<List<ProductBundleModel>>(
      ApiEndpoints.productBundles,
      fromJson: (json) => (json as List<dynamic>).map((e) => ProductBundleModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Future<ApiResponse<ProductModel>> createProduct(Map<String, dynamic> payload) async {
    if (AppConfig.enableMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      final p = ProductModel.fromJson({
        'id': 'prod_${DateTime.now().millisecondsSinceEpoch}',
        'name': payload['name'] ?? '',
        'sku': payload['sku'] ?? '',
        'category': payload['category'] ?? 'General',
        'unit_price': payload['unit_price'] ?? 0.0,
        'cost_price': payload['cost_price'] ?? 0.0,
      });
      _mockProducts.insert(0, p);
      return ApiResponse<ProductModel>(success: true, message: 'Product added', data: p);
    }

    return _apiService.post<ProductModel>(
      ApiEndpoints.products,
      data: payload,
      fromJson: (json) => ProductModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<UserModel>> createUser(Map<String, dynamic> payload) async {
    if (AppConfig.enableMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      final u = UserModel.fromJson({
        'id': 'usr_${DateTime.now().millisecondsSinceEpoch}',
        'name': payload['name'] ?? '',
        'username': payload['username'] ?? '',
        'email': payload['email'] ?? '',
        'role': payload['role'] ?? 'branch_sales',
        'branch': payload['branch'] ?? 'Dubai',
        'phone': payload['phone'] ?? '',
      });
      _mockUsers.insert(0, u);
      return ApiResponse<UserModel>(success: true, message: 'User created', data: u);
    }

    return _apiService.post<UserModel>(
      '/users',
      data: payload,
      fromJson: (json) => UserModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<UserModel>> updateUser(String id, Map<String, dynamic> payload) async {
    if (AppConfig.enableMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      final idx = _mockUsers.indexWhere((u) => u.id == id);
      if (idx != -1) {
        final existing = _mockUsers[idx];
        final updated = UserModel(
          id: id,
          username: payload['username'] ?? existing.username,
          name: payload['name'] ?? existing.name,
          email: payload['email'] ?? existing.email,
          role: payload['role'] ?? existing.role,
          branch: payload['branch'] ?? existing.branch,
          phone: payload['phone'] ?? existing.phone,
        );
        _mockUsers[idx] = updated;
        return ApiResponse<UserModel>(success: true, message: 'User updated', data: updated);
      }
    }

    return _apiService.put<UserModel>(
      '/users/$id',
      data: payload,
      fromJson: (json) => UserModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<void>> deleteUser(String id) async {
    if (AppConfig.enableMockData) {
      await Future.delayed(const Duration(milliseconds: 200));
      _mockUsers.removeWhere((u) => u.id == id);
      return ApiResponse<void>(success: true, message: 'User deleted');
    }
    return _apiService.delete<void>('/users/$id');
  }
}
