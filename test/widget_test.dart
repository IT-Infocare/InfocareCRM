import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infocare_crm/widgets/status_badge.dart';

void main() {
  testWidgets('StatusBadge renders correct label', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StatusBadge(status: 'pending_approval'),
        ),
      ),
    );

    expect(find.text('Pending Approval'), findsOneWidget);
  });
}
