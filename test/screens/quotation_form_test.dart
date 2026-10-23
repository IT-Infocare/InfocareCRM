import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:infocare_crm/controllers/customer_controller.dart';
import 'package:infocare_crm/controllers/quotation_controller.dart';
import 'package:infocare_crm/screens/quotes/forms/quotation_form.dart';
import 'package:infocare_crm/services/api_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.reset();
    Get.put(ApiService());
    Get.put(CustomerController());
    Get.put(QuotationController());
  });

  tearDown(() {
    Get.reset();
  });

  test('CustomerController initializes with allCustomers immediately', () {
    final custCtrl = Get.find<CustomerController>();
    expect(custCtrl.allCustomers.isNotEmpty, isTrue);
    expect(custCtrl.allCustomers.length, greaterThanOrEqualTo(5));

    final names = custCtrl.allCustomers.map((c) => c.name).toList();
    expect(names.contains('Ahmed Al Mansoori'), isTrue);
    expect(names.contains('John Smith'), isTrue);
    expect(names.contains('Mr. Rex'), isTrue);
  });

  testWidgets('QuotationFormDialog renders customer dropdown and lists all customers', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const GetMaterialApp(
        home: Scaffold(
          body: QuotationFormDialog(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify dialog title
    expect(find.text('Create New Quotation / BOQ'), findsOneWidget);

    // Verify customer dropdown is rendered and populated
    expect(find.text('Select Customer *'), findsOneWidget);
    expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);

    // Verify customer item is visible
    expect(find.textContaining('Ahmed Al Mansoori'), findsWidgets);
  });
}
