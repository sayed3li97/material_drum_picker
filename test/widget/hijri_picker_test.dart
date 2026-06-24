import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_drum_picker/material_drum_picker.dart';

import '../helpers.dart';

List<TabularLunarMonth> _synthetic({int months = 24}) {
  final out = <TabularLunarMonth>[];
  var g = DateTime(2024, 7, 7);
  var hy = 1446;
  var hm = 1;
  for (var i = 0; i <= months; i++) {
    out.add(
        TabularLunarMonth(hijriYear: hy, hijriMonth: hm, gregorianStart: g));
    g = g.add(Duration(days: i.isEven ? 30 : 29));
    hm++;
    if (hm > 12) {
      hm = 1;
      hy++;
    }
  }
  return out;
}

void main() {
  testWidgets('drum mode shows Arabic Hijri month names in ar', (tester) async {
    await tester.pumpWidget(buildTestWidget(
      DrumPicker(
        initialDate: DateTime(2024, 7, 10), // 1446 Muharram
        currentDate: DateTime(2024, 7, 10),
        firstDate: DateTime(2020),
        lastDate: DateTime(2030),
        calendar: DrumCalendarType.hijri,
        locale: const Locale('ar'),
        showActions: false,
      ),
      locale: const Locale('ar'),
    ));
    await tester.pumpAndSettle();
    expect(find.textContaining('محرم'), findsWidgets);
  });

  testWidgets('calendar mode renders a Hijri month with no day past 30',
      (tester) async {
    await tester.pumpWidget(buildTestWidget(
      DrumPicker(
        initialDate: DateTime(2024, 7, 10),
        currentDate: DateTime(2024, 7, 10),
        firstDate: DateTime(2020),
        lastDate: DateTime(2030),
        calendar: DrumCalendarType.hijri,
        initialMode: DrumPickerMode.calendar,
        showModeToggle: false,
        showActions: false,
        locale: const Locale('en'),
      ),
      locale: const Locale('en'),
    ));
    await tester.pumpAndSettle();
    expect(find.textContaining('Muharram'), findsOneWidget);
    expect(find.text('15'), findsOneWidget);
    expect(find.text('31'), findsNothing);
  });

  testWidgets('input mode parses a Hijri date to the right Gregorian',
      (tester) async {
    DateTime? changed;
    await tester.pumpWidget(buildTestWidget(
      DrumPicker(
        initialDate: DateTime(2024, 7, 7),
        currentDate: DateTime(2024, 7, 7),
        firstDate: DateTime(2020),
        lastDate: DateTime(2030),
        calendar: DrumCalendarType.hijri,
        initialMode: DrumPickerMode.input,
        showModeToggle: false,
        showActions: false,
        onChanged: (d) => changed = d,
        locale: const Locale('en'),
      ),
      locale: const Locale('en'),
    ));
    await tester.enterText(find.byType(TextField), '01/15/1446');
    await tester.pumpAndSettle();
    expect(changed, const HijriCalendarSystem().encode(1446, 1, 15));
  });

  testWidgets('showGregorianAlongside adds a Gregorian secondary line',
      (tester) async {
    await tester.pumpWidget(buildTestWidget(
      DrumPicker(
        initialDate: DateTime(2024, 7, 7),
        currentDate: DateTime(2024, 7, 7),
        firstDate: DateTime(2020),
        lastDate: DateTime(2030),
        calendar: DrumCalendarType.hijri,
        showGregorianAlongside: true,
        showActions: false,
        locale: const Locale('en'),
      ),
      locale: const Locale('en'),
    ));
    await tester.pumpAndSettle();
    expect(find.textContaining('July'), findsOneWidget);
  });

  testWidgets('a custom tabular system drives the calendar', (tester) async {
    final system = TabularLunarCalendarSystem(_synthetic());
    await tester.pumpWidget(buildTestWidget(
      DrumPicker(
        initialDate: system.minSupported,
        currentDate: system.minSupported,
        firstDate: system.minSupported,
        lastDate: system.maxSupported,
        calendarSystem: system,
        initialMode: DrumPickerMode.calendar,
        showModeToggle: false,
        showActions: false,
        locale: const Locale('en'),
      ),
      locale: const Locale('en'),
    ));
    await tester.pumpAndSettle();
    expect(find.textContaining('Muharram'), findsOneWidget);
    // First synthetic month is 30 days, so day 30 exists and 31 does not.
    expect(find.text('30'), findsOneWidget);
    expect(find.text('31'), findsNothing);
  });
}
