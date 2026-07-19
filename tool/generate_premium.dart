// Renders the premium showcase (drum + calendar, light + dark) into
// doc/screenshots/premium.png. Run with:
//
//   flutter test tool/generate_premium.dart
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
    '/tmp/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf';

final DateTime _today = DateTime(2024, 6, 15);

Future<ByteData> _read(String path) async =>
    ByteData.view(Uint8List.fromList(await File(path).readAsBytes()).buffer);

void main() {
  testWidgets('generate premium screenshot', (tester) async {
    await tester.runAsync(() async {
      final roboto = FontLoader('Roboto')
        ..addFont(_read(_robotoRegular))
        ..addFont(_read(_robotoMedium));
      await roboto.load();
      final icons = FontLoader('MaterialIcons')..addFont(_read(_materialIcons));
      await icons.load();
    });

    tester.view.physicalSize = const Size(860, 1060);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final key = GlobalKey();
    await tester.pumpWidget(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, fontFamily: 'Roboto'),
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [Locale('en')],
      home: RepaintBoundary(key: key, child: const _PremiumShowcase()),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    await tester.runAsync(() async {
      final image = await boundary.toImage(pixelRatio: 2);
      final bytes = await image.toByteData(format: ImageByteFormat.png);
      final file = File('doc/screenshots/premium.png');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes!.buffer.asUint8List());
      // ignore: avoid_print
      print('Wrote ${file.path} (${bytes.lengthInBytes ~/ 1024} KB)');
    });
  });
}

class _PremiumShowcase extends StatelessWidget {
  const _PremiumShowcase();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _themed(Brightness.light),
        _themed(Brightness.dark),
      ],
    );
  }

  Widget _themed(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF3457D5),
      brightness: brightness,
    );
    return Theme(
      data: ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        fontFamily: 'Roboto',
      ),
      child: Container(
        width: 430,
        height: 1060,
        color: scheme.surface,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              clipBehavior: Clip.antiAlias,
              child: DrumPicker(
                initialDate: _today,
                currentDate: _today,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
                showModeToggle: false,
                showActions: false,
                showDayOfWeekInDrum: true,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              clipBehavior: Clip.antiAlias,
              child: DrumPicker(
                initialDate: _today,
                currentDate: _today,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
                initialMode: DrumPickerMode.calendar,
                showModeToggle: false,
                showActions: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
