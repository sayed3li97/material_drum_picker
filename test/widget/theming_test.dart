import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_drum_picker/material_drum_picker.dart';

import '../helpers.dart';

/// Resolves the effective tokens for a given ambient theme and optional per
/// instance override, by pumping a [Builder] and capturing the result.
Future<DrumPickerResolved> _resolve(
  WidgetTester tester, {
  ThemeData? theme,
  DrumPickerTheme? override,
}) async {
  late DrumPickerResolved resolved;
  await tester.pumpWidget(MaterialApp(
    theme: theme ?? ThemeData(useMaterial3: true),
    home: Builder(
      builder: (context) {
        resolved = DrumPickerTheme.resolve(context, override);
        return const SizedBox.shrink();
      },
    ),
  ));
  return resolved;
}

void main() {
  group('DrumPickerTheme.merge', () {
    test('non-null fields of other win, the rest are kept', () {
      const base = DrumPickerTheme(
        headerBackgroundColor: Color(0xFF000001),
        itemExtent: 40,
        visibleItemCount: 3,
      );
      const over = DrumPickerTheme(headerBackgroundColor: Color(0xFF000002));
      final merged = base.merge(over);
      expect(merged.headerBackgroundColor, const Color(0xFF000002));
      expect(merged.itemExtent, 40);
      expect(merged.visibleItemCount, 3);
    });

    test('merge(null) returns an equivalent theme', () {
      const base = DrumPickerTheme(itemExtent: 50);
      expect(base.merge(null).itemExtent, 50);
    });
  });

  group('DrumPickerTheme.resolve defaults', () {
    testWidgets('use the resolved default values', (tester) async {
      final r = await _resolve(tester);
      expect(r.itemExtent, 52.0);
      expect(r.visibleItemCount, 5);
      expect(r.selectorBandRadius, 12.0);
      expect(r.dayShape, isA<CircleBorder>());
      expect(r.headerPadding, const EdgeInsets.fromLTRB(24, 16, 24, 12));
      expect(r.helpTextStyle.fontSize, 12);
      expect(r.headlineTextStyle.fontSize, 30);
      expect(r.timeHeadlineTextStyle.fontSize, 34);
      expect(r.selectedItemTextStyle.fontSize, 19);
      expect(r.unselectedItemTextStyle.fontSize, 18);
      expect(r.columnLabelTextStyle.fontSize, 11);
    });

    testWidgets('colors derive from the ColorScheme', (tester) async {
      final theme = ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
      );
      final r = await _resolve(tester, theme: theme);
      expect(r.headerBackgroundColor, theme.colorScheme.primaryContainer);
      expect(r.selectedDayBackgroundColor, theme.colorScheme.primary);
      expect(r.selectedDayForegroundColor, theme.colorScheme.onPrimary);
      expect(r.todayColor, theme.colorScheme.primary);
    });
  });

  group('DrumPickerTheme.resolve precedence', () {
    testWidgets('per-instance override beats the ambient extension',
        (tester) async {
      final theme = ThemeData(
        useMaterial3: true,
        extensions: const [
          DrumPickerTheme(
            headerBackgroundColor: Color(0xFF111111),
            itemExtent: 50,
          ),
        ],
      );
      final r = await _resolve(
        tester,
        theme: theme,
        override:
            const DrumPickerTheme(headerBackgroundColor: Color(0xFF222222)),
      );
      // Override wins for the field it sets.
      expect(r.headerBackgroundColor, const Color(0xFF222222));
      // Ambient extension still applies where the override is null.
      expect(r.itemExtent, 50);
    });

    testWidgets('a text style override merges over the default',
        (tester) async {
      final r = await _resolve(
        tester,
        override: const DrumPickerTheme(
          headlineTextStyle: TextStyle(fontWeight: FontWeight.w700),
        ),
      );
      // The historic size is preserved, only the weight changes.
      expect(r.headlineTextStyle.fontSize, 30);
      expect(r.headlineTextStyle.fontWeight, FontWeight.w700);
    });

    testWidgets('a custom dayShape is resolved', (tester) async {
      final r = await _resolve(
        tester,
        override: const DrumPickerTheme(
          dayShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
      );
      expect(r.dayShape, isA<RoundedRectangleBorder>());
    });
  });

  group('per-instance theme reaches the widget tree', () {
    testWidgets('header uses the overridden background color', (tester) async {
      const headerColor = Color(0xFF654321);
      await tester.pumpWidget(buildTestWidget(
        DrumPicker(
          initialDate: DateTime(2024, 6, 15),
          currentDate: DateTime(2024, 6, 15),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          showActions: false,
          theme: const DrumPickerTheme(headerBackgroundColor: headerColor),
        ),
      ));
      await tester.pumpAndSettle();
      final found = find.byWidgetPredicate(
        (w) =>
            w is Container &&
            w.decoration is BoxDecoration &&
            (w.decoration! as BoxDecoration).color == headerColor,
      );
      expect(found, findsOneWidget);
    });
  });

  group('DrumPickerLabels', () {
    testWidgets('override the drum column and mode tab strings',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(
        DrumPicker(
          initialDate: DateTime(2024, 6, 15),
          currentDate: DateTime(2024, 6, 15),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          showActions: false,
          labels: const DrumPickerLabels(
            dayColumn: 'JOUR',
            calendarMode: 'Cal',
            drumMode: 'Molette',
            inputMode: 'Saisie',
          ),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text('JOUR'), findsOneWidget);
      expect(find.text('DAY'), findsNothing);
      expect(find.text('Molette'), findsWidgets);
    });

    testWidgets('override the time strip column headers', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        DrumPicker(
          initialDate: DateTime(2024, 6, 15),
          currentDate: DateTime(2024, 6, 15),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          pickTime: true,
          use24hFormat: true,
          showActions: false,
          labels: const DrumPickerLabels(hourColumn: 'HR', minuteColumn: 'MN'),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text('HR'), findsOneWidget);
      expect(find.text('MN'), findsOneWidget);
    });
  });

  group('a fully customized picker renders', () {
    testWidgets('drum and calendar modes pump with no exception',
        (tester) async {
      const custom = DrumPickerTheme(
        headerBackgroundColor: Color(0xFF004D40),
        headerTextColor: Colors.white,
        selectedDayBackgroundColor: Colors.deepOrange,
        selectedDayForegroundColor: Colors.white,
        todayColor: Colors.deepOrange,
        dayShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        selectorBandRadius: 16,
        itemExtent: 48,
        visibleItemCount: 3,
        headlineTextStyle: TextStyle(fontWeight: FontWeight.w800),
      );
      await tester.pumpWidget(buildTestWidget(
        DrumPicker(
          initialDate: DateTime(2024, 6, 15),
          currentDate: DateTime(2024, 6, 15),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          initialMode: DrumPickerMode.calendar,
          showActions: false,
          theme: custom,
        ),
      ));
      await tester.pumpAndSettle();
      // The selected day (15) is present and the grid built with the custom
      // shape without throwing.
      expect(find.text('15'), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  });
}
