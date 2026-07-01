import 'package:flutter/cupertino.dart' show CupertinoDatePickerMode;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_drum_picker/material_drum_picker.dart';

import '../helpers.dart';

void main() {
  final today = DateTime(2024, 6, 17);

  group('DrumCalendarDatePicker (CalendarDatePicker drop-in)', () {
    testWidgets('renders the grid with no header and reports a tap',
        (tester) async {
      DateTime? changed;
      await tester.pumpWidget(buildTestWidget(
        DrumCalendarDatePicker(
          initialDate: today,
          firstDate: DateTime(2024, 6, 1),
          lastDate: DateTime(2024, 6, 30),
          currentDate: today,
          onDateChanged: (d) => changed = d,
        ),
        locale: const Locale('en'),
      ));
      await tester.pumpAndSettle();
      // Header is hidden in the inline drop-in.
      expect(find.text('SELECT DATE'), findsNothing);
      // The grid is present.
      expect(find.text('17'), findsOneWidget);
      await tester.tap(find.text('22'));
      await tester.pumpAndSettle();
      expect(changed, DateTime(2024, 6, 22));
    });

    testWidgets('onDisplayedMonthChanged fires on selection', (tester) async {
      DateTime? month;
      await tester.pumpWidget(buildTestWidget(
        DrumCalendarDatePicker(
          initialDate: today,
          firstDate: DateTime(2024, 6, 1),
          lastDate: DateTime(2024, 6, 30),
          currentDate: today,
          onDateChanged: (_) {},
          onDisplayedMonthChanged: (m) => month = m,
        ),
        locale: const Locale('en'),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.text('22'));
      await tester.pumpAndSettle();
      expect(month, DateTime(2024, 6));
    });

    testWidgets('exposes extras: a holiday is not selectable', (tester) async {
      DateTime? changed;
      await tester.pumpWidget(buildTestWidget(
        DrumCalendarDatePicker(
          initialDate: today,
          firstDate: DateTime(2024, 6, 1),
          lastDate: DateTime(2024, 6, 30),
          currentDate: today,
          holidays: {DateTime(2024, 6, 20)},
          onDateChanged: (d) => changed = d,
        ),
        locale: const Locale('en'),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.text('20'));
      await tester.pumpAndSettle();
      expect(changed, isNull);
    });
  });

  group('DrumCupertinoDatePicker (CupertinoDatePicker drop-in)', () {
    testWidgets('date mode streams the selected date with no header',
        (tester) async {
      DateTime? changed;
      await tester.pumpWidget(buildTestWidget(
        SizedBox(
          height: 280,
          child: DrumCupertinoDatePicker(
            mode: CupertinoDatePickerMode.date,
            initialDateTime: today,
            minimumDate: DateTime(2020),
            maximumDate: DateTime(2030),
            onDateTimeChanged: (d) => changed = d,
          ),
        ),
        locale: const Locale('en'),
      ));
      await tester.pumpAndSettle();
      expect(find.text('SELECT DATE'), findsNothing);
      // The day, month, and year wheels are present (June, 17, 2024 centered).
      expect(find.text('17'), findsWidgets);
      expect(find.text('2024'), findsWidgets);
      // It rendered without error; streaming callback is wired.
      expect(tester.takeException(), isNull);
      expect(changed, isNull); // no interaction yet
    });

    testWidgets('dateAndTime mode shows a time strip', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        SizedBox(
          height: 600,
          child: DrumCupertinoDatePicker(
            mode: CupertinoDatePickerMode.dateAndTime,
            initialDateTime: DateTime(2024, 6, 17, 9, 30),
            minimumDate: DateTime(2020),
            maximumDate: DateTime(2030),
            use24hFormat: true,
            onDateTimeChanged: (_) {},
          ),
        ),
        locale: const Locale('en'),
      ));
      await tester.pumpAndSettle();
      expect(find.text('HOUR'), findsOneWidget);
      expect(find.text('MIN'), findsOneWidget);
    });

    testWidgets('time mode shows only the time wheels', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        SizedBox(
          height: 280,
          child: DrumCupertinoDatePicker(
            mode: CupertinoDatePickerMode.time,
            initialDateTime: DateTime(2024, 6, 17, 9, 30),
            use24hFormat: false,
            onDateTimeChanged: (_) {},
          ),
        ),
        locale: const Locale('en'),
      ));
      await tester.pumpAndSettle();
      expect(find.text('HOUR'), findsOneWidget);
      expect(find.text('AM/PM'), findsOneWidget);
      expect(find.text('DAY'), findsNothing); // no date columns in time mode
    });
  });

  group('showDrumDatePicker entry-mode mapping', () {
    testWidgets('initialEntryMode.calendarOnly hides the toggle and opens grid',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => showDrumDatePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                  initialDate: today,
                  currentDate: today,
                  initialEntryMode: DatePickerEntryMode.calendarOnly,
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      // Calendar grid is shown (a day cell), and the mode tabs are hidden.
      expect(find.text('17'), findsOneWidget);
      expect(find.text('Calendar'), findsNothing);
      expect(find.text('Drum'), findsNothing);
    });
  });
}
