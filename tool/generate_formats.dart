// Renders the month-format and input-format screenshot into
// doc/screenshots/formats.png. Run with:
//
//   flutter test tool/generate_formats.dart
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

final DateTime _today = DateTime(2024, 6, 15);

Future<ByteData> _load(String path) async =>
    ByteData.view(Uint8List.fromList(await File(path).readAsBytes()).buffer);

void main() {
  testWidgets('generate formats screenshot', (tester) async {
    await tester.runAsync(() async {
      final roboto = FontLoader('Roboto')
        ..addFont(_load(_robotoRegular))
        ..addFont(_load(_robotoMedium));
      await roboto.load();
      final icons = FontLoader('MaterialIcons')..addFont(_load(_materialIcons));
      await icons.load();
    });

    tester.view.physicalSize = const Size(1080, 620);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final key = GlobalKey();
    await tester.pumpWidget(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        colorSchemeSeed: const Color(0xFF3F51B5),
      ),
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [Locale('en')],
      home: RepaintBoundary(key: key, child: const _FormatsShowcase()),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    await tester.runAsync(() async {
      final image = await boundary.toImage(pixelRatio: 2);
      final bytes = await image.toByteData(format: ImageByteFormat.png);
      final file = File('doc/screenshots/formats.png');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes!.buffer.asUint8List());
      // ignore: avoid_print
      print('Wrote ${file.path} (${bytes.lengthInBytes ~/ 1024} KB)');
    });
  });
}

class _FormatsShowcase extends StatelessWidget {
  const _FormatsShowcase();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: const Color(0xFFF1F2F7),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Align(
          alignment: Alignment.topLeft,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Month as name or number, and a custom typed format',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(
                'monthFormat switches the wheel between names and numbers; '
                'inputFormat controls the typed order, separator, and year width',
                style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _panel(
                      'Month as name (default)', _drum(DrumMonthFormat.name)),
                  const SizedBox(width: 16),
                  _panel('Month as number', _drum(DrumMonthFormat.numeric)),
                  const SizedBox(width: 16),
                  _panel('Typed input DD-MM-YYYY', _input()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _panel(String label, Widget card) => SizedBox(
        width: 320,
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

  Widget _drum(DrumMonthFormat monthFormat) => DrumPicker(
        initialDate: _today,
        currentDate: _today,
        firstDate: DateTime(2000),
        lastDate: DateTime(2050),
        monthFormat: monthFormat,
        columnOrder: DrumColumnOrder.dmy,
        showModeToggle: false,
        showActions: false,
        locale: const Locale('en'),
      );

  Widget _input() => DrumPicker(
        initialDate: _today,
        currentDate: _today,
        firstDate: DateTime(2000),
        lastDate: DateTime(2050),
        initialMode: DrumPickerMode.input,
        inputFormat: DrumDateFormat.parse('DD-MM-YYYY'),
        showModeToggle: false,
        showActions: false,
        locale: const Locale('en'),
      );
}
