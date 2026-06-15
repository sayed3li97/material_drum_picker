import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_drum_picker/material_drum_picker.dart';

import '../helpers.dart';

void main() {
  testWidgets('rejects a disabled date with the invalid error text',
      (tester) async {
    await tester.pumpWidget(buildTestWidget(DrumPicker(
      firstDate: DateTime(2024),
      lastDate: DateTime(2025),
      currentDate: DateTime(2024, 1, 1),
      initialMode: DrumPickerMode.input,
      showModeToggle: false,
      selectableDayPredicate: (day) => day.weekday != DateTime.saturday,
      errorInvalidText: 'Not available',
    )));
    await tester.enterText(find.byType(TextField), '06/15/2024'); // Saturday
    await tester.pumpAndSettle();
    expect(find.text('Not available'), findsOneWidget);
  });

  testWidgets('rejects malformed input with the format error text',
      (tester) async {
    await tester.pumpWidget(buildTestWidget(DrumPicker(
      firstDate: DateTime(2024),
      lastDate: DateTime(2025),
      currentDate: DateTime(2024, 1, 1),
      initialMode: DrumPickerMode.input,
      showModeToggle: false,
      errorFormatText: 'Bad format',
    )));
    await tester.enterText(find.byType(TextField), '13/45/2024');
    await tester.pumpAndSettle();
    expect(find.text('Bad format'), findsOneWidget);
  });

  testWidgets('accepts a valid in-range date and reports the change',
      (tester) async {
    DateTime? changed;
    await tester.pumpWidget(buildTestWidget(DrumPicker(
      firstDate: DateTime(2024),
      lastDate: DateTime(2025),
      currentDate: DateTime(2024, 1, 1),
      initialMode: DrumPickerMode.input,
      showModeToggle: false,
      onChanged: (d) => changed = d,
    )));
    await tester.enterText(find.byType(TextField), '03/10/2024');
    await tester.pumpAndSettle();
    expect(changed, DateTime(2024, 3, 10));
  });

  testWidgets('rejects an out-of-range date', (tester) async {
    await tester.pumpWidget(buildTestWidget(DrumPicker(
      firstDate: DateTime(2024, 6, 1),
      lastDate: DateTime(2024, 6, 30),
      currentDate: DateTime(2024, 6, 1),
      initialMode: DrumPickerMode.input,
      showModeToggle: false,
      errorInvalidText: 'Out of range',
    )));
    await tester.enterText(find.byType(TextField), '12/25/2024');
    await tester.pumpAndSettle();
    expect(find.text('Out of range'), findsOneWidget);
  });
}
