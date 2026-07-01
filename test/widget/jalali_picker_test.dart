import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_drum_picker/material_drum_picker.dart';

import '../helpers.dart';

void main() {
  testWidgets('drum mode shows Persian month names in fa', (tester) async {
    await tester.pumpWidget(buildTestWidget(
      DrumPicker(
        initialDate: DateTime(2024, 3, 20), // 1403 Farvardin 1 (Nowruz)
        currentDate: DateTime(2024, 3, 20),
        firstDate: DateTime(2020),
        lastDate: DateTime(2030),
        calendar: DrumCalendarType.jalali,
        locale: const Locale('fa'),
        showActions: false,
      ),
      locale: const Locale('fa'),
    ));
    await tester.pumpAndSettle();
    expect(find.textContaining('فروردین'), findsWidgets);
  });

  testWidgets('calendar mode renders a 31 day Jalali month', (tester) async {
    await tester.pumpWidget(buildTestWidget(
      DrumPicker(
        initialDate: DateTime(2024, 3, 20), // Farvardin (31 days)
        currentDate: DateTime(2024, 3, 20),
        firstDate: DateTime(2020),
        lastDate: DateTime(2030),
        calendar: DrumCalendarType.jalali,
        initialMode: DrumPickerMode.calendar,
        showModeToggle: false,
        showActions: false,
        locale: const Locale('en'),
      ),
      locale: const Locale('en'),
    ));
    await tester.pumpAndSettle();
    expect(find.textContaining('Farvardin'), findsOneWidget);
    expect(find.text('31'), findsOneWidget);
    expect(find.text('32'), findsNothing);
  });

  testWidgets('calendar mode caps a 30 day Jalali month', (tester) async {
    await tester.pumpWidget(buildTestWidget(
      DrumPicker(
        initialDate: DateTime(2024, 9, 22), // Mehr 1403 (30 days)
        currentDate: DateTime(2024, 9, 22),
        firstDate: DateTime(2020),
        lastDate: DateTime(2030),
        calendar: DrumCalendarType.jalali,
        initialMode: DrumPickerMode.calendar,
        showModeToggle: false,
        showActions: false,
        locale: const Locale('en'),
      ),
      locale: const Locale('en'),
    ));
    await tester.pumpAndSettle();
    expect(find.textContaining('Mehr'), findsOneWidget);
    expect(find.text('30'), findsOneWidget);
    expect(find.text('31'), findsNothing);
  });

  testWidgets('input mode parses a Jalali date to the right Gregorian',
      (tester) async {
    DateTime? changed;
    await tester.pumpWidget(buildTestWidget(
      DrumPicker(
        initialDate: DateTime(2024, 3, 20),
        currentDate: DateTime(2024, 3, 20),
        firstDate: DateTime(2020),
        lastDate: DateTime(2030),
        calendar: DrumCalendarType.jalali,
        initialMode: DrumPickerMode.input,
        showModeToggle: false,
        showActions: false,
        onChanged: (d) => changed = d,
        locale: const Locale('en'),
      ),
      locale: const Locale('en'),
    ));
    await tester.enterText(find.byType(TextField), '01/15/1403');
    await tester.pumpAndSettle();
    expect(changed, const JalaliCalendarSystem().encode(1403, 1, 15));
  });

  testWidgets('showGregorianAlongside adds a Gregorian secondary line',
      (tester) async {
    await tester.pumpWidget(buildTestWidget(
      DrumPicker(
        initialDate: DateTime(2024, 3, 20),
        currentDate: DateTime(2024, 3, 20),
        firstDate: DateTime(2020),
        lastDate: DateTime(2030),
        calendar: DrumCalendarType.jalali,
        showGregorianAlongside: true,
        showActions: false,
        locale: const Locale('en'),
      ),
      locale: const Locale('en'),
    ));
    await tester.pumpAndSettle();
    expect(find.textContaining('March'), findsOneWidget);
  });
}
