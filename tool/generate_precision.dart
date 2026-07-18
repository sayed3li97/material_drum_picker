// Renders the month/year precision screenshots into doc/screenshots/precision.png.
// Run with:
//
//   flutter test tool/generate_precision.dart
//
// Shows month precision on the drum and the calendar month chooser, and year
// precision on the year chooser. Developer only tool, excluded from the package.
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

Future<ByteData> _read(String path) async =>
    ByteData.view(Uint8List.fromList(await File(path).readAsBytes()).buffer);

void main() {
  testWidgets('generate precision screenshot', (tester) async {
    await tester.runAsync(() async {
      final roboto = FontLoader('Roboto')
        ..addFont(_read(_robotoRegular))
        ..addFont(_read(_robotoMedium));
      await roboto.load();
      final icons = FontLoader('MaterialIcons')..addFont(_read(_materialIcons));
      await icons.load();
    });

    tester.view.physicalSize = const Size(1160, 620);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final key = GlobalKey();
    await tester.pumpWidget(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        colorSchemeSeed: const Color(0xFF6750A4),
      ),
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [Locale('en')],
      home: RepaintBoundary(key: key, child: const _PrecisionShowcase()),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    await tester.runAsync(() async {
      final image = await boundary.toImage(pixelRatio: 2);
      final bytes = await image.toByteData(format: ImageByteFormat.png);
      final file = File('doc/screenshots/precision.png');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes!.buffer.asUint8List());
      // ignore: avoid_print
      print('Wrote ${file.path} (${bytes.lengthInBytes ~/ 1024} KB)');
    });
  });
}

class _PrecisionShowcase extends StatelessWidget {
  const _PrecisionShowcase();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: const Color(0xFFF3EFFA),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Align(
          alignment: Alignment.topLeft,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Month and year precision',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(
                'One precision flag turns the picker into a month/year or year selector, on the drum or the calendar',
                style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _panel('Month drum', _monthDrum()),
                  const SizedBox(width: 16),
                  _panel('Month calendar', _monthCalendar()),
                  const SizedBox(width: 16),
                  _panel('Year calendar', _yearCalendar()),
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
            Card(clipBehavior: Clip.antiAlias, elevation: 3, child: card),
          ],
        ),
      );

  Widget _monthDrum() => DrumPicker(
        initialDate: _today,
        currentDate: _today,
        firstDate: DateTime(2020),
        lastDate: DateTime(2030, 12),
        precision: DrumPrecision.month,
        showModeToggle: false,
        showActions: false,
        helpText: 'EXPIRY MONTH',
        locale: const Locale('en'),
      );

  Widget _monthCalendar() => DrumPicker(
        initialDate: _today,
        currentDate: _today,
        firstDate: DateTime(2020),
        lastDate: DateTime(2030, 12),
        precision: DrumPrecision.month,
        initialMode: DrumPickerMode.calendar,
        showModeToggle: false,
        showActions: false,
        helpText: 'EXPIRY MONTH',
        locale: const Locale('en'),
      );

  Widget _yearCalendar() => DrumPicker(
        initialDate: _today,
        currentDate: _today,
        firstDate: DateTime(2015),
        lastDate: DateTime(2030),
        precision: DrumPrecision.year,
        initialMode: DrumPickerMode.calendar,
        showModeToggle: false,
        showActions: false,
        helpText: 'BIRTH YEAR',
        locale: const Locale('en'),
      );
}
