import 'package:flutter_test/flutter_test.dart';
import 'package:infocare_crm/models/lead_model.dart';

void main() {
  group('LeadModel Tests', () {
    test('LeadModel fromJson and toJson parsing test', () {
      final json = {
        'id': 'lead_999',
        'contact_name': 'Test Contact',
        'company_name': 'Test Company',
        'phone': '+971500000000',
        'email': 'test@example.com',
        'requirement': 'CCTV 10 cameras',
        'source': 'whatsapp',
        'branch': 'Dubai',
        'estimated_value': 15000,
        'status': 'new',
        'stage': 'site_survey',
        'created_at': '2026-10-01T10:00:00.000Z',
      };

      final lead = LeadModel.fromJson(json);

      expect(lead.id, equals('lead_999'));
      expect(lead.contactName, equals('Test Contact'));
      expect(lead.companyName, equals('Test Company'));
      expect(lead.estimatedValue, equals(15000));
      expect(lead.source, equals('whatsapp'));
      expect(lead.status, equals('new'));

      final jsonOut = lead.toJson();
      expect(jsonOut['contact_name'], equals('Test Contact'));
      expect(jsonOut['estimated_value'], equals(15000));
    });
  });
}
