import 'package:get/get.dart';
import '../models/product_bundle_model.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';
import '../services/product_service.dart';
import 'settings_controller.dart';

class ProductController extends GetxController {
  final ProductService _productService = ProductService(Get.find<ApiService>());

  final RxBool isLoading = true.obs;
  final RxList<ProductModel> products = RxList<ProductModel>(SettingsController.defaultProducts);
  final RxList<ProductBundleModel> productBundles = <ProductBundleModel>[].obs;

  final RxInt activeTabIndex = 0.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedCategory = 'All'.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    try {
      final pRes = await _productService.getProducts();
      if (pRes.success && pRes.data != null) {
        final serverList = pRes.data!;
        final merged = <ProductModel>[...serverList];
        for (final def in SettingsController.defaultProducts) {
          if (!merged.any((p) => p.id == def.id || (p.sku.isNotEmpty && p.sku == def.sku))) {
            merged.add(def);
          }
        }
        products.assignAll(merged);
      }

      final bRes = await _productService.getProductBundles();
      if (bRes.success && bRes.data != null) {
        productBundles.assignAll(bRes.data!);
      }
    } catch (_) {
      // keep default/current products
    } finally {
      isLoading.value = false;
    }
  }

  List<String> get categories {
    final set = <String>{'All'};
    for (final p in products) {
      if (p.category != null && p.category!.trim().isNotEmpty) {
        set.add(p.category!.trim());
      }
    }
    return set.toList();
  }

  List<ProductModel> get filteredProducts {
    final query = searchQuery.value.trim().toLowerCase();
    final cat = selectedCategory.value;

    return products.where((p) {
      final matchesCategory = cat == 'All' || (p.category?.toLowerCase() == cat.toLowerCase());
      final matchesQuery = query.isEmpty ||
          p.name.toLowerCase().contains(query) ||
          p.sku.toLowerCase().contains(query) ||
          (p.category?.toLowerCase().contains(query) ?? false);
      return matchesCategory && matchesQuery;
    }).toList();
  }

  List<ProductBundleModel> get filteredBundles {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return productBundles;

    return productBundles.where((b) {
      return b.name.toLowerCase().contains(query) ||
          (b.description?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  Future<bool> createProduct(Map<String, dynamic> payload) async {
    final res = await _productService.createProduct(payload);
    if (res.success && res.data != null) {
      products.insert(0, res.data!);
      // Keep SettingsController in sync if active
      if (Get.isRegistered<SettingsController>()) {
        Get.find<SettingsController>().products.insert(0, res.data!);
      }
      Get.back();
      Get.snackbar('Success', 'Product "${res.data!.name}" added to catalog');
      return true;
    }
    Get.snackbar('Error', res.message ?? 'Failed to create product');
    return false;
  }

  Future<bool> updateProduct(String id, Map<String, dynamic> payload) async {
    final res = await _productService.updateProduct(id, payload);
    if (res.success && res.data != null) {
      final idx = products.indexWhere((p) => p.id == id);
      if (idx != -1) {
        products[idx] = res.data!;
      }
      if (Get.isRegistered<SettingsController>()) {
        final sIdx = Get.find<SettingsController>().products.indexWhere((p) => p.id == id);
        if (sIdx != -1) {
          Get.find<SettingsController>().products[sIdx] = res.data!;
        }
      }
      Get.back();
      Get.snackbar('Success', 'Product updated successfully');
      return true;
    }
    Get.snackbar('Error', res.message ?? 'Failed to update product');
    return false;
  }

  Future<bool> deleteProduct(String id) async {
    final res = await _productService.deleteProduct(id);
    if (res.success) {
      products.removeWhere((p) => p.id == id);
      if (Get.isRegistered<SettingsController>()) {
        Get.find<SettingsController>().products.removeWhere((p) => p.id == id);
      }
      Get.snackbar('Success', 'Product deleted from catalog');
      return true;
    }
    Get.snackbar('Error', res.message ?? 'Failed to delete product');
    return false;
  }

  Future<bool> createBundle(Map<String, dynamic> payload) async {
    final res = await _productService.createProductBundle(payload);
    if (res.success && res.data != null) {
      productBundles.insert(0, res.data!);
      if (Get.isRegistered<SettingsController>()) {
        Get.find<SettingsController>().productBundles.insert(0, res.data!);
      }
      Get.back();
      Get.snackbar('Success', 'Product bundle "${res.data!.name}" created');
      return true;
    }
    Get.snackbar('Error', res.message ?? 'Failed to create bundle');
    return false;
  }

  Future<bool> deleteBundle(String id) async {
    final res = await _productService.deleteProductBundle(id);
    if (res.success) {
      productBundles.removeWhere((b) => b.id == id);
      if (Get.isRegistered<SettingsController>()) {
        Get.find<SettingsController>().productBundles.removeWhere((b) => b.id == id);
      }
      Get.snackbar('Success', 'Product bundle removed');
      return true;
    }
    Get.snackbar('Error', res.message ?? 'Failed to delete bundle');
    return false;
  }
}
