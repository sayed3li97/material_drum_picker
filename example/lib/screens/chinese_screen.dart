import 'package:flutter/material.dart';
import 'package:material_drum_picker/material_drum_picker.dart';

/// Demonstrates the Chinese lunisolar calendar, including leap months and the
/// sexagenary year, in a Chinese locale.
class ChineseScreen extends StatefulWidget {
  /// Creates the Chinese calendar demo.
  const ChineseScreen({super.key});

  @override
  State<ChineseScreen> createState() => _ChineseScreenState();
}

class _ChineseScreenState extends State<ChineseScreen> {
  DateTime? _date;

  Future<void> _pick(Locale locale) async {
    final picked = await showDrumDatePicker(
      context: context,
      // Opens on the leap month of 2023 to show the 13 month year.
      initialDate: DateTime(2023, 3, 22),
      firstDate: DateTime(1950),
      lastDate: DateTime(2050),
      calendar: DrumCalendarType.chinese,
      showGregorianAlongside: true,
      locale: locale,
    );
    if (picked != null) setState(() => _date = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chinese (lunisolar)')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _date == null
                  ? 'No date selected'
                  : 'Gregorian: ${_date!.toIso8601String().split('T').first}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => _pick(const Locale('zh')),
              child: const Text('Pick a Chinese date (中文)'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => _pick(const Locale('en')),
              child: const Text('Pick a Chinese date (English)'),
            ),
          ],
        ),
      ),
    );
  }
}
