import 'package:flutter/material.dart';
import 'package:material_drum_picker/material_drum_picker.dart';

/// An appointment picker: calendar mode, near future only, no Sundays.
class SchedulingScreen extends StatefulWidget {
  /// Creates the scheduling demo.
  const SchedulingScreen({super.key});

  @override
  State<SchedulingScreen> createState() => _SchedulingScreenState();
}

class _SchedulingScreenState extends State<SchedulingScreen> {
  DateTime? _appointment;

  Future<void> _pick() async {
    final now = DateTime.now();
    final picked = await showDrumDatePicker(
      context: context,
      initialMode: DrumPickerMode.calendar,
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
      helpText: 'SELECT APPOINTMENT',
      confirmText: 'BOOK',
      cancelText: 'NOT NOW',
      selectableDayPredicate: (day) => day.weekday != DateTime.sunday,
      quickSelectOptions: [
        DrumQuickSelect.relative(label: 'Today', offset: Duration.zero),
        DrumQuickSelect.relative(
            label: 'Tomorrow', offset: const Duration(days: 1)),
        DrumQuickSelect.relative(
            label: 'Next week', offset: const Duration(days: 7)),
      ],
    );
    if (picked != null) setState(() => _appointment = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scheduling')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _appointment == null ? 'No appointment set' : '$_appointment',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _pick,
              child: const Text('Book appointment'),
            ),
          ],
        ),
      ),
    );
  }
}
