import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_drum_picker/material_drum_picker.dart';

import '../helpers.dart';

void main() {
  testWidgets('disabled day is not tappable in calendar mode', (tester) async {
    DateTime? changed;
    await tester.pumpWidget(buildTestWidget(DrumPicker(
      initialDate: kTestDate, // June 15 2024 — a Saturday
      firstDate: DateTime(2024, 6, 1),
      lastDate: DateTime(2024, 6, 30),
      currentDate: kTestDate,
      initialMode: DrumPickerMode.calendar,
      showModeToggle: false,
      selectableDayPredicate: (day) => day.weekday != DateTime.saturday,
      onChanged: (d) => changed = d,
    )));
    await tester.pumpAndSettle();

    await tester.tap(find.text('15'));
    await tester.pumpAndSettle();
    expect(changed, isNull, reason: 'tapping a disabled day does nothing');
  });

  testWidgets('tapping an enabled day reports the change', (tester) async {
    DateTime? changed;
    await tester.pumpWidget(buildTestWidget(DrumPicker(
      initialDate: DateTime(2024, 6, 1),
      firstDate: DateTime(2024, 6, 1),
      lastDate: DateTime(2024, 6, 30),
      currentDate: DateTime(2024, 6, 1),
      initialMode: DrumPickerMode.calendar,
      showModeToggle: false,
      onChanged: (d) => changed = d,
    )));
    await tester.pumpAndSettle();

    await tester.tap(find.text('18'));
    await tester.pumpAndSettle();
    expect(changed, DateTime(2024, 6, 18));
  });

  testWidgets('next-month navigation changes the header', (tester) async {
    await tester.pumpWidget(buildTestWidget(DrumPicker(
      initialDate: DateTime(2024, 6, 1),
      firstDate: DateTime(2024, 1, 1),
      lastDate: DateTime(2024, 12, 31),
      currentDate: DateTime(2024, 6, 1),
      initialMode: DrumPickerMode.calendar,
      showModeToggle: false,
    )));
    await tester.pumpAndSettle();

    expect(find.text('June 2024'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();
    expect(find.text('July 2024'), findsOneWidget);
  });
}
