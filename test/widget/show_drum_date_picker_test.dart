import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_drum_picker/material_drum_picker.dart';

Widget _app(Widget child) {
  return MaterialApp(
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    supportedLocales: const [Locale('en')],
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets('returns the confirmed date when OK is tapped', (tester) async {
    DateTime? result;
    await tester.pumpWidget(_app(Builder(
      builder: (context) => ElevatedButton(
        onPressed: () async {
          result = await showDrumDatePicker(
            context: context,
            initialDate: DateTime(2024, 6, 15),
            currentDate: DateTime(2024, 6, 15),
            firstDate: DateTime(2024),
            lastDate: DateTime(2025),
          );
        },
        child: const Text('Open'),
      ),
    )));

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.byType(DrumPicker), findsOneWidget);

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(result, DateTime(2024, 6, 15));
  });

  testWidgets('returns null when cancelled', (tester) async {
    DateTime? result = DateTime(2000);
    var completed = false;
    await tester.pumpWidget(_app(Builder(
      builder: (context) => ElevatedButton(
        onPressed: () async {
          result = await showDrumDatePicker(
            context: context,
            initialDate: DateTime(2024, 6, 15),
            currentDate: DateTime(2024, 6, 15),
            firstDate: DateTime(2024),
            lastDate: DateTime(2025),
          );
          completed = true;
        },
        child: const Text('Open'),
      ),
    )));

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(completed, isTrue);
    expect(result, isNull);
  });

  testWidgets('barrierDismissible false keeps the dialog open', (tester) async {
    await tester.pumpWidget(_app(Builder(
      builder: (context) => ElevatedButton(
        onPressed: () => showDrumDatePicker(
          context: context,
          currentDate: DateTime(2024, 6, 15),
          firstDate: DateTime(1900),
          lastDate: DateTime(2100),
          barrierDismissible: false,
        ),
        child: const Text('Open'),
      ),
    )));

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(10, 10)); // tap the barrier
    await tester.pumpAndSettle();
    expect(find.byType(DrumPicker), findsOneWidget); // still open
  });

  testWidgets('custom confirm and cancel labels are shown', (tester) async {
    await tester.pumpWidget(_app(Builder(
      builder: (context) => ElevatedButton(
        onPressed: () => showDrumDatePicker(
          context: context,
          currentDate: DateTime(2024, 6, 15),
          firstDate: DateTime(1900),
          lastDate: DateTime(2100),
          confirmText: 'BOOK',
          cancelText: 'NOPE',
        ),
        child: const Text('Open'),
      ),
    )));

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('BOOK'), findsOneWidget);
    expect(find.text('NOPE'), findsOneWidget);
  });
}
