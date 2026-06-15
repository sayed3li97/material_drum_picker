import 'package:flutter/material.dart';
import 'package:material_drum_picker/material_drum_picker.dart';

/// Demonstrates forcing different locales regardless of the device locale.
class LocalizationScreen extends StatefulWidget {
  /// Creates the localization demo.
  const LocalizationScreen({super.key});

  @override
  State<LocalizationScreen> createState() => _LocalizationScreenState();
}

class _LocalizationScreenState extends State<LocalizationScreen> {
  DateTime? _date;

  static const _locales = <(String, Locale, DrumColumnOrder)>[
    ('English (US)', Locale('en', 'US'), DrumColumnOrder.mdy),
    ('Français', Locale('fr', 'FR'), DrumColumnOrder.dmy),
    ('日本語', Locale('ja'), DrumColumnOrder.ymd),
  ];

  Future<void> _pick(Locale locale, DrumColumnOrder order) async {
    final picked = await showDrumDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
      locale: locale,
      columnOrder: order,
    );
    if (picked != null) setState(() => _date = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Localization')),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Text(
            _date == null ? 'No date selected' : '$_date',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          for (final (label, locale, order) in _locales)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: FilledButton.tonal(
                onPressed: () => _pick(locale, order),
                child: Text(label),
              ),
            ),
        ],
      ),
    );
  }
}
