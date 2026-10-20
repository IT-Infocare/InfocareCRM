import 'package:flutter_test/flutter_test.dart';
import 'package:infocare_crm/models/product_bundle_model.dart';
import 'package:infocare_crm/models/product_model.dart';

void main() {
  group('ProductModel & ProductBundleModel Tests', () {
    test('ProductModel fromJson and toJson parsing test', () {
      final json = {
        'id': 'prod_test_01',
        'name': 'Test IP Camera 4K',
        'sku': 'HIK-TEST-4K',
        'category': 'CCTV',
        'unit_price': 500,
        'cost_price': 300,
        'is_active': true,
      };

      final prod = ProductModel.fromJson(json);
      expect(prod.id, equals('prod_test_01'));
      expect(prod.name, equals('Test IP Camera 4K'));
      expect(prod.sku, equals('HIK-TEST-4K'));
      expect(prod.unitPrice, equals(500));
      expect(prod.costPrice, equals(300));

      final jsonOut = prod.toJson();
      expect(jsonOut['sku'], equals('HIK-TEST-4K'));
      expect(jsonOut['cost_price'], equals(300));
    });

    test('ProductBundleModel fromJson and toJson with items', () {
      final json = {
        'id': 'bndl_test_01',
        'name': 'Complete 8-Cam Office Bundle',
        'description': '8 IP Cameras with NVR and Cabling',
        'bundle_price': 8500,
        'items': [
          {
            'product': {
              'id': 'prod_01',
              'name': 'Dome Camera',
              'sku': 'DOME-01',
              'category': 'CCTV',
              'unit_price': 400,
              'cost_price': 250,
            },
            'quantity': 8,
          }
        ],
      };

      final bundle = ProductBundleModel.fromJson(json);
      expect(bundle.id, equals('bndl_test_01'));
      expect(bundle.name, equals('Complete 8-Cam Office Bundle'));
      expect(bundle.bundlePrice, equals(8500));
      expect(bundle.items.length, equals(1));
      expect(bundle.items.first.quantity, equals(8));
      expect(bundle.items.first.product.name, equals('Dome Camera'));

      final jsonOut = bundle.toJson();
      expect(jsonOut['bundle_price'], equals(8500));
      expect(jsonOut['items'], isA<List>());
    });
  });
}
