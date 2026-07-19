import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_drum_picker/material_drum_picker.dart';

import '../helpers.dart';

void main() {
  testWidgets('drum shows the weekday sub-line without clipping the number',
      (tester) async {
    await tester.pumpWidget(buildTestWidget(
      DrumPicker(
        initialDate: DateTime(2024, 6, 15), // a Saturday
        currentDate: DateTime(2024, 6, 15),
        firstDate: DateTime(2020),
        lastDate: DateTime(2030),
        initialMode: DrumPickerMode.drum,
        showModeToggle: false,
        showActions: false,
        showDayOfWeekInDrum: true,
        locale: const Locale('en'),
      ),
      locale: const Locale('en'),
    ));
    await tester.pumpAndSettle();
    // The selected day number and its weekday sub-line both render.
    expect(find.text('15'), findsWidgets);
    expect(find.text('Sat'), findsWidgets);
  });

  testWidgets('the selected day chip casts a soft lift shadow', (tester) async {
    await tester.pumpWidget(buildTestWidget(
      DrumPicker(
        initialDate: DateTime(2024, 6, 15),
        currentDate: DateTime(2024, 6, 15),
        firstDate: DateTime(2020),
        lastDate: DateTime(2030),
        initialMode: DrumPickerMode.calendar,
        showModeToggle: false,
        showActions: false,
        locale: const Locale('en'),
      ),
      locale: const Locale('en'),
    ));
    await tester.pumpAndSettle();
    // Exactly one day (the selected one) settles with a filled chip that has
    // a shadow. Non-selected cells animate to a transparent, shadowless fill.
    final shadowed = find.byWidgetPredicate((w) =>
        w is DecoratedBox &&
        w.decoration is ShapeDecoration &&
        ((w.decoration as ShapeDecoration).shadows?.isNotEmpty ?? false));
    expect(shadowed, findsOneWidget);
  });

  testWidgets('numeric text styles use tabular figures', (tester) async {
    late DrumPickerResolved r;
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        r = DrumPickerTheme.resolve(context);
        return const SizedBox();
      }),
    ));
    bool hasTabular(TextStyle s) =>
        s.fontFeatures?.contains(const FontFeature.tabularFigures()) ?? false;
    expect(hasTabular(r.headlineTextStyle), isTrue);
    expect(hasTabular(r.selectedItemTextStyle), isTrue);
    expect(hasTabular(r.unselectedItemTextStyle), isTrue);
    expect(hasTabular(r.dayTextStyle), isTrue);
  });
}
