import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_drum_picker/material_drum_picker.dart';
import 'package:material_drum_picker/src/widgets/internal/drum_column.dart';

import '../helpers.dart';

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

    final cols =
        tester.widgetList<DrumColumn>(find.byType(DrumColumn)).toList();
    expect(cols.length, 3);
    expect(cols[0].label, 'DAY');
    expect(cols[1].label, 'MONTH');
    expect(cols[2].label, 'YEAR');
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

    final cols =
        tester.widgetList<DrumColumn>(find.byType(DrumColumn)).toList();
    expect(cols[0].label, 'YEAR');
    expect(cols[1].label, 'MONTH');
    expect(cols[2].label, 'DAY');
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
