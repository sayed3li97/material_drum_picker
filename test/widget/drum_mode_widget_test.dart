import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_drum_picker/material_drum_picker.dart';

import '../helpers.dart';

/// The order of the column header labels currently on screen.
List<String?> _headerOrder(WidgetTester tester) => tester
    .widgetList<Text>(find.byType(Text))
    .map((t) => t.data)
    .where((d) => d == 'DAY' || d == 'MONTH' || d == 'YEAR')
    .toList();

void main() {
  testWidgets('columnOrder.dmy shows the Day column first', (tester) async {
    await tester.pumpWidget(buildTestWidget(DrumPicker(
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      currentDate: kTestDate,
      initialMode: DrumPickerMode.drum,
      columnOrder: DrumColumnOrder.dmy,
    )));
    await tester.pumpAndSettle();

    expect(_headerOrder(tester), ['DAY', 'MONTH', 'YEAR']);
  });

  testWidgets('columnOrder.ymd shows the Year column first', (tester) async {
    await tester.pumpWidget(buildTestWidget(DrumPicker(
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      currentDate: kTestDate,
      initialMode: DrumPickerMode.drum,
      columnOrder: DrumColumnOrder.ymd,
    )));
    await tester.pumpAndSettle();

    expect(_headerOrder(tester), ['YEAR', 'MONTH', 'DAY']);
  });

  testWidgets('French locale shows French month names', (tester) async {
    await tester.pumpWidget(buildTestWidget(
      DrumPicker(
        initialDate: DateTime(2024, 6, 15),
        firstDate: DateTime(2024),
        lastDate: DateTime(2025),
        currentDate: DateTime(2024, 6, 15),
        initialMode: DrumPickerMode.drum,
        locale: const Locale('fr'),
      ),
      locale: const Locale('fr'),
    ));
    await tester.pumpAndSettle();
    expect(find.textContaining('juin'), findsWidgets);
  });
}
