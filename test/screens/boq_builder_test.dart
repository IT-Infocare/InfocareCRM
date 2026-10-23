import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:infocare_crm/controllers/quotation_controller.dart';
import 'package:infocare_crm/controllers/settings_controller.dart';
import 'package:infocare_crm/models/quotation_item_model.dart';
import 'package:infocare_crm/models/quotation_model.dart';
import 'package:infocare_crm/screens/quotes/forms/quotation_line_form.dart';
import 'package:infocare_crm/screens/quotes/quotation_detail_screen.dart';
import 'package:infocare_crm/services/api_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.reset();
    Get.put(ApiService());
    Get.put(SettingsController());
  });

  tearDown(() {
    Get.reset();
  });

  test('QuotationController adds multiple line items without replacing and allows deleting', () async {
    final controller = Get.put(QuotationController());

    final initialQuote = QuotationModel(
      id: 'qt_test_999',
      quotationNumber: 'QT-2026-999',
      version: 1,
      status: 'draft',
      validUntil: DateTime.now().add(const Duration(days: 14)),
      customerId: 'cust_001',
      customerName: 'Test Customer',
      preparedBy: 'Sales Rep',
      subtotal: 0,
      vatAmount: 0,
      totalAmount: 0,
      items: [],
      createdAt: DateTime.now(),
    );

    controller.selectedQuotation.value = initialQuote;
    controller.quotations.assignAll([initialQuote]);

    final item1 = QuotationItemModel(
      id: 'qti_1',
      productId: 'prod_1',
      productName: 'Fanvil X3U Enterprise IP Phone',
      quantity: 1,
      unitPrice: 220.0,
      discount: 0,
      lineTotal: 220.0,
    );

    await controller.addLineItem('qt_test_999', item1);

    expect(controller.selectedQuotation.value!.items.length, 1);
    expect(controller.selectedQuotation.value!.items.first.productName, 'Fanvil X3U Enterprise IP Phone');
    expect(controller.selectedQuotation.value!.subtotal, 220.0);
    expect(controller.selectedQuotation.value!.vatAmount, 11.0);
    expect(controller.selectedQuotation.value!.totalAmount, 231.0);

    // Add second item - it MUST append, NOT replace!
    final item2 = QuotationItemModel(
      id: 'qti_2',
      productId: 'prod_2',
      productName: 'Aruba Wi-Fi 6 Enterprise Access Point',
      quantity: 2,
      unitPrice: 1000.0,
      discount: 10,
      lineTotal: 1800.0,
    );

    await controller.addLineItem('qt_test_999', item2);

    expect(controller.selectedQuotation.value!.items.length, 2);
    expect(controller.selectedQuotation.value!.items[0].productName, 'Fanvil X3U Enterprise IP Phone');
    expect(controller.selectedQuotation.value!.items[1].productName, 'Aruba Wi-Fi 6 Enterprise Access Point');
    expect(controller.selectedQuotation.value!.subtotal, 2020.0);
    expect(controller.selectedQuotation.value!.vatAmount, 101.0);
    expect(controller.selectedQuotation.value!.totalAmount, 2121.0);

    // Delete first item
    await controller.deleteLineItem('qt_test_999', 'qti_1');

    expect(controller.selectedQuotation.value!.items.length, 1);
    expect(controller.selectedQuotation.value!.items.first.productName, 'Aruba Wi-Fi 6 Enterprise Access Point');
    expect(controller.selectedQuotation.value!.subtotal, 1800.0);
    expect(controller.selectedQuotation.value!.vatAmount, 90.0);
    expect(controller.selectedQuotation.value!.totalAmount, 1890.0);
  });

  testWidgets('QuotationLineFormDialog in edit mode pre-fills initial item and updates', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    QuotationItemModel? editedItem;

    final initial = QuotationItemModel(
      id: 'qti_edit_1',
      productId: 'prod_test',
      productName: 'Custom Cisco Firewall Config',
      description: 'Layer 7 inspection',
      quantity: 3,
      unitPrice: 1500,
      discount: 5,
      lineTotal: 4275,
    );

    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: QuotationLineFormDialog(
            initialItem: initial,
            onAddLine: (item) {
              editedItem = item;
            },
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify dialog title says Edit
    expect(find.text('Edit BOQ Line Item'), findsOneWidget);
    expect(find.text('Update Line Item'), findsOneWidget);

    // Tap Update Line Item
    await tester.tap(find.text('Update Line Item'));
    await tester.pumpAndSettle();

    expect(editedItem, isNotNull);
    expect(editedItem!.id, 'qti_edit_1');
    expect(editedItem!.productName, 'Custom Cisco Firewall Config');
    expect(editedItem!.quantity, 3);
  });
}
