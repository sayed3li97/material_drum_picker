import 'package:flutter/material.dart';
import 'package:material_drum_picker/material_drum_picker.dart';

/// Demonstrates event markers: the calendar grid used as a lightweight event
/// calendar, with colored dots per day and a live count of the selected day.
class EventsScreen extends StatefulWidget {
  /// Creates the event markers demo.
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  static final DateTime _month = DateTime(2024, 6);

  // A few sample events keyed by day, each with its own color.
  final Map<int, List<Color>> _events = {
    4: [Colors.blue],
    10: [Colors.blue, Colors.green],
    11: [Colors.red],
    18: [Colors.purple],
    22: [Colors.green, Colors.red],
    27: [Colors.blue, Colors.green, Colors.red, Colors.orange, Colors.purple],
  };

  DateTime _selected = DateTime(2024, 6, 15);

  List<DrumEventMarker> _load(DateTime day) {
    if (day.year != _month.year || day.month != _month.month) return const [];
    return _events[day.day]
            ?.map((c) => DrumEventMarker(color: c))
            .toList(growable: false) ??
        const [];
  }

  @override
  Widget build(BuildContext context) {
    final count = _load(_selected).length;
    return Scaffold(
      appBar: AppBar(title: const Text('Event markers')),
      body: Column(
        children: [
          DrumCalendarDatePicker(
            initialDate: _selected,
            currentDate: _selected,
            firstDate: DateTime(2024, 6, 1),
            lastDate: DateTime(2024, 6, 30),
            onDateChanged: (d) => setState(() => _selected = d),
            eventLoader: _load,
          ),
          const Divider(),
          Text(
            count == 0
                ? 'No events on the selected day'
                : '$count event${count == 1 ? '' : 's'} on the selected day',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}
