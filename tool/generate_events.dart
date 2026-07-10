// Renders the event marker screenshots into doc/screenshots/events.png. Run:
//
//   flutter test tool/generate_events.dart
//
// Shows the calendar grid used as a lightweight event calendar: default colored
// dots, and a custom markerBuilder badge. Developer only tool, excluded from the
// published package.
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

final DateTime _today = DateTime(2024, 6, 15);

// A small set of sample events keyed by day, with per event colors.
final Map<int, List<Color>> _events = {
  4: [const Color(0xFF1565C0)],
  10: [const Color(0xFF1565C0), const Color(0xFF2E7D32)],
  11: [const Color(0xFFC62828)],
  15: [
    const Color(0xFF1565C0),
    const Color(0xFF2E7D32),
    const Color(0xFFF9A825)
  ],
  18: [const Color(0xFF6A1B9A)],
  22: [const Color(0xFF2E7D32), const Color(0xFFC62828)],
  23: [const Color(0xFF1565C0)],
  27: [
    const Color(0xFF1565C0),
    const Color(0xFF2E7D32),
    const Color(0xFFC62828),
    const Color(0xFFF9A825),
    const Color(0xFF6A1B9A)
  ],
};

List<DrumEventMarker> _load(DateTime day) {
  if (day.year != 2024 || day.month != 6) return const [];
  return _events[day.day]
          ?.map((c) => DrumEventMarker(color: c))
          .toList(growable: false) ??
      const [];
}

Future<ByteData> _read(String path) async =>
    ByteData.view(Uint8List.fromList(await File(path).readAsBytes()).buffer);

void main() {
  testWidgets('generate events screenshot', (tester) async {
    await tester.runAsync(() async {
      final roboto = FontLoader('Roboto')
        ..addFont(_read(_robotoRegular))
        ..addFont(_read(_robotoMedium));
      await roboto.load();
      final icons = FontLoader('MaterialIcons')..addFont(_read(_materialIcons));
      await icons.load();
    });

    tester.view.physicalSize = const Size(820, 620);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final key = GlobalKey();
    await tester.pumpWidget(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        colorSchemeSeed: const Color(0xFF1565C0),
      ),
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [Locale('en')],
      home: RepaintBoundary(key: key, child: const _EventsShowcase()),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    await tester.runAsync(() async {
      final image = await boundary.toImage(pixelRatio: 2);
      final bytes = await image.toByteData(format: ImageByteFormat.png);
      final file = File('doc/screenshots/events.png');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes!.buffer.asUint8List());
      // ignore: avoid_print
      print('Wrote ${file.path} (${bytes.lengthInBytes ~/ 1024} KB)');
    });
  });
}

class _EventsShowcase extends StatelessWidget {
  const _EventsShowcase();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: const Color(0xFFEEF3FA),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Align(
          alignment: Alignment.topLeft,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Event markers in the calendar grid',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(
                'Return DrumEventMarker dots per day, or draw your own with markerBuilder',
                style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _panel('Colored dots (eventLoader)', _dots()),
                  const SizedBox(width: 16),
                  _panel('Custom badge (markerBuilder)', _badges()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _panel(String label, Widget card) => SizedBox(
        width: 340,
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
              child: Padding(padding: const EdgeInsets.all(4), child: card),
            ),
          ],
        ),
      );

  Widget _dots() => DrumCalendarDatePicker(
        initialDate: _today,
        currentDate: _today,
        firstDate: DateTime(2024, 6, 1),
        lastDate: DateTime(2024, 6, 30),
        onDateChanged: (_) {},
        eventLoader: _load,
        locale: const Locale('en'),
      );

  Widget _badges() => DrumCalendarDatePicker(
        initialDate: _today,
        currentDate: _today,
        firstDate: DateTime(2024, 6, 1),
        lastDate: DateTime(2024, 6, 30),
        onDateChanged: (_) {},
        eventLoader: _load,
        markerBuilder: (context, day, markers) => Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            margin: const EdgeInsets.only(bottom: 3),
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: const Color(0xFFC62828),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${markers.length}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
          ),
        ),
        locale: const Locale('en'),
      );
}
