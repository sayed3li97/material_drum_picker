import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_drum_picker/material_drum_picker.dart';

import '../helpers.dart';

void main() {
  // 2023-03-22 is the first day of the leap month 2 (闰二月) of lunar year 2023.
  final leapDay = DateTime(2023, 3, 22);

  testWidgets('drum mode in zh shows the leap month and the ganzhi year',
      (tester) async {
    await tester.pumpWidget(buildTestWidget(
      DrumPicker(
        initialDate: leapDay,
        currentDate: leapDay,
        firstDate: DateTime(2000),
        lastDate: DateTime(2050),
        calendar: DrumCalendarType.chinese,
        showActions: false,
        locale: const Locale('zh'),
      ),
      locale: const Locale('zh'),
    ));
    await tester.pumpAndSettle();
    // The month wheel shows the leap month name, and the year wheel shows the
    // sexagenary year 癸卯 on its second line.
    expect(find.textContaining('闰二月'), findsWidgets);
    expect(find.textContaining('癸卯'), findsWidgets);
  });

  testWidgets('drum mode in en shows the zodiac in the year column',
      (tester) async {
    await tester.pumpWidget(buildTestWidget(
      DrumPicker(
        initialDate: leapDay,
        currentDate: leapDay,
        firstDate: DateTime(2000),
        lastDate: DateTime(2050),
        calendar: DrumCalendarType.chinese,
        showActions: false,
        locale: const Locale('en'),
      ),
      locale: const Locale('en'),
    ));
    await tester.pumpAndSettle();
    expect(find.textContaining('Rabbit'), findsWidgets);
    expect(find.textContaining('Leap 2'), findsWidgets);
  });

  testWidgets('calendar mode shows the leap month header and 29 day length',
      (tester) async {
    await tester.pumpWidget(buildTestWidget(
      DrumPicker(
        initialDate: leapDay,
        currentDate: leapDay,
        firstDate: DateTime(2000),
        lastDate: DateTime(2050),
        calendar: DrumCalendarType.chinese,
        initialMode: DrumPickerMode.calendar,
        showModeToggle: false,
        showActions: false,
        locale: const Locale('en'),
      ),
      locale: const Locale('en'),
    ));
    await tester.pumpAndSettle();
    expect(find.textContaining('Leap Month 2'), findsOneWidget);
    // The 2023 leap month 2 has 29 days, so day 29 exists and 30 does not.
    expect(find.text('29'), findsOneWidget);
    expect(find.text('30'), findsNothing);
  });

  testWidgets('selecting in the calendar returns the right Gregorian date',
      (tester) async {
    DateTime? changed;
    await tester.pumpWidget(buildTestWidget(
      DrumPicker(
        initialDate: leapDay,
        currentDate: leapDay,
        firstDate: DateTime(2000),
        lastDate: DateTime(2050),
        calendar: DrumCalendarType.chinese,
        initialMode: DrumPickerMode.calendar,
        showModeToggle: false,
        showActions: false,
        onChanged: (d) => changed = d,
        locale: const Locale('en'),
      ),
      locale: const Locale('en'),
    ));
    await tester.pumpAndSettle();
    // Day 10 of leap month 2, 2023 is 2023-03-31.
    await tester.tap(find.text('10'));
    await tester.pumpAndSettle();
    expect(changed, DateTime(2023, 3, 31));
  });
}
