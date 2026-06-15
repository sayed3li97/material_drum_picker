import 'package:flutter/material.dart';
import 'package:material_drum_picker/material_drum_picker.dart';

/// Embeds the picker inline in a form, without a dialog or action buttons.
class InlineFormScreen extends StatefulWidget {
  /// Creates the inline-form demo.
  const InlineFormScreen({super.key});

  @override
  State<InlineFormScreen> createState() => _InlineFormScreenState();
}

class _InlineFormScreenState extends State<InlineFormScreen> {
  DateTime? _expiry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inline form')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const TextField(
            decoration: InputDecoration(
              labelText: 'Card number',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          Text('Expiry date', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Card(
            clipBehavior: Clip.antiAlias,
            child: DrumPicker(
              firstDate: DateTime.now(),
              lastDate: DateTime(2040),
              initialMode: DrumPickerMode.drum,
              columnOrder: DrumColumnOrder.mdy,
              showActions: false,
              showModeToggle: false,
              showQuickSelects: false,
              onChanged: (date) => setState(() => _expiry = date),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _expiry == null ? null : () {},
            child: Text(_expiry == null ? 'Pick expiry' : 'Submit ($_expiry)'),
          ),
        ],
      ),
    );
  }
}
