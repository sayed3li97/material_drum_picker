// Renders the range / multi selection screenshot into doc/screenshots/range.png.
// Run with:
//
//   flutter test tool/generate_range.dart
//
// Developer only tool, excluded from the published package.
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

final DateTime _today = DateTime(2024, 6, 13);
final _range = DateTimeRange(
  start: DateTime(2024, 6, 10),
  end: DateTime(2024, 6, 18),
);

Future<ByteData> _load(String path) async =>
    ByteData.view(Uint8List.fromList(await File(path).readAsBytes()).buffer);

void main() {
  testWidgets('generate range screenshot', (tester) async {
    await tester.runAsync(() async {
      final roboto = FontLoader('Roboto')
        ..addFont(_load(_robotoRegular))
        ..addFont(_load(_robotoMedium));
      await roboto.load();
      final icons = FontLoader('MaterialIcons')..addFont(_load(_materialIcons));
      await icons.load();
    });

    tester.view.physicalSize = const Size(1180, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final key = GlobalKey();
    await tester.pumpWidget(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        colorSchemeSeed: const Color(0xFF6A1B9A),
      ),
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [Locale('en')],
      home: RepaintBoundary(key: key, child: const _RangeShowcase()),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    await tester.runAsync(() async {
      final image = await boundary.toImage(pixelRatio: 2);
      final bytes = await image.toByteData(format: ImageByteFormat.png);
      final file = File('doc/screenshots/range.png');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes!.buffer.asUint8List());
      // ignore: avoid_print
      print('Wrote ${file.path} (${bytes.lengthInBytes ~/ 1024} KB)');
    });
  });
}

class _RangeShowcase extends StatelessWidget {
  const _RangeShowcase();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: const Color(0xFFF4EEF6),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Align(
          alignment: Alignment.topLeft,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Date range (calendar or drum) and multiple dates',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(
                'The range picker offers a calendar grid and a two-wheel drum, '
                'switchable with the toggle. Multiple dates pick any set of days.',
                style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _panel(
                    'Range, calendar',
                    DrumDateRangePicker(
                      firstDate: DateTime(2024, 6, 1),
                      lastDate: DateTime(2024, 6, 30),
                      currentDate: _today,
                      initialDateRange: _range,
                      onChanged: (_) {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  _panel(
                    'Range, drum',
                    DrumDateRangePicker(
                      firstDate: DateTime(2020, 1, 1),
                      lastDate: DateTime(2030, 12, 31),
                      currentDate: _today,
                      initialDateRange: _range,
                      initialMode: DrumRangeMode.drum,
                      onChanged: (_) {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  _panel(
                    'Multiple dates',
                    DrumMultiDatePicker(
                      firstDate: DateTime(2024, 6, 1),
                      lastDate: DateTime(2024, 6, 30),
                      currentDate: _today,
                      initialDates: [
                        DateTime(2024, 6, 4),
                        DateTime(2024, 6, 11),
                        DateTime(2024, 6, 19),
                        DateTime(2024, 6, 26),
                      ],
                      onChanged: (_) {},
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _panel(String label, Widget child) => SizedBox(
        width: 356,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 8),
            Card(clipBehavior: Clip.antiAlias, elevation: 3, child: child),
          ],
        ),
      );
}
