import 'package:flutter/material.dart';
import 'package:material_drum_picker/material_drum_picker.dart';

/// A single screen that shows all three modes live, side by side, plus a live
/// read-out of the selected value and the active mode.
class ShowcaseScreen extends StatefulWidget {
  /// Creates the showcase screen.
  const ShowcaseScreen({super.key});

  @override
  State<ShowcaseScreen> createState() => _ShowcaseScreenState();
}

class _ShowcaseScreenState extends State<ShowcaseScreen> {
  DateTime _selected = DateTime(2024, 6, 15);
  DrumPickerMode _mode = DrumPickerMode.drum;

  static final DateTime _today = DateTime(2024, 6, 15);

  bool _noWeekends(DateTime day) =>
      day.weekday != DateTime.saturday && day.weekday != DateTime.sunday;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Showcase — all options')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Selected: ${_selected.toIso8601String().split('T').first}',
                      style: Theme.of(context).textTheme.titleMedium),
                  Text('Active mode: ${_mode.name}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            clipBehavior: Clip.antiAlias,
            child: DrumPicker(
              initialDate: _selected,
              currentDate: _today,
              firstDate: DateTime(1950),
              lastDate: DateTime(2035),
              initialMode: _mode,
              showDayOfWeekInDrum: true,
              columnOrder: DrumColumnOrder.dmy,
              helpText: 'PICK ANY DATE',
              selectableDayPredicate: _noWeekends,
              quickSelectOptions: [
                DrumQuickSelect.relative(
                    label: 'Today',
                    offset: Duration.zero,
                    referenceDate: _today),
                DrumQuickSelect.relative(
                    label: '+3 days',
                    offset: const Duration(days: 3),
                    referenceDate: _today),
                DrumQuickSelect.relative(
                    label: '+1 week',
                    offset: const Duration(days: 7),
                    referenceDate: _today),
              ],
              onChanged: (d) => setState(() => _selected = d),
              onModeChanged: (m) => setState(() => _mode = m),
              onConfirmed: (d) => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Confirmed $d')),
              ),
              onCancelled: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cancelled')),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Weekends are disabled via selectableDayPredicate, the drum shows '
            'the day-of-week, columns are Day–Month–Year, and quick-select '
            'chips appear in calendar mode. Switch modes with the tabs above.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
