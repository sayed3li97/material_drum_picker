import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/basic_screen.dart';
import 'screens/birth_date_screen.dart';
import 'screens/booking_screen.dart';
import 'screens/custom_theme_screen.dart';
import 'screens/date_time_screen.dart';
import 'screens/inline_form_screen.dart';
import 'screens/localization_screen.dart';
import 'screens/rtl_screen.dart';
import 'screens/scheduling_screen.dart';
import 'screens/showcase_screen.dart';

void main() => runApp(const ExampleApp());

/// The root example application.
class ExampleApp extends StatelessWidget {
  /// Creates the example app.
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'material_drum_picker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.indigo,
      ),
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [
        Locale('en'),
        Locale('fr'),
        Locale('ar'),
        Locale('ja'),
      ],
      home: const HomeScreen(),
    );
  }
}

/// A menu of the available demo screens.
class HomeScreen extends StatelessWidget {
  /// Creates the home menu.
  const HomeScreen({super.key});

  static const _demos = <(String, String, WidgetBuilder)>[
    ('Showcase', 'All options live, side by side', _showcase),
    ('Date + time', 'Combined date & time picker', _dateTime),
    ('Basic', 'Drop-in replacement for showDatePicker', _basic),
    ('Birth date', 'Drum mode, locked, min/max age', _birth),
    ('Booking', 'Disabled weekends and holidays', _booking),
    ('Scheduling', 'Calendar mode, future only', _scheduling),
    ('Custom theme', 'DrumPickerTheme overrides', _theme),
    ('Inline form', 'Embedded without a dialog', _inline),
    ('RTL / Arabic', 'Right-to-left layout', _rtl),
    ('Localization', 'Multiple locales', _localization),
  ];

  static Widget _showcase(BuildContext c) => const ShowcaseScreen();
  static Widget _dateTime(BuildContext c) => const DateTimeScreen();
  static Widget _basic(BuildContext c) => const BasicScreen();
  static Widget _birth(BuildContext c) => const BirthDateScreen();
  static Widget _booking(BuildContext c) => const BookingScreen();
  static Widget _scheduling(BuildContext c) => const SchedulingScreen();
  static Widget _theme(BuildContext c) => const CustomThemeScreen();
  static Widget _inline(BuildContext c) => const InlineFormScreen();
  static Widget _rtl(BuildContext c) => const RtlScreen();
  static Widget _localization(BuildContext c) => const LocalizationScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('material_drum_picker')),
      body: ListView.separated(
        itemCount: _demos.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final (title, subtitle, builder) = _demos[index];
          return ListTile(
            title: Text(title),
            subtitle: Text(subtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () =>
                Navigator.of(context).push(MaterialPageRoute(builder: builder)),
          );
        },
      ),
    );
  }
}
