import '../config/api_endpoints.dart';
import '../config/app_config.dart';
import '../models/api_response.dart';
import '../models/branch_model.dart';
import '../models/product_bundle_model.dart';
import '../models/product_model.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class SettingsService {
  final ApiService _apiService;

  SettingsService(this._apiService);

  final List<UserModel> _mockUsers = [
    UserModel(id: 'a0000000-0000-4000-a000-000000000001', username: 'Admin', name: 'System Administrator', email: 'admin@infocare.ae', role: 'admin', branch: 'Dubai', phone: '+971 50 100 0000'),
    UserModel(id: 'usr_1001', username: 'sarah.c', name: 'Sarah Connor', email: 'sarah.c@infocare.ae', role: 'admin', branch: 'Dubai', phone: '+971 50 123 4567'),
    UserModel(id: 'usr_1002', username: 'rahul.v', name: 'Rahul Verma', email: 'rahul.v@infocare.ae', role: 'branch_sales', branch: 'RAK', phone: '+971 55 234 5678'),
    UserModel(id: 'usr_1003', username: 'amal.k', name: 'Amal Kumar', email: 'amal.k@infocare.ae', role: 'kerala_back_office', branch: 'Kerala', phone: '+91 98 470 12345'),
    UserModel(id: 'usr_1004', username: 'dir', name: 'Management Director', email: 'dir@infocare.ae', role: 'management', branch: 'Dubai', phone: '+971 50 999 0000'),
  ];

  final List<BranchModel> _mockBranches = [
    BranchModel(id: 'br_01', name: 'Dubai HQ Office', code: 'Dubai', isActive: true),
    BranchModel(id: 'br_02', name: 'Ras Al Khaimah Branch', code: 'RAK', isActive: true),
    BranchModel(id: 'br_03', name: 'Kerala Back Office', code: 'Kerala', isActive: true),
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

  Future<ApiResponse<List<BranchModel>>> getBranches() async {
    if (AppConfig.enableMockData) {
      await Future.delayed(const Duration(milliseconds: 200));
      return ApiResponse<List<BranchModel>>(success: true, data: _mockBranches);
    }
    return _apiService.get<List<BranchModel>>(
      '/branches',
      fromJson: (json) => (json as List<dynamic>).map((e) => BranchModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Future<ApiResponse<BranchModel>> createBranch(Map<String, dynamic> payload) async {
    if (AppConfig.enableMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      final b = BranchModel.fromJson({
        'id': 'br_${DateTime.now().millisecondsSinceEpoch}',
        'name': payload['name'] ?? '',
        'code': payload['code'] ?? '',
        'is_active': payload['is_active'] ?? true,
      });
      _mockBranches.insert(0, b);
      return ApiResponse<BranchModel>(success: true, message: 'Branch created', data: b);
    }
    return _apiService.post<BranchModel>(
      '/branches',
      data: payload,
      fromJson: (json) => BranchModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<BranchModel>> updateBranch(String id, Map<String, dynamic> payload) async {
    if (AppConfig.enableMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      final idx = _mockBranches.indexWhere((b) => b.id == id);
      if (idx != -1) {
        final updated = BranchModel(
          id: id,
          name: payload['name'] ?? _mockBranches[idx].name,
          code: payload['code'] ?? _mockBranches[idx].code,
          isActive: payload['is_active'] ?? payload['isActive'] ?? _mockBranches[idx].isActive,
        );
        _mockBranches[idx] = updated;
        return ApiResponse<BranchModel>(success: true, message: 'Branch updated', data: updated);
      }
    }
    return _apiService.put<BranchModel>(
      '/branches/$id',
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
    return _apiService.delete<void>('/branches/$id');
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
}
