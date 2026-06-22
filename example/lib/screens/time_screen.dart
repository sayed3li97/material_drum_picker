import 'package:flutter/material.dart';
import 'package:material_drum_picker/material_drum_picker.dart';

/// Demonstrates the time-only picker in both 12-hour and 24-hour modes.
class TimeScreen extends StatefulWidget {
  /// Creates the time-only demo.
  const TimeScreen({super.key});

  @override
  State<TimeScreen> createState() => _TimeScreenState();
}

class _TimeScreenState extends State<TimeScreen> {
  TimeOfDay? _value;

  Future<void> _pick({required bool use24h, int interval = 1}) async {
    final picked = await showDrumTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 30),
      use24hFormat: use24h,
      minuteInterval: interval,
    );
    if (picked != null) setState(() => _value = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Time only')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: ListTile(
              title: const Text('Selected time'),
              subtitle: Text(
                _value == null
                    ? 'Nothing selected yet'
                    : _value!.format(context),
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => _pick(use24h: false),
            child: const Text('Pick time (12-hour, AM/PM)'),
          ),
          const SizedBox(height: 8),
          FilledButton.tonal(
            onPressed: () => _pick(use24h: true, interval: 5),
            child: const Text('Pick time (24-hour, 5-min steps)'),
          ),
          const SizedBox(height: 24),
          Text('Inline, 15-minute steps',
              style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Card(
            clipBehavior: Clip.antiAlias,
            child: DrumTimePicker(
              initialTime: const TimeOfDay(hour: 18, minute: 0),
              use24hFormat: false,
              minuteInterval: 15,
              showActions: false,
              onChanged: (t) => setState(() => _value = t),
            ),
          ),
        ],
      ),
    );
  }
}
