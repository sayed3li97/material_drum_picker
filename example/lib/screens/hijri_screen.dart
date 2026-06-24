import 'package:flutter/material.dart';
import 'package:material_drum_picker/material_drum_picker.dart';

/// Demonstrates the Umm al-Qura Hijri calendar in an Arabic, right to left
/// layout, with the Gregorian equivalent shown alongside.
class HijriScreen extends StatefulWidget {
  /// Creates the Hijri demo.
  const HijriScreen({super.key});

  @override
  State<HijriScreen> createState() => _HijriScreenState();
}

class _HijriScreenState extends State<HijriScreen> {
  DateTime? _date;

  Future<void> _pick() async {
    final picked = await showDrumDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
      calendar: DrumCalendarType.hijri,
      showGregorianAlongside: true,
      locale: const Locale('ar'),
      helpText: 'اختر التاريخ',
      confirmText: 'تأكيد',
      cancelText: 'إلغاء',
    );
    if (picked != null) setState(() => _date = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hijri (Umm al-Qura)')),
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
              child: const Text('Pick a Hijri date (Arabic)'),
            ),
          ],
        ),
      ),
    );
  }
}
