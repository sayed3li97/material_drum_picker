@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_drum_picker/material_drum_picker.dart';

void main() {
  testWidgets('drum picker — light theme golden', (tester) async {
    tester.view.physicalSize = const Size(440, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [Locale('en')],
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 360,
            child: DrumPicker(
              initialDate: DateTime(2024, 6, 15),
              currentDate: DateTime(2024, 6, 15),
              firstDate: DateTime(1900),
              lastDate: DateTime(2100),
              showActions: false,
            ),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(DrumPicker),
      matchesGoldenFile('goldens/drum_picker_light.png'),
    );
  });
}
