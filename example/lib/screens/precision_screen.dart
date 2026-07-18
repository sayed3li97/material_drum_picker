import 'package:flutter/material.dart';
import 'package:material_drum_picker/material_drum_picker.dart';

/// Demonstrates month and year precision: a card-expiry month picker and a
/// birth-year picker, both returning a Gregorian `DateTime`.
class PrecisionScreen extends StatefulWidget {
  /// Creates the precision demo.
  const PrecisionScreen({super.key});

  @override
  State<PrecisionScreen> createState() => _PrecisionScreenState();
}

class _PrecisionScreenState extends State<PrecisionScreen> {
  DateTime? _expiry;
  DateTime? _birthYear;

  Future<void> _pickExpiry() async {
    final picked = await showDrumDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035, 12),
      precision: DrumPrecision.month,
      helpText: 'CARD EXPIRY',
    );
    if (picked != null) setState(() => _expiry = picked);
  }

  Future<void> _pickBirthYear() async {
    final picked = await showDrumDatePicker(
      context: context,
      firstDate: DateTime(1940),
      lastDate: DateTime(2020),
      precision: DrumPrecision.year,
      initialEntryMode: DatePickerEntryMode.calendar,
      helpText: 'BIRTH YEAR',
    );
    if (picked != null) setState(() => _birthYear = picked);
  }

  String _fmtMonth(DateTime? d) =>
      d == null ? 'None' : '${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Month / year precision')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Card expiry: ${_fmtMonth(_expiry)}',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _pickExpiry,
              child: const Text('Pick expiry month'),
            ),
            const SizedBox(height: 24),
            Text('Birth year: ${_birthYear?.year ?? 'None'}',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _pickBirthYear,
              child: const Text('Pick birth year'),
            ),
          ],
        ),
      ),
    );
  }
}
