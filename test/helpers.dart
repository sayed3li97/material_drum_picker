import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// A fixed reference date used across tests for deterministic behavior.
/// June 15 2024 is a Saturday.
final DateTime kTestDate = DateTime(2024, 6, 15);

/// Wraps [child] in a localized [MaterialApp] suitable for widget tests.
///
/// The picker relies on [MaterialLocalizations] and `intl` formatting, so the
/// global localization delegates must be present.
Widget buildTestWidget(
  Widget child, {
  Locale? locale,
  ThemeData? theme,
}) {
  return MaterialApp(
    locale: locale,
    theme:
        theme ?? ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    supportedLocales: const [
      Locale('en'),
      Locale('en', 'US'),
      Locale('fr'),
      Locale('fr', 'FR'),
      Locale('ar'),
      Locale('ja'),
    ],
    home: Scaffold(
      body: SingleChildScrollView(child: child),
    ),
  );
}
