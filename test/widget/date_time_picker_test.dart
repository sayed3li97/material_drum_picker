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
  testWidgets('pickTime shows the time strip with hour/min/AM-PM in 12h',
      (tester) async {
    await tester.pumpWidget(buildTestWidget(DrumPicker(
      initialDate: DateTime(2024, 6, 15, 9, 30),
      currentDate: DateTime(2024, 6, 15),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      pickTime: true,
      use24hFormat: false,
    )));
    await tester.pumpAndSettle();

    expect(find.byType(TimeStrip), findsOneWidget);
    expect(find.text('HOUR'), findsOneWidget);
    expect(find.text('MIN'), findsOneWidget);
    expect(find.text('AM/PM'), findsOneWidget);
  });

  testWidgets('24h format hides the AM/PM column', (tester) async {
    await tester.pumpWidget(buildTestWidget(DrumPicker(
      initialDate: DateTime(2024, 6, 15, 9, 30),
      currentDate: DateTime(2024, 6, 15),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      pickTime: true,
      use24hFormat: true,
    )));
    await tester.pumpAndSettle();

    expect(find.text('HOUR'), findsOneWidget);
    expect(find.text('MIN'), findsOneWidget);
    expect(find.text('AM/PM'), findsNothing);
  });

  testWidgets('without pickTime there is no time strip', (tester) async {
    await tester.pumpWidget(buildTestWidget(DrumPicker(
      initialDate: DateTime(2024, 6, 15),
      currentDate: DateTime(2024, 6, 15),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    )));
    await tester.pumpAndSettle();
    expect(find.byType(TimeStrip), findsNothing);
  });

  testWidgets('minuteInterval controls the minute column count',
      (tester) async {
    await tester.pumpWidget(buildTestWidget(DrumPicker(
      initialDate: DateTime(2024, 6, 15, 9, 0),
      currentDate: DateTime(2024, 6, 15),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      pickTime: true,
      use24hFormat: true,
      minuteInterval: 15,
    )));
    await tester.pumpAndSettle();

    final minuteCol = tester.widget<DrumColumn>(
      find.byWidgetPredicate(
        (w) => w is DrumColumn && w.label == 'MIN',
      ),
    );
    expect(minuteCol.itemCount, 4); // 0, 15, 30, 45
  });

  testWidgets('showDrumDateTimePicker returns the date with time',
      (tester) async {
    DateTime? result;
    await tester.pumpWidget(_app(
      Builder(
        builder: (context) => ElevatedButton(
          onPressed: () async {
            result = await showDrumDateTimePicker(
              context: context,
              initialDate: DateTime(2024, 6, 15, 14, 30),
              currentDate: DateTime(2024, 6, 15),
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
              use24hFormat: true,
            );
          },
          child: const Text('Open'),
        ),
      ),
    ));

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('OK'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(result, DateTime(2024, 6, 15, 14, 30));
  });

  testWidgets('initial minute is snapped to the interval', (tester) async {
    DateTime? changed;
    await tester.pumpWidget(buildTestWidget(DrumPicker(
      initialDate: DateTime(2024, 6, 15, 9, 37),
      currentDate: DateTime(2024, 6, 15),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      pickTime: true,
      use24hFormat: true,
      minuteInterval: 15,
      onConfirmed: (d) => changed = d,
    )));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('OK'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    // 37 snaps down to 30.
    expect(changed, DateTime(2024, 6, 15, 9, 30));
  });
}
