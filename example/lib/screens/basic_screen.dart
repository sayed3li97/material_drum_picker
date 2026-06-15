import 'package:flutter/material.dart';
import 'package:material_drum_picker/material_drum_picker.dart';

/// The simplest possible usage — a drop-in replacement for `showDatePicker`.
class BasicScreen extends StatefulWidget {
  /// Creates the basic demo.
  const BasicScreen({super.key});

  @override
  State<BasicScreen> createState() => _BasicScreenState();
}

class _BasicScreenState extends State<BasicScreen> {
  DateTime? _date;

  Future<void> _pick() async {
    final picked = await showDrumDatePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Basic')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _date == null ? 'No date selected' : '$_date',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: _pick, child: const Text('Pick a date')),
          ],
        ),
      ),
    );
  }
}
