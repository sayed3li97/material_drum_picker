import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_drum_picker/material_drum_picker.dart';
import 'package:material_drum_picker/src/widgets/internal/day_cell.dart';

import '../helpers.dart';

const _calendars = <DrumCalendarType>[
  DrumCalendarType.gregorian,
  DrumCalendarType.hijri,
  DrumCalendarType.chinese,
  DrumCalendarType.jalali,
];

DrumCalendarSystem _systemFor(DrumCalendarType type) => switch (type) {
      DrumCalendarType.gregorian => const GregorianCalendarSystem(),
      DrumCalendarType.hijri => const HijriCalendarSystem(),
      DrumCalendarType.chinese => const ChineseCalendarSystem(),
      DrumCalendarType.jalali => const JalaliCalendarSystem(),
    };

void main() {
  final today = DateTime(2024, 6, 15);

  group('Q1: starts on today by default (no initialDate)', () {
    for (final cal in _calendars) {
      testWidgets('$cal opens with today selected', (tester) async {
        DateTime? confirmed;
        await tester.pumpWidget(buildTestWidget(
          DrumPicker(
            firstDate: DateTime(1950),
            lastDate: DateTime(2050),
            currentDate: today, // stands in for DateTime.now()
            calendar: cal,
            locale: const Locale('en'),
            onConfirmed: (d) => confirmed = d,
          ),
          locale: const Locale('en'),
        ));
        await tester.pumpAndSettle();
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();
        expect(confirmed, today);
      });
    }
  });

  group('Q1: the calendar grid rings today accurately', () {
    for (final cal in _calendars) {
      testWidgets('$cal marks exactly the right day as today', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          DrumPicker(
            firstDate: DateTime(1950),
            lastDate: DateTime(2050),
            currentDate: today,
            initialDate: today,
            calendar: cal,
            initialMode: DrumPickerMode.calendar,
            showModeToggle: false,
            showActions: false,
            locale: const Locale('en'),
          ),
          locale: const Locale('en'),
        ));
        await tester.pumpAndSettle();
        final todayCells = tester
            .widgetList<DayCell>(find.byType(DayCell))
            .where((c) => c.isToday)
            .toList();
        expect(todayCells.length, 1, reason: 'exactly one today cell');
        // The ringed day matches this calendar's own decoding of today.
        expect(todayCells.single.day, _systemFor(cal).decode(today).day);
      });
    }
  });

  group('Q2: initialDate sets the starting date', () {
    final initial = DateTime(2022, 3, 9);
    for (final cal in _calendars) {
      testWidgets('$cal opens on initialDate, not today', (tester) async {
        DateTime? confirmed;
        await tester.pumpWidget(buildTestWidget(
          DrumPicker(
            firstDate: DateTime(1950),
            lastDate: DateTime(2050),
            currentDate: today,
            initialDate: initial,
            calendar: cal,
            locale: const Locale('en'),
            onConfirmed: (d) => confirmed = d,
          ),
          locale: const Locale('en'),
        ));
        await tester.pumpAndSettle();
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();
        expect(confirmed, initial);
      });
    }

    testWidgets('the show* dialog also honors initialDate', (tester) async {
      DateTime? result;
      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () async {
                  result = await showDrumDatePicker(
                    context: context,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2030),
                    initialDate: DateTime(2021, 7, 4),
                  );
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(result, DateTime(2021, 7, 4));
    });
  });

  group('every mode renders and round trips for every calendar', () {
    for (final cal in _calendars) {
      for (final mode in DrumPickerMode.values) {
        testWidgets('$cal in $mode mode renders without error', (tester) async {
          await tester.pumpWidget(buildTestWidget(
            DrumPicker(
              firstDate: DateTime(1990),
              lastDate: DateTime(2040),
              currentDate: today,
              initialDate: today,
              calendar: cal,
              initialMode: mode,
              showModeToggle: false,
              showActions: false,
              locale: const Locale('en'),
            ),
            locale: const Locale('en'),
          ));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        });
      }
    }
  });

  group('option sweep (smoke + invariants)', () {
    DrumPicker base({
      DrumColumnOrder? columnOrder,
      bool pickTime = false,
      bool? use24h,
      int minuteInterval = 1,
      bool showQuickSelects = true,
      SelectableDayPredicate? predicate,
      DrumPickerTheme? theme,
      DrumPickerLabels labels = const DrumPickerLabels(),
      Locale locale = const Locale('en'),
      TextDirection? textDirection,
      DrumPickerMode mode = DrumPickerMode.drum,
    }) =>
        DrumPicker(
          firstDate: DateTime(2000),
          lastDate: DateTime(2030),
          currentDate: today,
          initialDate: today,
          initialMode: mode,
          columnOrder: columnOrder,
          pickTime: pickTime,
          use24hFormat: use24h,
          minuteInterval: minuteInterval,
          showQuickSelects: showQuickSelects,
          selectableDayPredicate: predicate,
          theme: theme,
          labels: labels,
          showActions: false,
          locale: locale,
          textDirection: textDirection,
        );

    for (final order in DrumColumnOrder.values) {
      testWidgets('columnOrder $order renders', (tester) async {
        await tester.pumpWidget(buildTestWidget(base(columnOrder: order)));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('15'), findsWidgets);
      });
    }

    testWidgets('pickTime adds a 12h time strip with AM/PM', (tester) async {
      await tester
          .pumpWidget(buildTestWidget(base(pickTime: true, use24h: false)));
      await tester.pumpAndSettle();
      expect(find.text('AM/PM'), findsOneWidget);
    });

    testWidgets('24h pickTime hides AM/PM', (tester) async {
      await tester
          .pumpWidget(buildTestWidget(base(pickTime: true, use24h: true)));
      await tester.pumpAndSettle();
      expect(find.text('AM/PM'), findsNothing);
    });

    testWidgets('minuteInterval limits the minute column', (tester) async {
      await tester.pumpWidget(buildTestWidget(
          base(pickTime: true, use24h: true, minuteInterval: 15)));
      await tester.pumpAndSettle();
      // The minute column is present, but padded non-multiples like 05 (which
      // the default interval of 1 would show) do not appear with interval 15.
      expect(find.text('MIN'), findsOneWidget);
      expect(find.text('05'), findsNothing);
    });

    testWidgets('selectableDayPredicate blocks a day in the calendar',
        (tester) async {
      DateTime? changed;
      await tester.pumpWidget(buildTestWidget(
        DrumPicker(
          firstDate: DateTime(2024, 6, 1),
          lastDate: DateTime(2024, 6, 30),
          currentDate: today,
          initialDate: today,
          initialMode: DrumPickerMode.calendar,
          showModeToggle: false,
          showActions: false,
          selectableDayPredicate: (d) => d.day != 20,
          onChanged: (d) => changed = d,
          locale: const Locale('en'),
        ),
        locale: const Locale('en'),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.text('20'));
      await tester.pumpAndSettle();
      expect(changed, isNull); // tap on a blocked day is ignored
    });

    testWidgets('per-instance theme reaches the header', (tester) async {
      const headerColor = Color(0xFF334455);
      await tester.pumpWidget(buildTestWidget(base(
          theme: const DrumPickerTheme(headerBackgroundColor: headerColor))));
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate((w) => w is Container && w.color == headerColor),
        findsOneWidget,
      );
    });

    testWidgets('labels relabel the mode tabs', (tester) async {
      await tester.pumpWidget(buildTestWidget(DrumPicker(
        firstDate: DateTime(2000),
        lastDate: DateTime(2030),
        currentDate: today,
        initialDate: today,
        labels: const DrumPickerLabels(drumMode: 'Wheel'),
        showActions: false,
        locale: const Locale('en'),
      )));
      await tester.pumpAndSettle();
      expect(find.text('Wheel'), findsWidgets);
    });

    testWidgets('RTL locale lays out without error', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        base(locale: const Locale('ar'), textDirection: TextDirection.rtl),
        locale: const Locale('ar'),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
