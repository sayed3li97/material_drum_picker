// Renders the working days / holidays / first day of week screenshot into
// doc/screenshots/working_days.png. Run with:
//
//   flutter test tool/generate_working_days.dart
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

final DateTime _today = DateTime(2024, 6, 17); // a Monday

Future<ByteData> _load(String path) async =>
    ByteData.view(Uint8List.fromList(await File(path).readAsBytes()).buffer);

void main() {
  testWidgets('generate working days screenshot', (tester) async {
    await tester.runAsync(() async {
      final roboto = FontLoader('Roboto')
        ..addFont(_load(_robotoRegular))
        ..addFont(_load(_robotoMedium));
      await roboto.load();
      final icons = FontLoader('MaterialIcons')..addFont(_load(_materialIcons));
      await icons.load();
    });

    tester.view.physicalSize = const Size(760, 510);
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
      home: RepaintBoundary(key: key, child: const _WorkingDaysShowcase()),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    await tester.runAsync(() async {
      final image = await boundary.toImage(pixelRatio: 2);
      final bytes = await image.toByteData(format: ImageByteFormat.png);
      final file = File('doc/screenshots/working_days.png');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes!.buffer.asUint8List());
      // ignore: avoid_print
      print('Wrote ${file.path} (${bytes.lengthInBytes ~/ 1024} KB)');
    });
  });
}

class _WorkingDaysShowcase extends StatelessWidget {
  const _WorkingDaysShowcase();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: const Color(0xFFEEF2F8),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Align(
          alignment: Alignment.topLeft,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Working days, holidays, and the first day of week',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(
                'Weekends and the holiday on the 19th are disabled; the week '
                'starts on Monday',
                style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 340,
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  elevation: 3,
                  child: DrumPicker(
                    initialDate: _today,
                    currentDate: _today,
                    firstDate: DateTime(2024, 6, 1),
                    lastDate: DateTime(2024, 6, 30),
                    initialMode: DrumPickerMode.calendar,
                    showModeToggle: false,
                    showActions: false,
                    showQuickSelects: false,
                    disabledWeekdays: const {
                      DateTime.saturday,
                      DateTime.sunday
                    },
                    holidays: {DateTime(2024, 6, 19)},
                    firstDayOfWeek: DateTime.monday,
                    locale: const Locale('en'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
