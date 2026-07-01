// Renders Persian Solar Hijri (Jalali) screenshots, including a Persian right to
// left layout, into doc/screenshots/jalali.png. Run with:
//
//   flutter test tool/generate_jalali.dart
//
// Loads real Latin and Arabic-script (Persian) fonts so the captured image
// shows crisp text. Developer only tool, excluded from the published package.
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
const _notoArabic =
    '/tmp/flutter/engine/src/flutter/txt/third_party/fonts/NotoNaskhArabic-Regular.ttf';

final DateTime _today = DateTime(2024, 6, 15); // around 1403 Khordad 26

Future<ByteData> _load(String path) async =>
    ByteData.view(Uint8List.fromList(await File(path).readAsBytes()).buffer);

void main() {
  testWidgets('generate jalali screenshot', (tester) async {
    await tester.runAsync(() async {
      final roboto = FontLoader('Roboto')
        ..addFont(_load(_robotoRegular))
        ..addFont(_load(_robotoMedium));
      await roboto.load();
      final persian = FontLoader('NotoArabic')..addFont(_load(_notoArabic));
      await persian.load();
      final icons = FontLoader('MaterialIcons')..addFont(_load(_materialIcons));
      await icons.load();
    });

    tester.view.physicalSize = const Size(1080, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final key = GlobalKey();
    await tester.pumpWidget(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        fontFamilyFallback: const ['NotoArabic'],
        colorSchemeSeed: const Color(0xFF1565C0),
      ),
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [Locale('en'), Locale('fa')],
      home: RepaintBoundary(key: key, child: const _JalaliShowcase()),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    await tester.runAsync(() async {
      final image = await boundary.toImage(pixelRatio: 2);
      final bytes = await image.toByteData(format: ImageByteFormat.png);
      final file = File('doc/screenshots/jalali.png');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes!.buffer.asUint8List());
      // ignore: avoid_print
      print('Wrote ${file.path} (${bytes.lengthInBytes ~/ 1024} KB)');
    });
  });
}

class _JalaliShowcase extends StatelessWidget {
  const _JalaliShowcase();

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
              const Text('Persian Solar Hijri (Jalali), with Persian layout',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(
                'Persian month names and digits, Saturday first week, right to left, Gregorian shown alongside',
                style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _panel('Drum mode (fa)', _fa(_drum())),
                  const SizedBox(width: 16),
                  _panel('Calendar mode (fa)', _fa(_calendar())),
                  const SizedBox(width: 16),
                  _panel('English Jalali', _english(_drumEn())),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Wraps a picker in Persian localizations and right to left direction.
  Widget _fa(Widget child) => Builder(
        builder: (context) => Localizations.override(
          context: context,
          locale: const Locale('fa'),
          child: Directionality(textDirection: TextDirection.rtl, child: child),
        ),
      );

  Widget _english(Widget child) => Builder(
        builder: (context) => Localizations.override(
          context: context,
          locale: const Locale('en'),
          child: child,
        ),
      );

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

  Widget _drum() => DrumPicker(
        initialDate: _today,
        currentDate: _today,
        firstDate: DateTime(2000),
        lastDate: DateTime(2050),
        calendar: DrumCalendarType.jalali,
        locale: const Locale('fa'),
        textDirection: TextDirection.rtl,
        columnOrder: DrumColumnOrder.dmy,
        showDayOfWeekInDrum: true,
        showGregorianAlongside: true,
        showModeToggle: false,
        showActions: false,
        helpText: 'انتخاب تاریخ',
      );

  Widget _calendar() => DrumPicker(
        initialDate: _today,
        currentDate: _today,
        firstDate: DateTime(2000),
        lastDate: DateTime(2050),
        calendar: DrumCalendarType.jalali,
        locale: const Locale('fa'),
        textDirection: TextDirection.rtl,
        initialMode: DrumPickerMode.calendar,
        showModeToggle: false,
        showActions: false,
        helpText: 'انتخاب تاریخ',
      );

  Widget _drumEn() => DrumPicker(
        initialDate: _today,
        currentDate: _today,
        firstDate: DateTime(2000),
        lastDate: DateTime(2050),
        calendar: DrumCalendarType.jalali,
        locale: const Locale('en'),
        showGregorianAlongside: true,
        showModeToggle: false,
        showActions: false,
        helpText: 'SELECT DATE',
      );
}
