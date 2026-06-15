import 'package:flutter/material.dart';
import 'package:material_drum_picker/material_drum_picker.dart';

/// Demonstrates overriding M3 tokens via [DrumPickerTheme].
class CustomThemeScreen extends StatefulWidget {
  /// Creates the custom-theme demo.
  const CustomThemeScreen({super.key});

  @override
  State<CustomThemeScreen> createState() => _CustomThemeScreenState();
}

class _CustomThemeScreenState extends State<CustomThemeScreen> {
  DateTime? _date;

  Future<void> _pick() async {
    final picked = await showDrumDatePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            extensions: const [
              DrumPickerTheme(
                headerBackgroundColor: Color(0xFF004D40),
                headerTextColor: Colors.white,
                itemExtent: 48,
                visibleItemCount: 3,
              ),
            ],
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _date = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Custom theme')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _date == null ? 'No date selected' : '$_date',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _pick,
              child: const Text('Pick with custom theme'),
            ),
          ],
        ),
      ),
    );
  }
}
