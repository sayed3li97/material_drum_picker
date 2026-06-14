import 'package:flutter/material.dart';
import 'package:material_drum_picker/material_drum_picker.dart';

/// A booking picker that disables weekends and specific holidays.
class BookingScreen extends StatefulWidget {
  /// Creates the booking demo.
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? _workday;

  static final Set<DateTime> _holidays = {
    DateTime(2024, 12, 25),
    DateTime(2025, 1, 1),
  };

  bool _isSelectable(DateTime day) {
    if (day.weekday == DateTime.saturday || day.weekday == DateTime.sunday) {
      return false;
    }
    return !_holidays.any((h) => DrumDateUtils.isSameDay(h, day));
  }

  Future<void> _pick() async {
    final picked = await showDrumDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2025, 12, 31),
      selectableDayPredicate: _isSelectable,
      initialMode: DrumPickerMode.calendar,
      helpText: 'CHOOSE A WORKDAY',
    );
    if (picked != null) setState(() => _workday = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _workday == null ? 'No workday selected' : '$_workday',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _pick,
              child: const Text('Book a workday'),
            ),
          ],
        ),
      ),
    );
  }
}
