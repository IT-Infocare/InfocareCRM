import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:infocare_crm/controllers/auth_controller.dart';
import 'package:infocare_crm/controllers/quotation_controller.dart';
import 'package:infocare_crm/controllers/settings_controller.dart';
import 'package:infocare_crm/models/quotation_item_model.dart';
import 'package:infocare_crm/models/quotation_model.dart';
import 'package:infocare_crm/models/user_model.dart';
import 'package:infocare_crm/screens/quotes/dialogs/quotation_pdf_preview_dialog.dart';
import 'package:infocare_crm/screens/quotes/quotation_detail_screen.dart';
import 'package:infocare_crm/screens/quotes/quotation_list_screen.dart';
import 'package:infocare_crm/services/api_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.reset();
    Get.put(ApiService());
    final auth = Get.put(AuthController());
    auth.currentUser.value = UserModel(
      id: 'usr_admin',
      username: 'admin',
      name: 'System Administrator',
      email: 'admin@infocare.ae',
      role: 'admin',
      branch: 'Dubai',
    );
    Get.put(SettingsController());
  });

  tearDown(() {
    Get.reset();
  });

  final testQuote = QuotationModel(
    id: 'qt_test_101',
    quotationNumber: 'QT-2026-529',
    version: 1,
    status: 'draft',
    validUntil: DateTime(2026, 11, 6),
    customerId: 'cust_001',
    customerName: 'Valued Customer',
    preparedBy: 'Field Sales Executive',
    terms: '50% advance, 50% upon installation completion. 1 year warranty included.',
    subtotal: 630.0,
    vatAmount: 31.5,
    totalAmount: 661.5,
    pdfUrl: 'https://example.com/test.pdf',
    items: [
      QuotationItemModel(
        id: 'item_1',
        productId: 'prod_1',
        productName: 'Hikvision 4MP IP Dome Camera',
        description: '4MP Outdoor/Indoor IR Network Dome Camera with PoE',
        quantity: 1,
        unitPrice: 350.0,
        discount: 0,
        lineTotal: 350.0,
      ),
      QuotationItemModel(
        id: 'item_2',
        productId: 'prod_2',
        productName: 'Electro-Magnetic Lock 600lbs with Bracket',
        description: 'Fail-safe 280kg / 600lbs magnetic lock with ZL bracket & LED',
        quantity: 1,
        unitPrice: 280.0,
        discount: 0,
        lineTotal: 280.0,
      ),
    ],
    createdAt: DateTime(2026, 10, 23),
  );

  testWidgets('QuotationDetailScreen displays Created Date and opens PDF preview dialog', (tester) async {
    final controller = Get.put(QuotationController());
    controller.selectedQuotation.value = testQuote;
    controller.quotations.assignAll([testQuote]);

    await tester.binding.setSurfaceSize(const Size(1280, 800));

    await tester.pumpWidget(
      GetMaterialApp(
        home: const QuotationDetailScreen(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Created Date is displayed in header tiles
    expect(find.text('Created Date'), findsOneWidget);
    expect(find.text('Oct 23, 2026'), findsOneWidget);
    expect(find.text('Valid Until'), findsOneWidget);
    expect(find.text('Nov 06, 2026'), findsOneWidget);

    // Tap "Preview PDF" button
    final previewButton = find.text('Preview PDF');
    expect(previewButton, findsOneWidget);
    await tester.tap(previewButton);
    await tester.pumpAndSettle();

    // Verify QuotationPdfPreviewDialog is opened
    expect(find.byType(QuotationPdfPreviewDialog), findsOneWidget);
    expect(find.text('QT-2026-529 (v1) - PDF Preview'), findsOneWidget);
    expect(find.text('COMMERCIAL QUOTATION'), findsOneWidget);
    expect(find.text('Valued Customer'), findsAtLeastNWidgets(1));
    expect(find.text('Hikvision 4MP IP Dome Camera'), findsAtLeastNWidgets(1));
    expect(find.text('Electro-Magnetic Lock 600lbs with Bracket'), findsAtLeastNWidgets(1));

    // Close preview dialog cleanly
    await tester.tap(find.byTooltip('Close Preview'));
    await tester.pumpAndSettle();
  });

  testWidgets('QuotationListScreen displays CREATED DATE column and formatted cell', (tester) async {
    if (!Get.isRegistered<ApiService>()) Get.put(ApiService());
    final controller = Get.put(QuotationController());
    controller.quotations.assignAll([testQuote]);
    controller.isLoading.value = false;

    await tester.binding.setSurfaceSize(const Size(1280, 800));

    await tester.pumpWidget(
      GetMaterialApp(
        home: const QuotationListScreen(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify CREATED DATE column header is present
    expect(find.text('CREATED DATE'), findsOneWidget);
    // Verify formatted date is present in the table row
    expect(find.text('Oct 23, 2026'), findsOneWidget);
  });
}
