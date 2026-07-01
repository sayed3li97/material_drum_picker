import 'package:flutter/material.dart';
import 'package:material_drum_picker/material_drum_picker.dart';

/// Demonstrates the Persian Solar Hijri (Jalali) calendar in a Persian, right to
/// left layout, with the Gregorian equivalent shown alongside.
class JalaliScreen extends StatefulWidget {
  /// Creates the Jalali demo.
  const JalaliScreen({super.key});

  @override
  State<JalaliScreen> createState() => _JalaliScreenState();
}

class _JalaliScreenState extends State<JalaliScreen> {
  DateTime? _date;

  Future<void> _pick() async {
    final picked = await showDrumDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
      calendar: DrumCalendarType.jalali,
      showGregorianAlongside: true,
      locale: const Locale('fa'),
      helpText: 'انتخاب تاریخ',
      confirmText: 'تأیید',
      cancelText: 'لغو',
    );
    if (picked != null) setState(() => _date = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Persian (Jalali)')),
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
              onPressed: _pick,
              child: const Text('Pick a Jalali date (Persian)'),
            ),
          ],
        ),
      ),
    );
  }
}
