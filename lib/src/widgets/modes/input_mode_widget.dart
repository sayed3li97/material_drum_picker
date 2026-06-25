import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../calendar/drum_calendar_system.dart';
import '../../utils/drum_date_utils.dart';
import '../../utils/drum_locale_utils.dart';
import '../../utils/drum_numerals.dart';

/// The keyboard text-entry input mode, with live `MM/DD/YYYY` validation in the
/// active [system] calendar. The positional Month/Day/Year format is kept for
/// backward compatibility; only validation, conversion, and the localized
/// preview follow the active calendar.
class InputModeWidget extends StatefulWidget {
  /// Creates the input mode body.
  const InputModeWidget({
    super.key,
    required this.selectedDate,
    required this.firstDate,
    required this.lastDate,
    required this.system,
    required this.locale,
    required this.onChanged,
    this.selectableDayPredicate,
    this.errorFormatText,
    this.errorInvalidText,
    this.fieldHintText,
    this.fieldLabelText,
    this.decoration,
  });

  /// The currently-selected date (canonical Gregorian value).
  final DateTime selectedDate;

  /// The earliest selectable date.
  final DateTime firstDate;

  /// The latest selectable date.
  final DateTime lastDate;

  /// The active calendar system.
  final DrumCalendarSystem system;

  /// The resolved locale for names and numerals.
  final Locale locale;

  /// Called with the new date when valid text is entered.
  final ValueChanged<DateTime> onChanged;

  /// Optional predicate restricting selectable days.
  final bool Function(DateTime day)? selectableDayPredicate;

  /// Error shown when the typed text is not a valid `MM/DD/YYYY` date.
  final String? errorFormatText;

  /// Error shown when the date is valid but out of range or not selectable.
  final String? errorInvalidText;

  /// Hint text for the field. Defaults to `MM/DD/YYYY`.
  final String? fieldHintText;

  /// Label text for the field. Defaults to `Enter Date`.
  final String? fieldLabelText;

  /// Optional base decoration. The label, hint, error, helper, and suffix icon
  /// are layered on top. When null an [OutlineInputBorder] is used.
  final InputDecoration? decoration;

  @override
  State<InputModeWidget> createState() => _InputModeWidgetState();
}

class _InputModeWidgetState extends State<InputModeWidget> {
  late final TextEditingController _controller;
  String? _errorText;
  String? _helperText;

  String? get _localeName => DrumLocaleUtils.toIntlLocale(widget.locale);

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

  /// Formats [date] as Month/Day/Year in the active calendar, with locale
  /// aware digits.
  String _format(DateTime date) {
    final c = widget.system.decode(date);
    final mm = DrumNumerals.formatPadded(c.month, 2, _localeName);
    final dd = DrumNumerals.formatPadded(c.day, 2, _localeName);
    final yyyy = DrumNumerals.formatPadded(c.year, 4, _localeName);
    return '$mm/$dd/$yyyy';
  }

  /// Maps Eastern Arabic-Indic and Persian digits to ASCII so typed localized
  /// digits parse correctly.
  String _normalizeDigits(String input) {
    final buffer = StringBuffer();
    for (final rune in input.runes) {
      if (rune >= 0x0660 && rune <= 0x0669) {
        buffer.writeCharCode(0x30 + (rune - 0x0660));
      } else if (rune >= 0x06F0 && rune <= 0x06F9) {
        buffer.writeCharCode(0x30 + (rune - 0x06F0));
      } else {
        buffer.writeCharCode(rune);
      }
    }
    return buffer.toString();
  }

  /// Parses `MM/DD/YYYY` in the active calendar, returning the canonical
  /// `DateTime`, or null if the text is malformed or invalid in the calendar.
  DateTime? _parse(String text) {
    final parts = _normalizeDigits(text).split('/');
    if (parts.length != 3) return null;
    final month = int.tryParse(parts[0]);
    final day = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (month == null || day == null || year == null) return null;
    if (!widget.system.isValid(year, month, day)) return null;
    return widget.system.encode(year, month, day);
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
      _helperText = _preview(date);
    });
    widget.onChanged(date);
  }

  String _preview(DateTime date) {
    final c = widget.system.decode(date);
    final weekday = DateFormat.EEEE(_localeName).format(date);
    final month = widget.system
        .monthName(c.month, abbreviated: false, locale: widget.locale);
    final day = DrumNumerals.format(c.day, _localeName);
    final year = DrumNumerals.format(c.year, _localeName);
    return '$weekday, $month $day, $year';
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
          FilteringTextInputFormatter.allow(RegExp(r'[0-9٠-٩۰-۹/]')),
          LengthLimitingTextInputFormatter(10),
        ],
        decoration: (widget.decoration ??
                const InputDecoration(border: OutlineInputBorder()))
            .copyWith(
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
