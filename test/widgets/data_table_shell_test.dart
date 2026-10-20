import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infocare_crm/models/pagination_model.dart';
import 'package:infocare_crm/widgets/data_table_shell.dart';

void main() {
  testWidgets('DataTableShell renders 12 columns in 638px width without overflow', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(638, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final columns = List.generate(
      12,
      (i) => DataColumn(label: Text('COLUMN $i')),
    );

    final rows = List.generate(
      5,
      (rowIndex) => DataRow(
        cells: List.generate(
          12,
          (colIndex) => DataCell(Text('Cell $rowIndex-$colIndex')),
        ),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 638,
            height: 500,
            child: DataTableShell(
              columns: columns,
              rows: rows,
              pagination: PaginationModel(page: 1, limit: 10, totalItems: 25, totalPages: 3),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('COLUMN 0'), findsOneWidget);
    expect(find.text('Cell 0-0'), findsOneWidget);
    expect(find.textContaining('Page 1 of 3'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
