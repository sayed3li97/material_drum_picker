import 'package:flutter/material.dart';
import 'package:material_drum_picker/material_drum_picker.dart';

/// Demonstrates a right-to-left (Arabic) layout.
class RtlScreen extends StatefulWidget {
  /// Creates the RTL demo.
  const RtlScreen({super.key});

  @override
  State<RtlScreen> createState() => _RtlScreenState();
}

class _RtlScreenState extends State<RtlScreen> {
  DateTime? _date;

  Future<void> _pick() async {
    final picked = await showDrumDatePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      locale: const Locale('ar'),
      textDirection: TextDirection.rtl,
      columnOrder: DrumColumnOrder.dmy,
      helpText: 'اختر التاريخ',
      confirmText: 'تأكيد',
      cancelText: 'إلغاء',
    );
    if (picked != null) setState(() => _date = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('RTL / Arabic')),
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
              child: const Text('Pick (RTL)'),
            ),
          ],
        ),
      ),
    );
  }
}
