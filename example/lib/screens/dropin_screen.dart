import 'package:flutter/cupertino.dart' show CupertinoDatePickerMode;
import 'package:flutter/material.dart';
import 'package:material_drum_picker/material_drum_picker.dart';

/// Demonstrates the inline drop in replacements for `CalendarDatePicker` and
/// `CupertinoDatePicker`.
class DropinScreen extends StatefulWidget {
  /// Creates the drop in demo.
  const DropinScreen({super.key});

  @override
  State<DropinScreen> createState() => _DropinScreenState();
}

class _DropinScreenState extends State<DropinScreen> {
  DateTime _date = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Drop in replacements')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Selected: ${_date.toIso8601String().split('T').first}',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          const Text('DrumCupertinoDatePicker'),
          const SizedBox(height: 8),
          Card(
            child: SizedBox(
              height: 240,
              // Was: CupertinoDatePicker(...)
              child: DrumCupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: _date,
                minimumDate: DateTime(2020),
                maximumDate: DateTime(2030),
                onDateTimeChanged: (d) => setState(() => _date = d),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('DrumCalendarDatePicker'),
          const SizedBox(height: 8),
          Card(
            // Was: CalendarDatePicker(...)
            child: DrumCalendarDatePicker(
              initialDate: _date,
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
              onDateChanged: (d) => setState(() => _date = d),
            ),
          ),
        ],
      ),
    );
  }
}
