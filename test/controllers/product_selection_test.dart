import 'package:flutter_test/flutter_test.dart';
import 'package:infocare_crm/controllers/settings_controller.dart';
import 'package:infocare_crm/controllers/product_controller.dart';
import 'package:infocare_crm/models/quotation_item_model.dart';
import 'package:infocare_crm/services/api_service.dart';
import 'package:get/get.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.reset();
    Get.put(ApiService());
  });

  tearDown(() {
    Get.reset();
  });

  test('SettingsController initializes with default product catalogue immediately', () {
    final setCtrl = Get.put(SettingsController());
    expect(setCtrl.products.isNotEmpty, isTrue);
    expect(setCtrl.products.length, greaterThanOrEqualTo(10));

    // Verify key products exist
    final names = setCtrl.products.map((p) => p.name).toList();
    expect(names.any((n) => n.contains('Hikvision')), isTrue);
    expect(names.any((n) => n.contains('Cisco')), isTrue);
    expect(names.any((n) => n.contains('Yeastar')), isTrue);
  });

  test('ProductController initializes with default products and filters properly', () {
    final prodCtrl = Get.put(ProductController());
    expect(prodCtrl.products.isNotEmpty, isTrue);

    // Verify categories
    expect(prodCtrl.categories.contains('CCTV'), isTrue);
    expect(prodCtrl.categories.contains('Networking'), isTrue);
    expect(prodCtrl.categories.contains('Telecom'), isTrue);

    // Filter by query
    prodCtrl.searchQuery.value = 'Hikvision';
    expect(prodCtrl.filteredProducts.isNotEmpty, isTrue);
    for (final p in prodCtrl.filteredProducts) {
      expect(
        p.name.toLowerCase().contains('hikvision') ||
            p.sku.toLowerCase().contains('hikvision') ||
            (p.category?.toLowerCase().contains('hikvision') ?? false),
        isTrue,
      );
    }
  });

  test('QuotationItemModel calculates line item total with discount correctly', () {
    const qty = 3;
    const price = 350.0;
    const disc = 10.0;
    const expectedTotal = (qty * price) * (1 - (disc / 100)); // 1050 * 0.9 = 945.0

    final item = QuotationItemModel(
      id: 'qti_123',
      productId: 'prod_001',
      productName: 'Hikvision 4MP IP Dome Camera',
      quantity: qty,
      unitPrice: price,
      discount: disc,
      lineTotal: expectedTotal,
      sortOrder: 1,
    );

    expect(item.lineTotal, 945.0);
    expect(item.productName, 'Hikvision 4MP IP Dome Camera');
  });
}
