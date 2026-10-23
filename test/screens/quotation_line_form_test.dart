import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:infocare_crm/controllers/settings_controller.dart';
import 'package:infocare_crm/models/quotation_item_model.dart';
import 'package:infocare_crm/screens/quotes/forms/quotation_line_form.dart';
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

  testWidgets('QuotationLineFormDialog renders product dropdown and allows selecting items', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    QuotationItemModel? addedItem;

    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: QuotationLineFormDialog(
            onAddLine: (item) {
              addedItem = item;
            },
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify dialog title
    expect(find.text('Add Line Item to BOQ'), findsOneWidget);

    // Verify dropdown is rendered
    expect(find.text('Select from Catalogue'), findsOneWidget);
    expect(find.text('+ Custom Item / Service'), findsOneWidget);
    expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);

    // Verify default selection exists (e.g. Hikvision)
    expect(find.textContaining('Hikvision'), findsWidgets);

    // Switch to Custom Item mode
    await tester.tap(find.text('+ Custom Item / Service'));
    await tester.pumpAndSettle();

    expect(find.text('Custom Product / Service Name *'), findsOneWidget);

    // Switch back to Catalogue mode
    await tester.tap(find.text('Select from Catalogue'));
    await tester.pumpAndSettle();

    expect(find.text('Select Product *'), findsOneWidget);
    expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);

    // Submit line item
    await tester.tap(find.text('Add Line Item'));
    await tester.pumpAndSettle();

    expect(addedItem, isNotNull);
    expect(addedItem!.productName.isNotEmpty, isTrue);
    expect(addedItem!.unitPrice, greaterThan(0));
    expect(addedItem!.lineTotal, greaterThan(0));
  });
}
