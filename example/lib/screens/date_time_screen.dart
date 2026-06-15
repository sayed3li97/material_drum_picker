import 'package:flutter/material.dart';
import 'package:material_drum_picker/material_drum_picker.dart';

/// Demonstrates the combined date + time picker.
class DateTimeScreen extends StatefulWidget {
  /// Creates the date-time demo.
  const DateTimeScreen({super.key});

  @override
  State<DateTimeScreen> createState() => _DateTimeScreenState();
}

class _DateTimeScreenState extends State<DateTimeScreen> {
  DateTime? _value;

  Future<void> _pickDialog({bool use24h = false, int interval = 1}) async {
    final now = DateTime.now();
    final picked = await showDrumDateTimePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365)),
      use24hFormat: use24h,
      minuteInterval: interval,
      helpText: 'SELECT DATE & TIME',
    );
    if (picked != null) setState(() => _value = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Date + time')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: ListTile(
              title: const Text('Selected'),
              subtitle: Text(_value?.toString() ?? 'Nothing selected yet'),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => _pickDialog(),
            child: const Text('Pick date & time (12-hour)'),
          ),
          const SizedBox(height: 8),
          FilledButton.tonal(
            onPressed: () => _pickDialog(use24h: true, interval: 15),
            child: const Text('Pick date & time (24-hour, 15-min steps)'),
          ),
          const SizedBox(height: 24),
          Text('Inline, 5-minute steps',
              style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Card(
            clipBehavior: Clip.antiAlias,
            child: DrumPicker(
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
              initialDate: DateTime(2024, 6, 15, 9, 0),
              currentDate: DateTime(2024, 6, 15),
              pickTime: true,
              minuteInterval: 5,
              showModeToggle: false,
              showActions: false,
              onChanged: (d) => setState(() => _value = d),
            ),
          ),
        ],
      ),
    );
  }
}
