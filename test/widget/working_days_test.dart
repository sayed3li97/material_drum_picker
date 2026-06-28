import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_drum_picker/material_drum_picker.dart';

import '../helpers.dart';

void main() {
  // June 2024: the 1st is a Saturday. 15=Sat, 16=Sun, 17=Mon, 18=Tue,
  // 20=Thu, 21=Fri.
  final june17 = DateTime(2024, 6, 17); // a Monday (working day)

  DrumPicker calendar({
    Set<int>? disabledWeekdays,
    Set<DateTime>? holidays,
    int? firstDayOfWeek,
    DateTime? initialDate,
    ValueChanged<DateTime>? onChanged,
  }) =>
      DrumPicker(
        initialDate: initialDate ?? june17,
        currentDate: june17,
        firstDate: DateTime(2024, 6, 1),
        lastDate: DateTime(2024, 6, 30),
        initialMode: DrumPickerMode.calendar,
        showModeToggle: false,
        showActions: false,
        disabledWeekdays: disabledWeekdays,
        holidays: holidays,
        firstDayOfWeek: firstDayOfWeek,
        onChanged: onChanged,
        locale: const Locale('en'),
      );

  group('disabledWeekdays (working days only)', () {
    testWidgets('a weekend day cannot be tapped, a working day can',
        (tester) async {
      DateTime? changed;
      await tester.pumpWidget(buildTestWidget(calendar(
        disabledWeekdays: {DateTime.saturday, DateTime.sunday},
        onChanged: (d) => changed = d,
      )));
      await tester.pumpAndSettle();
      await tester.tap(find.text('16')); // Sunday
      await tester.pumpAndSettle();
      expect(changed, isNull);
      await tester.tap(find.text('18')); // Tuesday
      await tester.pumpAndSettle();
      expect(changed, DateTime(2024, 6, 18));
    });

    testWidgets('the opening date snaps off a weekend', (tester) async {
      DateTime? confirmed;
      await tester.pumpWidget(buildTestWidget(DrumPicker(
        // No initialDate; currentDate is Saturday the 15th.
        currentDate: DateTime(2024, 6, 15),
        firstDate: DateTime(2024, 6, 1),
        lastDate: DateTime(2024, 6, 30),
        disabledWeekdays: {DateTime.saturday, DateTime.sunday},
        onConfirmed: (d) => confirmed = d,
        locale: const Locale('en'),
      )));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      // Nearest working day to Sat 15 is Fri 14.
      expect(confirmed, DateTime(2024, 6, 14));
      expect(confirmed!.weekday, isNot(DateTime.saturday));
      expect(confirmed!.weekday, isNot(DateTime.sunday));
    });
  });

  group('holidays', () {
    testWidgets('a holiday cannot be tapped', (tester) async {
      DateTime? changed;
      await tester.pumpWidget(buildTestWidget(calendar(
        holidays: {DateTime(2024, 6, 20)},
        onChanged: (d) => changed = d,
      )));
      await tester.pumpAndSettle();
      await tester.tap(find.text('20')); // holiday
      await tester.pumpAndSettle();
      expect(changed, isNull);
      await tester.tap(find.text('21'));
      await tester.pumpAndSettle();
      expect(changed, DateTime(2024, 6, 21));
    });

    testWidgets('holidays ignore the time component', (tester) async {
      DateTime? changed;
      await tester.pumpWidget(buildTestWidget(calendar(
        holidays: {DateTime(2024, 6, 20, 9, 30)}, // time is ignored
        onChanged: (d) => changed = d,
      )));
      await tester.pumpAndSettle();
      await tester.tap(find.text('20'));
      await tester.pumpAndSettle();
      expect(changed, isNull);
    });

    testWidgets('the opening date snaps off a holiday', (tester) async {
      DateTime? confirmed;
      await tester.pumpWidget(buildTestWidget(DrumPicker(
        initialDate: DateTime(2024, 6, 20),
        currentDate: DateTime(2024, 6, 20),
        firstDate: DateTime(2024, 6, 1),
        lastDate: DateTime(2024, 6, 30),
        holidays: {DateTime(2024, 6, 20)},
        onConfirmed: (d) => confirmed = d,
        locale: const Locale('en'),
      )));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(confirmed, DateTime(2024, 6, 21));
    });

    testWidgets('input mode rejects a holiday', (tester) async {
      DateTime? changed;
      await tester.pumpWidget(buildTestWidget(DrumPicker(
        initialDate: june17,
        currentDate: june17,
        firstDate: DateTime(2024, 6, 1),
        lastDate: DateTime(2024, 6, 30),
        initialMode: DrumPickerMode.input,
        showModeToggle: false,
        showActions: false,
        holidays: {DateTime(2024, 6, 20)},
        onChanged: (d) => changed = d,
        locale: const Locale('en'),
      )));
      await tester.enterText(find.byType(TextField), '06/20/2024');
      await tester.pumpAndSettle();
      expect(changed, isNull);
      await tester.enterText(find.byType(TextField), '06/21/2024');
      await tester.pumpAndSettle();
      expect(changed, DateTime(2024, 6, 21));
    });
  });

  group('firstDayOfWeek', () {
    // June 2024 starts on a Saturday, so the count of leading empty cells in
    // the grid reveals where the week begins.
    Finder emptyCells() => find.byWidgetPredicate((w) =>
        w is SizedBox && w.width == 44 && w.height == 44 && w.child == null);

    testWidgets('default (en locale) starts the week on Sunday',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(calendar(initialDate: june17)));
      await tester.pumpAndSettle();
      expect(emptyCells(), findsNWidgets(6)); // Sat is 6 cells after Sunday
    });

    testWidgets('Monday start shifts the grid', (tester) async {
      await tester.pumpWidget(buildTestWidget(
          calendar(initialDate: june17, firstDayOfWeek: DateTime.monday)));
      await tester.pumpAndSettle();
      expect(emptyCells(), findsNWidgets(5)); // Sat is 5 cells after Monday
    });
  });
}
