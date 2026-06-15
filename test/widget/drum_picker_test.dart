import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_drum_picker/material_drum_picker.dart';

import '../helpers.dart';

void main() {
  testWidgets('custom helpText appears in the header', (tester) async {
    await tester.pumpWidget(buildTestWidget(DrumPicker(
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      currentDate: kTestDate,
      helpText: 'PICK YOUR DATE',
    )));
    await tester.pumpAndSettle();
    expect(find.text('PICK YOUR DATE'), findsOneWidget);
  });

  testWidgets('default helpText is SELECT DATE', (tester) async {
    await tester.pumpWidget(buildTestWidget(DrumPicker(
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      currentDate: kTestDate,
    )));
    await tester.pumpAndSettle();
    expect(find.text('SELECT DATE'), findsOneWidget);
  });

  testWidgets('onModeChanged fires when switching to calendar', (tester) async {
    DrumPickerMode? captured;
    await tester.pumpWidget(buildTestWidget(DrumPicker(
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      currentDate: kTestDate,
      onModeChanged: (mode) => captured = mode,
    )));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Calendar'));
    await tester.pumpAndSettle();
    expect(captured, DrumPickerMode.calendar);
  });

  testWidgets('custom quickSelectOptions replace the defaults', (tester) async {
    await tester.pumpWidget(buildTestWidget(DrumPicker(
      firstDate: DateTime(2024, 6, 1),
      lastDate: DateTime(2024, 6, 30),
      currentDate: kTestDate,
      initialMode: DrumPickerMode.calendar,
      quickSelectOptions: [
        DrumQuickSelect(label: 'Custom A', date: DateTime(2024, 6, 10)),
        DrumQuickSelect(label: 'Custom B', date: DateTime(2024, 6, 20)),
      ],
    )));
    await tester.pumpAndSettle();
    expect(find.text('Custom A'), findsOneWidget);
    expect(find.text('Custom B'), findsOneWidget);
    expect(find.text('Today'), findsNothing);
  });

  testWidgets('out-of-range quick select chip is disabled', (tester) async {
    DateTime? changed;
    await tester.pumpWidget(buildTestWidget(DrumPicker(
      initialDate: DateTime(2024, 6, 11),
      firstDate: DateTime(2024, 6, 10),
      lastDate: DateTime(2024, 6, 20),
      currentDate: DateTime(2024, 6, 11),
      initialMode: DrumPickerMode.calendar,
      onChanged: (d) => changed = d,
      quickSelectOptions: [
        DrumQuickSelect(label: 'In Range', date: DateTime(2024, 6, 15)),
        DrumQuickSelect(label: 'Out of Range', date: DateTime(2024, 7, 1)),
      ],
    )));
    await tester.pumpAndSettle();

    expect(find.text('Out of Range'), findsOneWidget);

    final outChip = tester.widget<ActionChip>(
      find.ancestor(
        of: find.text('Out of Range'),
        matching: find.byType(ActionChip),
      ),
    );
    expect(outChip.onPressed, isNull, reason: 'out-of-range chip is disabled');

    final inChip = tester.widget<ActionChip>(
      find.ancestor(
        of: find.text('In Range'),
        matching: find.byType(ActionChip),
      ),
    );
    expect(inChip.onPressed, isNotNull);

    await tester.ensureVisible(find.text('In Range'));
    await tester.tap(find.text('In Range'));
    await tester.pumpAndSettle();
    expect(changed, DateTime(2024, 6, 15));
  });

  testWidgets('showActions false hides the OK/Cancel buttons', (tester) async {
    await tester.pumpWidget(buildTestWidget(DrumPicker(
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      currentDate: kTestDate,
      showActions: false,
    )));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextButton, 'OK'), findsNothing);
  });
}
