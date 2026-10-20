import '../config/api_endpoints.dart';
import '../config/app_config.dart';
import '../models/api_response.dart';
import '../models/product_bundle_model.dart';
import '../models/product_model.dart';
import 'api_service.dart';

class ProductService {
  final ApiService _apiService;

  ProductService(this._apiService);

  static final List<ProductModel> _mockProducts = [
    ProductModel(id: 'prod_cctv_4k', name: 'Hikvision 4K IP Dome Camera 4MP', sku: 'HIK-4K-DOME', category: 'CCTV', unitPrice: 450, costPrice: 280),
    ProductModel(id: 'prod_nvr_64ch', name: 'Hikvision 64-Channel NVR recorder 4K', sku: 'HIK-NVR-64', category: 'CCTV', unitPrice: 8500, costPrice: 5800),
    ProductModel(id: 'prod_wifi_ap', name: 'Aruba Wi-Fi 6 Enterprise Access Point', sku: 'ARUBA-AP6', category: 'Networking', unitPrice: 2800, costPrice: 1950),
    ProductModel(id: 'prod_poe_switch', name: 'Cisco 48-Port Gigabit Managed PoE+ Switch', sku: 'CISCO-48POE', category: 'Networking', unitPrice: 15500, costPrice: 11000),
    ProductModel(id: 'prod_pabx_system', name: 'Yeastar P560 IP PBX System 100 Ext', sku: 'YEASTAR-P560', category: 'Telecom', unitPrice: 6200, costPrice: 4100),
  ];

  static final List<ProductBundleModel> _mockBundles = [
    ProductBundleModel(
      id: 'bndl_01',
      name: 'Standard 16-Camera IP CCTV Package',
      description: '16 IP cameras + 16-ch NVR + 2TB Hard Disk + Installation',
      items: [
        ProductBundleItem(product: _mockProducts[0], quantity: 16),
        ProductBundleItem(product: _mockProducts[1], quantity: 1),
      ],
      bundlePrice: 14500,
    ),
    ProductBundleModel(
      id: 'bndl_02',
      name: 'Small Office Wi-Fi & Telecom Bundle',
      description: '2 Aruba APs + Yeastar PBX + 5 IP Phones',
      items: [
        ProductBundleItem(product: _mockProducts[2], quantity: 2),
        ProductBundleItem(product: _mockProducts[4], quantity: 1),
      ],
      bundlePrice: 11800,
    ),
  ];

  Future<ApiResponse<List<ProductModel>>> getProducts({String? search, String? category}) async {
    if (AppConfig.enableMockData) {
      await Future.delayed(const Duration(milliseconds: 250));
      var list = List<ProductModel>.from(_mockProducts);
      if (category != null && category != 'All' && category.isNotEmpty) {
        list = list.where((p) => p.category?.toLowerCase() == category.toLowerCase()).toList();
      }
      if (search != null && search.isNotEmpty) {
        final q = search.toLowerCase();
        list = list.where((p) =>
            p.name.toLowerCase().contains(q) ||
            p.sku.toLowerCase().contains(q) ||
            (p.category?.toLowerCase().contains(q) ?? false)).toList();
      }
      return ApiResponse<List<ProductModel>>(success: true, data: list);
    }

    return _apiService.get<List<ProductModel>>(
      ApiEndpoints.products,
      fromJson: (json) => (json as List<dynamic>).map((e) => ProductModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Future<ApiResponse<ProductModel>> createProduct(Map<String, dynamic> payload) async {
    if (AppConfig.enableMockData) {
      await Future.delayed(const Duration(milliseconds: 250));
      final p = ProductModel.fromJson({
        'id': 'prod_${DateTime.now().millisecondsSinceEpoch}',
        'name': payload['name'] ?? '',
        'sku': payload['sku'] ?? '',
        'category': payload['category'] ?? 'General',
        'unit_price': payload['unit_price'] ?? 0.0,
        'cost_price': payload['cost_price'] ?? 0.0,
      });
      _mockProducts.insert(0, p);
      return ApiResponse<ProductModel>(success: true, message: 'Product added successfully', data: p);
    }

    return _apiService.post<ProductModel>(
      ApiEndpoints.products,
      data: payload,
      fromJson: (json) => ProductModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<ProductModel>> updateProduct(String id, Map<String, dynamic> payload) async {
    if (AppConfig.enableMockData) {
      await Future.delayed(const Duration(milliseconds: 250));
      final idx = _mockProducts.indexWhere((p) => p.id == id);
      if (idx != -1) {
        final existing = _mockProducts[idx];
        final updated = ProductModel(
          id: id,
          name: payload['name'] ?? existing.name,
          sku: payload['sku'] ?? existing.sku,
          category: payload['category'] ?? existing.category,
          description: payload['description'] ?? existing.description,
          unitPrice: payload['unit_price'] ?? existing.unitPrice,
          costPrice: payload['cost_price'] ?? existing.costPrice,
          isActive: payload['is_active'] ?? existing.isActive,
        );
        _mockProducts[idx] = updated;
        return ApiResponse<ProductModel>(success: true, message: 'Product updated successfully', data: updated);
      }
    }

    return _apiService.put<ProductModel>(
      '${ApiEndpoints.products}/$id',
      data: payload,
      fromJson: (json) => ProductModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<void>> deleteProduct(String id) async {
    if (AppConfig.enableMockData) {
      await Future.delayed(const Duration(milliseconds: 200));
      _mockProducts.removeWhere((p) => p.id == id);
      return ApiResponse<void>(success: true, message: 'Product deleted');
    }

    return _apiService.delete<void>('${ApiEndpoints.products}/$id');
  }

  Future<ApiResponse<List<ProductBundleModel>>> getProductBundles({String? search}) async {
    if (AppConfig.enableMockData) {
      await Future.delayed(const Duration(milliseconds: 250));
      var list = List<ProductBundleModel>.from(_mockBundles);
      if (search != null && search.isNotEmpty) {
        final q = search.toLowerCase();
        list = list.where((b) =>
            b.name.toLowerCase().contains(q) ||
            (b.description?.toLowerCase().contains(q) ?? false)).toList();
      }
      return ApiResponse<List<ProductBundleModel>>(success: true, data: list);
    }

    return _apiService.get<List<ProductBundleModel>>(
      ApiEndpoints.productBundles,
      fromJson: (json) => (json as List<dynamic>).map((e) => ProductBundleModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Future<ApiResponse<ProductBundleModel>> createProductBundle(Map<String, dynamic> payload) async {
    if (AppConfig.enableMockData) {
      await Future.delayed(const Duration(milliseconds: 250));
      final b = ProductBundleModel.fromJson({
        'id': 'bndl_${DateTime.now().millisecondsSinceEpoch}',
        'name': payload['name'] ?? '',
        'description': payload['description'] ?? '',
        'bundle_price': payload['bundle_price'] ?? 0.0,
        'items': payload['items'] ?? [],
      });
      _mockBundles.insert(0, b);
      return ApiResponse<ProductBundleModel>(success: true, message: 'Bundle created successfully', data: b);
    }

    return _apiService.post<ProductBundleModel>(
      ApiEndpoints.productBundles,
      data: payload,
      fromJson: (json) => ProductBundleModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<void>> deleteProductBundle(String id) async {
    if (AppConfig.enableMockData) {
      await Future.delayed(const Duration(milliseconds: 200));
      _mockBundles.removeWhere((b) => b.id == id);
      return ApiResponse<void>(success: true, message: 'Bundle deleted');
    }

    return _apiService.delete<void>('${ApiEndpoints.productBundles}/$id');
  }
}
