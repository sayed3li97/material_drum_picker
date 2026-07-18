import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_drum_picker/material_drum_picker.dart';

import '../helpers.dart';

void main() {
  group('constructor guards', () {
    test('precision below day with pickTime asserts', () {
      expect(
        () => DrumPicker(
          firstDate: DateTime(2000),
          lastDate: DateTime(2030),
          precision: DrumPrecision.month,
          pickTime: true,
        ),
        throwsAssertionError,
      );
    });

    test('precision below day with day-level rules asserts', () {
      expect(
        () => DrumPicker(
          firstDate: DateTime(2000),
          lastDate: DateTime(2030),
          precision: DrumPrecision.month,
          selectableDayPredicate: (d) => true,
        ),
        throwsAssertionError,
      );
      expect(
        () => DrumPicker(
          firstDate: DateTime(2000),
          lastDate: DateTime(2030),
          precision: DrumPrecision.year,
          holidays: {DateTime(2024, 1, 1)},
        ),
        throwsAssertionError,
      );
    });
  });

  group('drum mode column suppression', () {
    Future<void> pumpDrum(WidgetTester tester, DrumPrecision precision) async {
      await tester.pumpWidget(buildTestWidget(
        DrumPicker(
          initialDate: DateTime(2024, 6, 15),
          currentDate: DateTime(2024, 6, 15),
          firstDate: DateTime(2000),
          lastDate: DateTime(2030),
          precision: precision,
          showModeToggle: false,
          showHeader: false,
          showActions: false,
          locale: const Locale('en'),
        ),
        locale: const Locale('en'),
      ));
      await tester.pumpAndSettle();
    }

    testWidgets('day precision shows all three columns', (tester) async {
      await pumpDrum(tester, DrumPrecision.day);
      expect(find.text('DAY'), findsOneWidget);
      expect(find.text('MONTH'), findsOneWidget);
      expect(find.text('YEAR'), findsOneWidget);
    });

    testWidgets('month precision hides the day column', (tester) async {
      await pumpDrum(tester, DrumPrecision.month);
      expect(find.text('DAY'), findsNothing);
      expect(find.text('MONTH'), findsOneWidget);
      expect(find.text('YEAR'), findsOneWidget);
    });

    testWidgets('year precision shows only the year column', (tester) async {
      await pumpDrum(tester, DrumPrecision.year);
      expect(find.text('DAY'), findsNothing);
      expect(find.text('MONTH'), findsNothing);
      expect(find.text('YEAR'), findsOneWidget);
    });
  });

  group('calendar mode choosers', () {
    testWidgets('month precision shows a month grid and emits the 1st',
        (tester) async {
      DateTime? changed;
      await tester.pumpWidget(buildTestWidget(
        DrumPicker(
          initialDate: DateTime(2024, 6, 15),
          currentDate: DateTime(2024, 6, 15),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          precision: DrumPrecision.month,
          initialMode: DrumPickerMode.calendar,
          showModeToggle: false,
          showHeader: false,
          showActions: false,
          onChanged: (d) => changed = d,
          locale: const Locale('en'),
        ),
        locale: const Locale('en'),
      ));
      await tester.pumpAndSettle();
      // A month chooser, not a day grid: months present, day numbers absent.
      expect(find.text('Mar'), findsOneWidget);
      expect(find.text('15'), findsNothing);
      await tester.tap(find.text('Mar'));
      await tester.pumpAndSettle();
      expect(changed, DateTime(2024, 3, 1));
    });

    testWidgets('year precision shows a year grid and emits Jan 1',
        (tester) async {
      DateTime? changed;
      await tester.pumpWidget(buildTestWidget(
        DrumPicker(
          initialDate: DateTime(2024, 6, 15),
          currentDate: DateTime(2024, 6, 15),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          precision: DrumPrecision.year,
          initialMode: DrumPickerMode.calendar,
          showModeToggle: false,
          showHeader: false,
          showActions: false,
          onChanged: (d) => changed = d,
          locale: const Locale('en'),
        ),
        locale: const Locale('en'),
      ));
      await tester.pumpAndSettle();
      // The year grid scrolls; reveal the target year before tapping.
      await tester.ensureVisible(find.text('2026'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('2026'));
      await tester.pumpAndSettle();
      expect(changed, DateTime(2026, 1, 1));
    });

    testWidgets('a mid-month firstDate keeps that month selectable',
        (tester) async {
      DateTime? changed;
      await tester.pumpWidget(buildTestWidget(
        DrumPicker(
          initialDate: DateTime(2024, 6, 15),
          currentDate: DateTime(2024, 6, 15),
          firstDate: DateTime(2024, 3, 20), // mid-March
          lastDate: DateTime(2024, 12, 31),
          precision: DrumPrecision.month,
          initialMode: DrumPickerMode.calendar,
          showModeToggle: false,
          showHeader: false,
          showActions: false,
          onChanged: (d) => changed = d,
          locale: const Locale('en'),
        ),
        locale: const Locale('en'),
      ));
      await tester.pumpAndSettle();
      // March is partially in range, so it is selectable; its value clamps to
      // the boundary firstDate rather than the (out-of-range) 1st.
      await tester.tap(find.text('Mar'));
      await tester.pumpAndSettle();
      expect(changed, DateTime(2024, 3, 20));
    });
  });

  group('input mode narrowing', () {
    testWidgets('month precision parses MM/yyyy', (tester) async {
      DateTime? changed;
      await tester.pumpWidget(buildTestWidget(
        DrumPicker(
          initialDate: DateTime(2024, 6, 15),
          currentDate: DateTime(2024, 6, 15),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          precision: DrumPrecision.month,
          initialMode: DrumPickerMode.input,
          showModeToggle: false,
          showHeader: false,
          showActions: false,
          onChanged: (d) => changed = d,
          locale: const Locale('en'),
        ),
        locale: const Locale('en'),
      ));
      await tester.enterText(find.byType(TextField), '03/2026');
      await tester.pumpAndSettle();
      expect(changed, DateTime(2026, 3, 1));
    });

    testWidgets('year precision parses yyyy', (tester) async {
      DateTime? changed;
      await tester.pumpWidget(buildTestWidget(
        DrumPicker(
          initialDate: DateTime(2024, 6, 15),
          currentDate: DateTime(2024, 6, 15),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          precision: DrumPrecision.year,
          initialMode: DrumPickerMode.input,
          showModeToggle: false,
          showHeader: false,
          showActions: false,
          onChanged: (d) => changed = d,
          locale: const Locale('en'),
        ),
        locale: const Locale('en'),
      ));
      await tester.enterText(find.byType(TextField), '2027');
      await tester.pumpAndSettle();
      expect(changed, DateTime(2027, 1, 1));
    });
  });

  group('headline', () {
    testWidgets('month precision headline is "Month Year"', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        DrumPicker(
          initialDate: DateTime(2024, 3, 15),
          currentDate: DateTime(2024, 3, 15),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          precision: DrumPrecision.month,
          initialMode: DrumPickerMode.drum,
          showModeToggle: false,
          showActions: false,
          locale: const Locale('en'),
        ),
        locale: const Locale('en'),
      ));
      await tester.pumpAndSettle();
      expect(find.text('March 2024'), findsOneWidget);
    });
  });

  group('non-Gregorian calendars', () {
    testWidgets('Chinese month chooser shows the leap month in a leap year',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(
        DrumPicker(
          initialDate: DateTime(2023, 6, 1), // lunar year 2023 has a leap month
          currentDate: DateTime(2023, 6, 1),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          calendar: DrumCalendarType.chinese,
          precision: DrumPrecision.month,
          initialMode: DrumPickerMode.calendar,
          showModeToggle: false,
          showHeader: false,
          showActions: false,
          locale: const Locale('zh'),
        ),
        locale: const Locale('zh'),
      ));
      await tester.pumpAndSettle();
      // The leap month tile is present (闰 prefix), proving the chooser renders
      // the 13-month set for a leap year.
      expect(find.textContaining('闰'), findsOneWidget);
    });

    testWidgets('Jalali month precision emits the first of the Persian month',
        (tester) async {
      DateTime? changed;
      const system = JalaliCalendarSystem();
      await tester.pumpWidget(buildTestWidget(
        DrumPicker(
          initialDate: DateTime(2024, 6, 15),
          currentDate: DateTime(2024, 6, 15),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          calendar: DrumCalendarType.jalali,
          precision: DrumPrecision.month,
          initialMode: DrumPickerMode.calendar,
          showModeToggle: false,
          showHeader: false,
          showActions: false,
          onChanged: (d) => changed = d,
          locale: const Locale('en'),
        ),
        locale: const Locale('en'),
      ));
      await tester.pumpAndSettle();
      // Tap Farvardin (the first Persian month) and expect the first day of it.
      await tester.tap(find.text('Far'));
      await tester.pumpAndSettle();
      final c = system.decode(changed!);
      expect(c.month, 1);
      expect(c.day, 1);
      expect(changed, system.encode(c.year, 1, 1));
    });
  });
}
