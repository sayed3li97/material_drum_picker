// Renders a multi-panel showcase of the package and writes it to
// `doc/screenshots/showcase.png`. Run with:
//
//   flutter test tool/generate_showcase.dart
//
// It loads real fonts from the local Flutter SDK so the captured image shows
// crisp text instead of the placeholder boxes that `flutter_test` renders by
// default. The hardcoded font paths are intentional — this is a developer-only
// tool, not part of the published package or the test suite.
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' show ImageByteFormat;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart' show FontLoader;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_drum_picker/material_drum_picker.dart';

const _robotoRegular =
    '/tmp/flutter/engine/src/flutter/txt/third_party/fonts/Roboto-Regular.ttf';
const _robotoMedium =
    '/tmp/flutter/engine/src/flutter/txt/third_party/fonts/Roboto-Medium.ttf';
const _materialIcons =
    '/tmp/flutter/engine/src/flutter/tools/font_subset/fixtures/MaterialIcons-Regular.ttf';

Future<ByteData> _load(String path) async {
  final bytes = await File(path).readAsBytes();
  return ByteData.view(Uint8List.fromList(bytes).buffer);
}

bool _noWeekends(DateTime day) =>
    day.weekday != DateTime.saturday && day.weekday != DateTime.sunday;

final DateTime _today = DateTime(2024, 6, 15);

void main() {
  testWidgets('generate showcase screenshot', (tester) async {
    await _capture(
      tester,
      const Size(1660, 860),
      'doc/screenshots/showcase.png',
      _Showcase(),
    );
  });

  testWidgets('generate date+time screenshot', (tester) async {
    await _capture(
      tester,
      const Size(720, 820),
      'doc/screenshots/datetime.png',
      _DateTimeShowcase(),
    );
  });

  testWidgets('generate time-only screenshot', (tester) async {
    await _capture(
      tester,
      const Size(720, 560),
      'doc/screenshots/time.png',
      const _TimeShowcase(),
    );
  });
}

Future<void> _loadFonts(WidgetTester tester) async {
  // Font loading uses real File IO / async, which deadlocks in the test's
  // fake-async zone — do it inside runAsync.
  await tester.runAsync(() async {
    final roboto = FontLoader('Roboto')
      ..addFont(_load(_robotoRegular))
      ..addFont(_load(_robotoMedium));
    await roboto.load();
    final icons = FontLoader('MaterialIcons')..addFont(_load(_materialIcons));
    await icons.load();
  });
}

Future<void> _capture(
  WidgetTester tester,
  Size size,
  String path,
  Widget child,
) async {
  await _loadFonts(tester);

  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final boundaryKey = GlobalKey();

  await tester.pumpWidget(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      fontFamily: 'Roboto',
      colorSchemeSeed: Colors.indigo,
    ),
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    supportedLocales: const [Locale('en')],
    home: RepaintBoundary(key: boundaryKey, child: child),
  ));
  // Bounded pumps instead of pumpAndSettle: a focused TextField's blinking
  // cursor never settles, so pumpAndSettle would hang.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));

  final boundary =
      boundaryKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;

  // toImage/toByteData need real async, which deadlocks inside the test's
  // fake-async zone — run them via runAsync.
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 2);
    final bytes = await image.toByteData(format: ImageByteFormat.png);
    final file = File(path);
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes!.buffer.asUint8List());
    // ignore: avoid_print
    print('Wrote ${file.path} (${bytes.lengthInBytes ~/ 1024} KB)');
  });
}

class _Showcase extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: const Color(0xFFF1F1F8),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Align(
          alignment: Alignment.topLeft,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'material_drum_picker',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(
                'Material 3 + iOS-style drum roller · drum · calendar · input · date+time · dark',
                style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _panel('Drum mode', _drum(), false),
                  const SizedBox(width: 16),
                  _panel('Calendar mode', _calendar(), false),
                  const SizedBox(width: 16),
                  _panel('Input mode', _input(), false),
                  const SizedBox(width: 16),
                  _panel('Date + time', _dateTime(), false),
                  const SizedBox(width: 16),
                  _panel('Dark theme', _drum(), true),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _panel(String label, Widget picker, bool dark) {
    Widget card = Card(
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      child: picker,
    );
    if (dark) {
      // A Card is itself a Material, so a dark Theme is enough to recolor it.
      card = Theme(
        data: ThemeData(
          useMaterial3: true,
          fontFamily: 'Roboto',
          brightness: Brightness.dark,
          colorSchemeSeed: Colors.indigo,
        ),
        child: card,
      );
    }
    return SizedBox(
      width: 300,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 8),
          card,
        ],
      ),
    );
  }

  Widget _drum() => DrumPicker(
        initialDate: _today,
        currentDate: _today,
        firstDate: DateTime(1950),
        lastDate: DateTime(2035),
        initialMode: DrumPickerMode.drum,
        showModeToggle: false,
        showActions: false,
        showDayOfWeekInDrum: true,
        columnOrder: DrumColumnOrder.dmy,
        helpText: 'SELECT DATE',
      );

  Widget _calendar() => DrumPicker(
        initialDate: _today,
        currentDate: _today,
        firstDate: DateTime(2024, 1, 1),
        lastDate: DateTime(2024, 12, 31),
        initialMode: DrumPickerMode.calendar,
        showModeToggle: false,
        showActions: false,
        selectableDayPredicate: _noWeekends,
        helpText: 'SELECT DATE',
        quickSelectOptions: [
          DrumQuickSelect.relative(
              label: 'Today', offset: Duration.zero, referenceDate: _today),
          DrumQuickSelect.relative(
              label: 'Tomorrow',
              offset: const Duration(days: 1),
              referenceDate: _today),
          DrumQuickSelect.relative(
              label: 'Next week',
              offset: const Duration(days: 7),
              referenceDate: _today),
        ],
      );

  Widget _dateTime() => DrumPicker(
        initialDate: DateTime(2024, 6, 15, 14, 30),
        currentDate: _today,
        firstDate: DateTime(1950),
        lastDate: DateTime(2035),
        initialMode: DrumPickerMode.drum,
        showModeToggle: false,
        showActions: false,
        pickTime: true,
        use24hFormat: true,
        minuteInterval: 5,
        columnOrder: DrumColumnOrder.dmy,
        helpText: 'SELECT DATE & TIME',
      );

  Widget _input() => DrumPicker(
        initialDate: _today,
        currentDate: _today,
        firstDate: DateTime(1950),
        lastDate: DateTime(2035),
        initialMode: DrumPickerMode.input,
        showModeToggle: false,
        showActions: false,
        helpText: 'SELECT DATE',
        fieldLabelText: 'Enter Date',
      );
}

/// A focused two-panel close-up of the date + time picker (12- and 24-hour).
class _DateTimeShowcase extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: const Color(0xFFF1F1F8),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Align(
          alignment: Alignment.topLeft,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Date + time',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(
                'A drum date selector with an hour / minute (+ AM/PM) time strip',
                style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _panel('12-hour', use24h: false),
                  const SizedBox(width: 16),
                  _panel('24-hour, 5-min steps', use24h: true),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _panel(String label, {required bool use24h}) {
    return SizedBox(
      width: 300,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 8),
          Card(
            clipBehavior: Clip.antiAlias,
            elevation: 3,
            child: DrumPicker(
              initialDate: DateTime(2024, 6, 15, 14, 30),
              currentDate: _today,
              firstDate: DateTime(1950),
              lastDate: DateTime(2035),
              initialMode: DrumPickerMode.drum,
              showModeToggle: false,
              showActions: false,
              pickTime: true,
              use24hFormat: use24h,
              minuteInterval: use24h ? 5 : 1,
              columnOrder: DrumColumnOrder.dmy,
              helpText: 'SELECT DATE & TIME',
            ),
          ),
        ],
      ),
    );
  }
}

/// A focused two-panel close-up of the time-only picker (12- and 24-hour).
class _TimeShowcase extends StatelessWidget {
  const _TimeShowcase();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: const Color(0xFFF1F1F8),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Align(
          alignment: Alignment.topLeft,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Time only',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(
                'A standalone time picker, configurable for AM/PM or 24-hour',
                style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _panel('12-hour (AM/PM)', use24h: false),
                  const SizedBox(width: 16),
                  _panel('24-hour, 5-min steps', use24h: true),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _panel(String label, {required bool use24h}) {
    return SizedBox(
      width: 300,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 8),
          Card(
            clipBehavior: Clip.antiAlias,
            elevation: 3,
            child: DrumTimePicker(
              initialTime: const TimeOfDay(hour: 14, minute: 30),
              use24hFormat: use24h,
              minuteInterval: use24h ? 5 : 1,
              showActions: false,
            ),
          ),
        ],
      ),
    );
  }
}
