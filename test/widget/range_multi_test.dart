import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_drum_picker/material_drum_picker.dart';

import '../helpers.dart';

void main() {
  final june = DateTime(2024, 6, 15);

  group('DrumDateRangePicker (inline)', () {
    testWidgets('selecting a start then an end reports the range',
        (tester) async {
      DateTimeRange? range;
      await tester.pumpWidget(buildTestWidget(
        DrumDateRangePicker(
          firstDate: DateTime(2024, 6, 1),
          lastDate: DateTime(2024, 6, 30),
          currentDate: june,
          onChanged: (r) => range = r,
        ),
        locale: const Locale('en'),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.text('5'));
      await tester.pumpAndSettle();
      expect(range, isNull); // incomplete after one tap
      await tester.tap(find.text('12'));
      await tester.pumpAndSettle();
      expect(range, isNotNull);
      expect(range!.start, DateTime(2024, 6, 5));
      expect(range!.end, DateTime(2024, 6, 12));
    });

    testWidgets('tapping an earlier day moves the start', (tester) async {
      DateTimeRange? range;
      await tester.pumpWidget(buildTestWidget(
        DrumDateRangePicker(
          firstDate: DateTime(2024, 6, 1),
          lastDate: DateTime(2024, 6, 30),
          currentDate: june,
          onChanged: (r) => range = r,
        ),
        locale: const Locale('en'),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.text('10')); // start
      await tester.tap(find.text('4')); // earlier -> becomes new start
      await tester.pumpAndSettle();
      expect(range, isNull); // still incomplete (only a start)
      await tester.tap(find.text('20'));
      await tester.pumpAndSettle();
      expect(range!.start, DateTime(2024, 6, 4));
      expect(range!.end, DateTime(2024, 6, 20));
    });

    testWidgets('a disabled day (weekend) cannot start a range',
        (tester) async {
      DateTimeRange? range;
      await tester.pumpWidget(buildTestWidget(
        DrumDateRangePicker(
          firstDate: DateTime(2024, 6, 1),
          lastDate: DateTime(2024, 6, 30),
          currentDate: june,
          disabledWeekdays: const {DateTime.saturday, DateTime.sunday},
          onChanged: (r) => range = r,
        ),
        locale: const Locale('en'),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.text('16')); // Sunday
      await tester.tap(find.text('17')); // Monday
      await tester.pumpAndSettle();
      // The Sunday tap was ignored, so only the Monday start is set.
      expect(range, isNull);
    });
  });

  group('DrumDateRangePicker drum mode and toggle', () {
    testWidgets('drum mode shows Start and End wheels', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        DrumDateRangePicker(
          firstDate: DateTime(2024, 6, 1),
          lastDate: DateTime(2024, 6, 30),
          currentDate: june,
          initialMode: DrumRangeMode.drum,
          showModeToggle: false,
          onChanged: (_) {},
        ),
        locale: const Locale('en'),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Start'), findsOneWidget);
      expect(find.text('End'), findsOneWidget);
      // Two day/month/year wheel groups are present.
      expect(find.text('DAY'), findsNWidgets(2));
      expect(find.text('Calendar'), findsNothing); // toggle hidden
    });

    testWidgets('toggling to Drum yields a range and back to Calendar',
        (tester) async {
      DateTimeRange? range;
      await tester.pumpWidget(buildTestWidget(
        DrumDateRangePicker(
          firstDate: DateTime(2024, 6, 1),
          lastDate: DateTime(2024, 6, 30),
          currentDate: june, // 2024-06-15
          onChanged: (r) => range = r,
        ),
        locale: const Locale('en'),
      ));
      await tester.pumpAndSettle();
      // Starts on the calendar grid.
      expect(find.text('Start'), findsNothing);
      await tester.tap(find.text('Drum'));
      await tester.pumpAndSettle();
      expect(find.text('Start'), findsOneWidget);
      // Drum mode always has both ends, so a range is reported immediately.
      expect(range, isNotNull);
      expect(range!.start, DateTime(2024, 6, 15));
      expect(range!.end, DateTime(2024, 6, 15));
      // Back to the grid.
      await tester.tap(find.text('Calendar'));
      await tester.pumpAndSettle();
      expect(find.text('Start'), findsNothing);
      expect(find.text('15'), findsOneWidget); // a day cell
    });
  });

  group('DrumMultiDatePicker (inline)', () {
    testWidgets('tapping toggles days in and out of the set', (tester) async {
      List<DateTime> dates = const [];
      await tester.pumpWidget(buildTestWidget(
        DrumMultiDatePicker(
          firstDate: DateTime(2024, 6, 1),
          lastDate: DateTime(2024, 6, 30),
          currentDate: june,
          onChanged: (d) => dates = d,
        ),
        locale: const Locale('en'),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.text('3'));
      await tester.tap(find.text('9'));
      await tester.tap(find.text('21'));
      await tester.pumpAndSettle();
      expect(dates, [
        DateTime(2024, 6, 3),
        DateTime(2024, 6, 9),
        DateTime(2024, 6, 21),
      ]);
      // Tapping 9 again removes it.
      await tester.tap(find.text('9'));
      await tester.pumpAndSettle();
      expect(dates, [DateTime(2024, 6, 3), DateTime(2024, 6, 21)]);
    });
  });

  group('showDrumDateRangePicker (modal)', () {
    testWidgets('returns the selected range on Save', (tester) async {
      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      DateTimeRange? result;
      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () async {
                  result = await showDrumDateRangePicker(
                    context: context,
                    firstDate: DateTime(2024, 6, 1),
                    lastDate: DateTime(2024, 6, 30),
                    currentDate: june,
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
      await tester.tap(find.text('5'));
      await tester.tap(find.text('12'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(result, isNotNull);
      expect(result!.start, DateTime(2024, 6, 5));
      expect(result!.end, DateTime(2024, 6, 12));
    });

    testWidgets('Save is disabled until the range is complete', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => showDrumDateRangePicker(
                  context: context,
                  firstDate: DateTime(2024, 6, 1),
                  lastDate: DateTime(2024, 6, 30),
                  currentDate: june,
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      // Before any selection, the Save button is disabled.
      final save = tester.widget<TextButton>(
        find.ancestor(of: find.text('Save'), matching: find.byType(TextButton)),
      );
      expect(save.onPressed, isNull);
    });
  });

  group('showDrumMultiDatePicker (modal)', () {
    testWidgets('returns the selected days on Save', (tester) async {
      List<DateTime>? result;
      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () async {
                  result = await showDrumMultiDatePicker(
                    context: context,
                    firstDate: DateTime(2024, 6, 1),
                    lastDate: DateTime(2024, 6, 30),
                    currentDate: june,
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
      await tester.tap(find.text('2'));
      await tester.tap(find.text('14'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(result, [DateTime(2024, 6, 2), DateTime(2024, 6, 14)]);
    });
  });
}
