import 'package:flutter/material.dart';
import 'package:material_drum_picker/material_drum_picker.dart';

/// A birth-date picker: drum mode, locked, with min/max age constraints.
class BirthDateScreen extends StatefulWidget {
  /// Creates the birth-date demo.
  const BirthDateScreen({super.key});

  @override
  State<BirthDateScreen> createState() => _BirthDateScreenState();
}

class _BirthDateScreenState extends State<BirthDateScreen> {
  DateTime? _birthDate;

  Future<void> _pick() async {
    final today = DateTime.now();
    final picked = await showDrumDatePicker(
      context: context,
      initialMode: DrumPickerMode.drum,
      initialDate: DateTime(today.year - 25, today.month, today.day),
      firstDate: DateTime(today.year - 120),
      lastDate: DateTime(today.year - 18, today.month, today.day),
      helpText: 'SELECT BIRTH DATE',
      columnOrder: DrumColumnOrder.dmy,
      showModeToggle: false,
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Birth date')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _birthDate == null
                  ? 'No birth date selected'
                  : '${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _pick,
              child: const Text('Select birth date'),
            ),
          ],
        ),
      ),
    );
  }
}
