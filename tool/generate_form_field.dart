// Renders the DrumDateFormField screenshot into doc/screenshots/form_field.png.
// Run with:
//
//   flutter test tool/generate_form_field.dart
//
// Shows the field in a form: filled, empty with a hint, a validation error, and
// a Persian (Jalali) variant. Developer only tool, excluded from the package.
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
const _notoArabic =
    '/tmp/flutter/engine/src/flutter/txt/third_party/fonts/NotoNaskhArabic-Regular.ttf';

Future<ByteData> _read(String path) async =>
    ByteData.view(Uint8List.fromList(await File(path).readAsBytes()).buffer);

void main() {
  testWidgets('generate form field screenshot', (tester) async {
    await tester.runAsync(() async {
      final roboto = FontLoader('Roboto')
        ..addFont(_read(_robotoRegular))
        ..addFont(_read(_robotoMedium));
      await roboto.load();
      final persian = FontLoader('NotoArabic')..addFont(_read(_notoArabic));
      await persian.load();
      final icons = FontLoader('MaterialIcons')..addFont(_read(_materialIcons));
      await icons.load();
    });

    tester.view.physicalSize = const Size(760, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final key = GlobalKey();
    await tester.pumpWidget(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        fontFamilyFallback: const ['NotoArabic'],
        colorSchemeSeed: const Color(0xFF3949AB),
      ),
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [Locale('en'), Locale('fa')],
      home: RepaintBoundary(key: key, child: const _FormFieldShowcase()),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    await tester.runAsync(() async {
      final image = await boundary.toImage(pixelRatio: 2);
      final bytes = await image.toByteData(format: ImageByteFormat.png);
      final file = File('doc/screenshots/form_field.png');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes!.buffer.asUint8List());
      // ignore: avoid_print
      print('Wrote ${file.path} (${bytes.lengthInBytes ~/ 1024} KB)');
    });
  });
}

class _FormFieldShowcase extends StatelessWidget {
  const _FormFieldShowcase();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: const Color(0xFFEEF0FA),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Align(
          alignment: Alignment.topLeft,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('DrumDateFormField, a date field for Forms',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(
                'Tap to open the picker; validates and saves with Form, like TextFormField',
                style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: 420,
                child: Card(
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      autovalidateMode: AutovalidateMode.always,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DrumDateFormField(
                            initialValue: DateTime(1990, 6, 15),
                            firstDate: DateTime(1950),
                            lastDate: DateTime(2010),
                            decoration: const InputDecoration(
                              labelText: 'Date of birth',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.cake_outlined),
                            ),
                            locale: const Locale('en'),
                          ),
                          const SizedBox(height: 16),
                          DrumDateFormField(
                            firstDate: DateTime(2024),
                            lastDate: DateTime(2026),
                            hintText: 'Select a date',
                            decoration: const InputDecoration(
                              labelText: 'Start date',
                              border: OutlineInputBorder(),
                            ),
                            locale: const Locale('en'),
                          ),
                          const SizedBox(height: 16),
                          DrumDateFormField(
                            firstDate: DateTime(2024),
                            lastDate: DateTime(2026),
                            hintText: 'Required',
                            validator: (v) =>
                                v == null ? 'Please pick a date' : null,
                            decoration: const InputDecoration(
                              labelText: 'End date',
                              border: OutlineInputBorder(),
                            ),
                            locale: const Locale('en'),
                          ),
                          const SizedBox(height: 16),
                          DrumDateFormField(
                            initialValue: DateTime(2024, 3, 20),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2050),
                            calendar: DrumCalendarType.jalali,
                            decoration: const InputDecoration(
                              labelText: 'Persian date',
                              border: OutlineInputBorder(),
                            ),
                            locale: const Locale('fa'),
                          ),
                        ],
                      ),
                    ),
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
