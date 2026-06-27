// Renders the Chinese lunisolar calendar screenshot into
// doc/screenshots/chinese.png. Run with:
//
//   flutter test tool/generate_chinese.dart
//
// Loads a CJK font so the captured image shows the Chinese month and year
// names. Developer only tool, excluded from the published package.
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
const _cjk = '/usr/share/fonts/truetype/wqy/wqy-zenhei.ttc';

// 2023-03-22 is the first day of the leap month 2 (闰二月) of lunar year 2023.
final DateTime _today = DateTime(2023, 3, 22);

Future<ByteData> _load(String path) async =>
    ByteData.view(Uint8List.fromList(await File(path).readAsBytes()).buffer);

void main() {
  testWidgets('generate chinese screenshot', (tester) async {
    await tester.runAsync(() async {
      final roboto = FontLoader('Roboto')
        ..addFont(_load(_robotoRegular))
        ..addFont(_load(_robotoMedium));
      await roboto.load();
      final cjk = FontLoader('WenQuanYi')..addFont(_load(_cjk));
      await cjk.load();
      final icons = FontLoader('MaterialIcons')..addFont(_load(_materialIcons));
      await icons.load();
    });

    tester.view.physicalSize = const Size(1080, 680);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final key = GlobalKey();
    await tester.pumpWidget(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        fontFamilyFallback: const ['WenQuanYi'],
        colorSchemeSeed: const Color(0xFFB71C1C),
      ),
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [Locale('en'), Locale('zh')],
      home: RepaintBoundary(key: key, child: const _ChineseShowcase()),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    await tester.runAsync(() async {
      final image = await boundary.toImage(pixelRatio: 2);
      final bytes = await image.toByteData(format: ImageByteFormat.png);
      final file = File('doc/screenshots/chinese.png');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes!.buffer.asUint8List());
      // ignore: avoid_print
      print('Wrote ${file.path} (${bytes.lengthInBytes ~/ 1024} KB)');
    });
  });
}

class _ChineseShowcase extends StatelessWidget {
  const _ChineseShowcase();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: const Color(0xFFF6F1F1),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Align(
          alignment: Alignment.topLeft,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Chinese lunisolar calendar with leap months',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(
                'Showing leap month 2 of 2023 (闰二月). 13 months this year, '
                'traditional names, and the sexagenary year 癸卯 (Rabbit)',
                style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _panel('Drum mode (zh)', _drum(const Locale('zh'))),
                  const SizedBox(width: 16),
                  _panel('Calendar mode (zh)', _calendar(const Locale('zh'))),
                  const SizedBox(width: 16),
                  _panel('English', _drum(const Locale('en'))),
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

  Widget _drum(Locale locale) => DrumPicker(
        initialDate: _today,
        currentDate: _today,
        firstDate: DateTime(2000),
        lastDate: DateTime(2050),
        calendar: DrumCalendarType.chinese,
        locale: locale,
        showModeToggle: false,
        showActions: false,
      );

  Widget _calendar(Locale locale) => DrumPicker(
        initialDate: _today,
        currentDate: _today,
        firstDate: DateTime(2000),
        lastDate: DateTime(2050),
        calendar: DrumCalendarType.chinese,
        initialMode: DrumPickerMode.calendar,
        locale: locale,
        showModeToggle: false,
        showActions: false,
      );
}
