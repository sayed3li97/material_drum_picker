import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_drum_picker/material_drum_picker.dart';
import 'package:material_drum_picker/src/widgets/internal/drum_column.dart';
import 'package:material_drum_picker/src/widgets/internal/time_strip.dart';

import '../helpers.dart';

Widget _app(Widget child, {bool use24h = false}) {
  return MaterialApp(
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    supportedLocales: const [Locale('en')],
    home: MediaQuery(
      data: MediaQueryData(alwaysUse24HourFormat: use24h),
      child: Scaffold(body: child),
    ),
  );
}

void main() {
  testWidgets('time-only picker shows a time strip and no date columns',
      (tester) async {
    await tester.pumpWidget(buildTestWidget(const DrumTimePicker(
      initialTime: TimeOfDay(hour: 9, minute: 30),
      use24hFormat: false,
    )));
    await tester.pumpAndSettle();

    expect(find.byType(TimeStrip), findsOneWidget);
    expect(find.text('HOUR'), findsOneWidget);
    expect(find.text('MIN'), findsOneWidget);
    expect(find.text('AM/PM'), findsOneWidget);
    // No date columns.
    expect(find.text('DAY'), findsNothing);
    expect(find.text('MONTH'), findsNothing);
    expect(find.text('YEAR'), findsNothing);
  });

  testWidgets('24-hour mode hides the AM/PM column', (tester) async {
    await tester.pumpWidget(buildTestWidget(const DrumTimePicker(
      initialTime: TimeOfDay(hour: 14, minute: 0),
      use24hFormat: true,
    )));
    await tester.pumpAndSettle();
    expect(find.text('AM/PM'), findsNothing);
    expect(find.text('14:00'), findsOneWidget);
  });

  testWidgets('12-hour mode shows AM/PM in the header', (tester) async {
    await tester.pumpWidget(buildTestWidget(const DrumTimePicker(
      initialTime: TimeOfDay(hour: 14, minute: 30),
      use24hFormat: false,
    )));
    await tester.pumpAndSettle();
    // CLDR may use a narrow no-break space before the meridiem, so match
    // the parts rather than a literal space.
    expect(find.textContaining('2:30'), findsOneWidget);
    expect(find.textContaining('PM'), findsWidgets);
  });

  testWidgets('use24hFormat follows MediaQuery when null', (tester) async {
    await tester.pumpWidget(_app(
      const DrumTimePicker(initialTime: TimeOfDay(hour: 8, minute: 15)),
      use24h: true,
    ));
    await tester.pumpAndSettle();
    expect(find.text('AM/PM'), findsNothing);
    expect(find.text('08:15'), findsOneWidget);
  });

  testWidgets('minuteInterval controls the minute column count',
      (tester) async {
    await tester.pumpWidget(buildTestWidget(const DrumTimePicker(
      initialTime: TimeOfDay(hour: 9, minute: 0),
      use24hFormat: true,
      minuteInterval: 15,
    )));
    await tester.pumpAndSettle();
    final minuteCol = tester.widget<DrumColumn>(
      find.byWidgetPredicate((w) => w is DrumColumn && w.label == 'MIN'),
    );
    expect(minuteCol.itemCount, 4);
  });

  testWidgets('initial minute is snapped to the interval', (tester) async {
    TimeOfDay? confirmed;
    await tester.pumpWidget(buildTestWidget(DrumTimePicker(
      initialTime: const TimeOfDay(hour: 9, minute: 37),
      use24hFormat: true,
      minuteInterval: 15,
      onConfirmed: (t) => confirmed = t,
    )));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('OK'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(confirmed, const TimeOfDay(hour: 9, minute: 30));
  });

  testWidgets('showActions false hides the buttons', (tester) async {
    await tester.pumpWidget(buildTestWidget(const DrumTimePicker(
      initialTime: TimeOfDay(hour: 9, minute: 0),
      showActions: false,
    )));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextButton, 'OK'), findsNothing);
  });

  testWidgets('showDrumTimePicker returns the confirmed time', (tester) async {
    TimeOfDay? result;
    await tester.pumpWidget(_app(Builder(
      builder: (context) => ElevatedButton(
        onPressed: () async {
          result = await showDrumTimePicker(
            context: context,
            initialTime: const TimeOfDay(hour: 16, minute: 45),
            use24hFormat: true,
          );
        },
        child: const Text('Open'),
      ),
    )));

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.byType(DrumTimePicker), findsOneWidget);
    await tester.ensureVisible(find.text('OK'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(result, const TimeOfDay(hour: 16, minute: 45));
  });

  testWidgets('showDrumTimePicker returns null on cancel', (tester) async {
    TimeOfDay? result = const TimeOfDay(hour: 0, minute: 0);
    var completed = false;
    await tester.pumpWidget(_app(Builder(
      builder: (context) => ElevatedButton(
        onPressed: () async {
          result = await showDrumTimePicker(
            context: context,
            initialTime: const TimeOfDay(hour: 16, minute: 45),
          );
          completed = true;
        },
        child: const Text('Open'),
      ),
    )));

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Cancel'));
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(completed, isTrue);
    expect(result, isNull);
  });
}
