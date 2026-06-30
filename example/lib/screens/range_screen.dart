import 'package:flutter/material.dart';
import 'package:material_drum_picker/material_drum_picker.dart';

/// Demonstrates date range and multiple date selection.
class RangeScreen extends StatefulWidget {
  /// Creates the range demo.
  const RangeScreen({super.key});

  @override
  State<RangeScreen> createState() => _RangeScreenState();
}

class _RangeScreenState extends State<RangeScreen> {
  DateTimeRange? _range;
  List<DateTime> _dates = const [];

  Future<void> _pickRange() async {
    final range = await showDrumDateRangePicker(
      context: context,
      firstDate: DateTime(2024, 1, 1),
      lastDate: DateTime(2025, 12, 31),
      firstDayOfWeek: DateTime.monday,
    );
    if (range != null) setState(() => _range = range);
  }

  Future<void> _pickMulti() async {
    final dates = await showDrumMultiDatePicker(
      context: context,
      firstDate: DateTime(2024, 1, 1),
      lastDate: DateTime(2025, 12, 31),
    );
    if (dates != null) setState(() => _dates = dates);
  }

  String _fmt(DateTime d) => d.toIso8601String().split('T').first;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Range & multiple dates')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _range == null
                  ? 'No range selected'
                  : '${_fmt(_range!.start)} to ${_fmt(_range!.end)}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _pickRange,
              child: const Text('Pick a date range'),
            ),
            const SizedBox(height: 24),
            Text(
              _dates.isEmpty
                  ? 'No dates selected'
                  : '${_dates.length} dates: ${_dates.map(_fmt).join(', ')}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _pickMulti,
              child: const Text('Pick multiple dates'),
            ),
          ],
        ),
      ),
    );
  }
}
