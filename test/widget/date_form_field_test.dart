import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_drum_picker/material_drum_picker.dart';

import '../helpers.dart';

Widget _form({
  required GlobalKey<FormState> formKey,
  DateTime? initialValue,
  ValueChanged<DateTime?>? onChanged,
  FormFieldSetter<DateTime>? onSaved,
  FormFieldValidator<DateTime>? validator,
  AutovalidateMode? autovalidateMode,
  bool enabled = true,
  DrumCalendarType calendar = DrumCalendarType.gregorian,
  String? hintText,
  InputDecoration decoration = const InputDecoration(labelText: 'Date'),
}) {
  return buildTestWidget(
    Form(
      key: formKey,
      child: DrumDateFormField(
        initialValue: initialValue,
        firstDate: DateTime(2024, 6, 1),
        lastDate: DateTime(2024, 6, 30),
        currentDate: DateTime(2024, 6, 15),
        onChanged: onChanged,
        onSaved: onSaved,
        validator: validator,
        autovalidateMode: autovalidateMode,
        enabled: enabled,
        calendar: calendar,
        hintText: hintText,
        decoration: decoration,
        locale: const Locale('en'),
      ),
    ),
    locale: const Locale('en'),
  );
}

void main() {
  testWidgets('shows the initial value formatted', (tester) async {
    final key = GlobalKey<FormState>();
    await tester
        .pumpWidget(_form(formKey: key, initialValue: DateTime(2024, 6, 15)));
    expect(find.text('June 15, 2024'), findsOneWidget);
  });

  testWidgets('shows the hint text when empty (no label)', (tester) async {
    final key = GlobalKey<FormState>();
    await tester.pumpWidget(_form(
      formKey: key,
      hintText: 'Pick a date',
      decoration: const InputDecoration(),
    ));
    expect(find.text('Pick a date'), findsOneWidget);
  });

  testWidgets('tapping opens the picker; picking updates value, onChanged',
      (tester) async {
    final key = GlobalKey<FormState>();
    DateTime? changed;
    DateTime? saved;
    await tester.pumpWidget(_form(
      formKey: key,
      initialValue: DateTime(2024, 6, 15),
      onChanged: (v) => changed = v,
      onSaved: (v) => saved = v,
    ));

    await tester.tap(find.text('June 15, 2024'));
    await tester.pumpAndSettle();
    // The dialog is open in calendar mode.
    expect(find.text('OK'), findsOneWidget);
    await tester.tap(find.text('20'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('OK'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(changed, DateTime(2024, 6, 20));
    expect(find.text('June 20, 2024'), findsOneWidget);

    key.currentState!.save();
    expect(saved, DateTime(2024, 6, 20));
  });

  testWidgets('cancelling the dialog keeps the current value', (tester) async {
    final key = GlobalKey<FormState>();
    DateTime? changed;
    await tester.pumpWidget(_form(
      formKey: key,
      initialValue: DateTime(2024, 6, 15),
      onChanged: (v) => changed = v,
    ));
    await tester.tap(find.text('June 15, 2024'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Cancel'));
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(changed, isNull);
    expect(find.text('June 15, 2024'), findsOneWidget);
  });

  testWidgets('validator reports an error through the decoration',
      (tester) async {
    final key = GlobalKey<FormState>();
    await tester.pumpWidget(_form(
      formKey: key,
      validator: (v) => v == null ? 'Required' : null,
    ));
    expect(find.text('Required'), findsNothing);
    key.currentState!.validate();
    await tester.pump();
    expect(find.text('Required'), findsOneWidget);
  });

  testWidgets('reset restores the initial value', (tester) async {
    final key = GlobalKey<FormState>();
    await tester.pumpWidget(_form(
      formKey: key,
      initialValue: DateTime(2024, 6, 15),
    ));
    await tester.tap(find.text('June 15, 2024'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('20'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('OK'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('June 20, 2024'), findsOneWidget);

    key.currentState!.reset();
    await tester.pump();
    expect(find.text('June 15, 2024'), findsOneWidget);
  });

  testWidgets('disabled field does not open the picker', (tester) async {
    final key = GlobalKey<FormState>();
    await tester.pumpWidget(_form(
      formKey: key,
      initialValue: DateTime(2024, 6, 15),
      enabled: false,
    ));
    await tester.tap(find.text('June 15, 2024'));
    await tester.pumpAndSettle();
    expect(find.text('OK'), findsNothing); // no dialog
  });

  testWidgets('formats the value in the active calendar (Jalali)',
      (tester) async {
    final key = GlobalKey<FormState>();
    await tester.pumpWidget(_form(
      formKey: key,
      initialValue: DateTime(2024, 3, 20), // Farvardin 1, 1403
      calendar: DrumCalendarType.jalali,
    ));
    expect(find.text('Farvardin 1, 1403'), findsOneWidget);
  });
}
