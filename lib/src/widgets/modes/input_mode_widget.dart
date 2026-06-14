import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../utils/drum_date_utils.dart';

/// The keyboard text-entry input mode, with live `MM/DD/YYYY` validation.
class InputModeWidget extends StatefulWidget {
  /// Creates the input mode body.
  const InputModeWidget({
    super.key,
    required this.selectedDate,
    required this.firstDate,
    required this.lastDate,
    required this.onChanged,
    this.selectableDayPredicate,
    this.errorFormatText,
    this.errorInvalidText,
    this.fieldHintText,
    this.fieldLabelText,
    this.localeName,
  });

  /// The currently-selected date.
  final DateTime selectedDate;

  /// The earliest selectable date.
  final DateTime firstDate;

  /// The latest selectable date.
  final DateTime lastDate;

  /// Called with the new date when valid text is entered.
  final ValueChanged<DateTime> onChanged;

  /// Optional predicate restricting selectable days.
  final bool Function(DateTime day)? selectableDayPredicate;

  /// Error shown when the typed text is not a valid `MM/DD/YYYY` date.
  final String? errorFormatText;

  /// Error shown when the date is valid but out of range / not selectable.
  final String? errorInvalidText;

  /// Hint text for the field. Defaults to `MM/DD/YYYY`.
  final String? fieldHintText;

  /// Label text for the field. Defaults to `Enter Date`.
  final String? fieldLabelText;

  /// The `intl` locale used to format the helper preview text.
  final String? localeName;

  @override
  State<InputModeWidget> createState() => _InputModeWidgetState();
}

class _InputModeWidgetState extends State<InputModeWidget> {
  late final TextEditingController _controller;
  String? _errorText;
  String? _helperText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _format(widget.selectedDate));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _format(DateTime date) {
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    final yyyy = date.year.toString().padLeft(4, '0');
    return '$mm/$dd/$yyyy';
  }

  /// Parses `MM/DD/YYYY`, returning `null` if the text is malformed.
  DateTime? _parse(String text) {
    final parts = text.split('/');
    if (parts.length != 3) return null;
    final month = int.tryParse(parts[0]);
    final day = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (month == null || day == null || year == null) return null;
    if (month < 1 || month > 12) return null;
    if (year < 1 || day < 1) return null;
    if (day > DrumDateUtils.daysInMonth(year, month)) return null;
    return DateTime(year, month, day);
  }

  void _onChanged(String text) {
    final date = _parse(text);
    if (date == null) {
      setState(() {
        _errorText = widget.errorFormatText ?? 'Invalid format. Use MM/DD/YYYY';
        _helperText = null;
      });
      return;
    }
    if (!DrumDateUtils.isInRange(date, widget.firstDate, widget.lastDate)) {
      setState(() {
        _errorText = widget.errorInvalidText ?? 'Out of range';
        _helperText = null;
      });
      return;
    }
    if (!(widget.selectableDayPredicate?.call(date) ?? true)) {
      setState(() {
        _errorText = widget.errorInvalidText ?? 'Date not available';
        _helperText = null;
      });
      return;
    }
    setState(() {
      _errorText = null;
      _helperText = DateFormat.yMMMMEEEEd(widget.localeName).format(date);
    });
    widget.onChanged(date);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        autofocus: false,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9/]')),
          LengthLimitingTextInputFormatter(10),
        ],
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: widget.fieldLabelText ?? 'Enter Date',
          hintText: widget.fieldHintText ?? 'MM/DD/YYYY',
          errorText: _errorText,
          helperText: _helperText,
          suffixIcon: const Icon(Icons.edit_calendar_outlined),
        ),
        onChanged: _onChanged,
      ),
    );
  }
}
