import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_drum_picker/material_drum_picker.dart';

import '../helpers.dart';

void main() {
  group('DrumMonthFormat', () {
    testWidgets('numeric shows the month number, not its name', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        DrumPicker(
          initialDate: DateTime(2024, 6, 15),
          currentDate: DateTime(2024, 6, 15),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          monthFormat: DrumMonthFormat.numeric,
          showActions: false,
          locale: const Locale('en'),
        ),
        locale: const Locale('en'),
      ));
      await tester.pumpAndSettle();
      // June renders as 06 on the wheel. The exact wheel label 'Jun' is gone
      // (the headline still reads 'Sat, Jun 15', which is not an exact match).
      expect(find.text('06'), findsWidgets);
      expect(find.text('Jun'), findsNothing);
    });

    testWidgets('name (default) still shows the month name', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        DrumPicker(
          initialDate: DateTime(2024, 6, 15),
          currentDate: DateTime(2024, 6, 15),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          showActions: false,
          locale: const Locale('en'),
        ),
        locale: const Locale('en'),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Jun'), findsWidgets);
    });
  });

  group('inputFormat', () {
    testWidgets('DD-MM-YYYY formats the initial value and parses input',
        (tester) async {
      DateTime? changed;
      await tester.pumpWidget(buildTestWidget(
        DrumPicker(
          initialDate: DateTime(2024, 6, 15),
          currentDate: DateTime(2024, 6, 15),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          initialMode: DrumPickerMode.input,
          showModeToggle: false,
          showActions: false,
          inputFormat: DrumDateFormat.parse('DD-MM-YYYY'),
          onChanged: (d) => changed = d,
          locale: const Locale('en'),
        ),
        locale: const Locale('en'),
      ));
      await tester.pumpAndSettle();
      expect(find.text('15-06-2024'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '20-06-2024');
      await tester.pumpAndSettle();
      expect(changed, DateTime(2024, 6, 20));
    });

    testWidgets('a two digit year resolves into the supported range',
        (tester) async {
      DateTime? changed;
      await tester.pumpWidget(buildTestWidget(
        DrumPicker(
          initialDate: DateTime(2024, 6, 15),
          currentDate: DateTime(2024, 6, 15),
          firstDate: DateTime(2000),
          lastDate: DateTime(2049),
          initialMode: DrumPickerMode.input,
          showModeToggle: false,
          showActions: false,
          inputFormat: DrumDateFormat.parse('MM/DD/YY'),
          onChanged: (d) => changed = d,
          locale: const Locale('en'),
        ),
        locale: const Locale('en'),
      ));
      await tester.pumpAndSettle();
      // 2024 renders with a two digit year.
      expect(find.text('06/15/24'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '06/15/30');
      await tester.pumpAndSettle();
      expect(changed, DateTime(2030, 6, 15));
    });

    testWidgets('the default format is unchanged (MM/DD/YYYY)', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        DrumPicker(
          initialDate: DateTime(2024, 6, 15),
          currentDate: DateTime(2024, 6, 15),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          initialMode: DrumPickerMode.input,
          showModeToggle: false,
          showActions: false,
          locale: const Locale('en'),
        ),
        locale: const Locale('en'),
      ));
      await tester.pumpAndSettle();
      expect(find.text('06/15/2024'), findsOneWidget);
    });
  });
}
