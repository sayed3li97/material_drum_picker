import 'package:flutter/material.dart';
import 'package:material_drum_picker/material_drum_picker.dart';

/// Demonstrates [DrumDateFormField] inside a [Form] with validation, save, and
/// reset, the way you would use [TextFormField].
class FormFieldScreen extends StatefulWidget {
  /// Creates the form field demo.
  const FormFieldScreen({super.key});

  @override
  State<FormFieldScreen> createState() => _FormFieldScreenState();
}

class _FormFieldScreenState extends State<FormFieldScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _dob;
  DateTime? _start;

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Saved: dob=${_dob?.toIso8601String().split('T').first}, '
          'start=${_start?.toIso8601String().split('T').first}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    return Scaffold(
      appBar: AppBar(title: const Text('Form field')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DrumDateFormField(
                firstDate: DateTime(1900),
                lastDate: today,
                decoration: const InputDecoration(
                  labelText: 'Date of birth',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.cake_outlined),
                ),
                validator: (v) =>
                    v == null ? 'Please pick your date of birth' : null,
                onSaved: (v) => _dob = v,
              ),
              const SizedBox(height: 16),
              DrumDateFormField(
                firstDate: today,
                lastDate: DateTime(today.year + 2),
                hintText: 'Select a start date',
                decoration: const InputDecoration(
                  labelText: 'Start date',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null ? 'Required' : null,
                onSaved: (v) => _start = v,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _formKey.currentState!.reset(),
                      child: const Text('Reset'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _submit,
                      child: const Text('Submit'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
