import 'package:flutter/material.dart';
import 'package:material_drum_picker/material_drum_picker.dart';

/// Demonstrates a data backed lunar calendar driven by a lookup table.
///
/// The dataset below is a clearly labeled SYNTHETIC sample (an alternating
/// 30 and 29 day pattern), not real Taqweem al-Hadi data. A real committee
/// calendar dataset must be supplied by the app, with the publisher's
/// permission and attribution; the package never ships that data.
class DataBackedCalendarScreen extends StatefulWidget {
  /// Creates the data backed calendar demo.
  const DataBackedCalendarScreen({super.key});

  @override
  State<DataBackedCalendarScreen> createState() =>
      _DataBackedCalendarScreenState();
}

class _DataBackedCalendarScreenState extends State<DataBackedCalendarScreen> {
  late final TabularLunarCalendarSystem _system = _buildSampleSystem();
  DateTime? _date;

  static TabularLunarCalendarSystem _buildSampleSystem() {
    final months = <TabularLunarMonth>[];
    var g = DateTime(2024, 7, 7);
    var hy = 1446;
    var hm = 1;
    for (var i = 0; i <= 36; i++) {
      months.add(
          TabularLunarMonth(hijriYear: hy, hijriMonth: hm, gregorianStart: g));
      g = g.add(Duration(days: i.isEven ? 30 : 29));
      hm++;
      if (hm > 12) {
        hm = 1;
        hy++;
      }
    }
    return TabularLunarCalendarSystem(months);
  }

  Future<void> _pick() async {
    final picked = await showDrumDatePicker(
      context: context,
      firstDate: _system.minSupported,
      lastDate: _system.maxSupported,
      calendarSystem: _system,
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
      appBar: AppBar(title: const Text('Data backed calendar')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              color: Theme.of(context).colorScheme.tertiaryContainer,
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'This uses a synthetic sample dataset for demonstration. It is '
                  'not real Taqweem al-Hadi data. Supply a real committee dataset '
                  'from your own app, with permission and attribution.',
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _date == null
                  ? 'No date selected'
                  : 'Gregorian: ${_date!.toIso8601String().split('T').first}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _pick,
              child: const Text('Pick from the sample calendar'),
            ),
          ],
        ),
      ),
    );
  }
}
