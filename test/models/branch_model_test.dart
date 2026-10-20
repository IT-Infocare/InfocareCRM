import 'package:flutter_test/flutter_test.dart';
import 'package:infocare_crm/models/branch_model.dart';

void main() {
  group('BranchModel Tests', () {
    test('BranchModel fromJson and toJson parsing test with shortName', () {
      final json = {
        'id': '77777777-7777-4777-a777-777777777777',
        'company_id': '11111111-2222-3333-4444-555555555555',
        'company_name': 'InfoCare Systems',
        'name': 'InfoCare System Dubai',
        'short_name': 'Dubai',
        'code': 'DXB',
        'country': 'UAE',
        'city': 'Dubai',
        'currency': 'AED',
        'vat_percent': 5.0,
        'timezone': 'Asia/Dubai',
        'phone': '+971 4 321 0000',
        'email': 'dubai@infocare.ae',
        'is_active': true,
      };

      final branch = BranchModel.fromJson(json);

      expect(branch.id, equals('77777777-7777-4777-a777-777777777777'));
      expect(branch.name, equals('InfoCare System Dubai'));
      expect(branch.shortName, equals('Dubai'));
      expect(branch.code, equals('DXB'));
      expect(branch.isActive, isTrue);

      final jsonOut = branch.toJson();
      expect(jsonOut['short_name'], equals('Dubai'));
      expect(jsonOut['shortName'], equals('Dubai'));
      expect(jsonOut['code'], equals('DXB'));
    });

    test('BranchModel copyWith preserves and updates shortName', () {
      final branch = BranchModel(
        id: '1',
        name: 'Infocare Abu Dhabi',
        shortName: 'Abu Dhabi',
        code: 'AUH',
      );

      expect(branch.shortName, equals('Abu Dhabi'));

      final updated = branch.copyWith(shortName: 'AUH Branch');
      expect(updated.shortName, equals('AUH Branch'));
      expect(updated.name, equals('Infocare Abu Dhabi'));
    });

    test('BranchModel deriveShortName correctly handles legacy records without explicit short_name', () {
      final legacyDubai = BranchModel.fromJson({
        'id': 'b1',
        'name': 'Infocare Surveillance Systems LLC — Dubai',
        'code': 'DXB',
      });
      final legacyRak = BranchModel.fromJson({
        'id': 'b2',
        'name': 'Infocare Surveillance Systems LLC — RAK',
        'code': 'RAK',
      });
      final legacyKerala = BranchModel.fromJson({
        'id': 'b3',
        'name': 'Infocare Back Office — Kerala',
        'code': 'KER',
      });

      expect(legacyDubai.shortName, equals('Dubai'));
      expect(legacyDubai.displayShortName, equals('Dubai'));

      expect(legacyRak.shortName, equals('RAK'));
      expect(legacyRak.displayShortName, equals('RAK'));

      expect(legacyKerala.shortName, equals('Kerala'));
      expect(legacyKerala.displayShortName, equals('Kerala'));
    });
  });
}
