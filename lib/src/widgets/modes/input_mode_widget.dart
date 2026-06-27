import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../calendar/drum_calendar_system.dart';
import '../../models/drum_date_format.dart';
import '../../utils/drum_date_utils.dart';
import '../../utils/drum_locale_utils.dart';
import '../../utils/drum_numerals.dart';

/// The keyboard text-entry input mode, with live validation in the active
/// [system] calendar. The field order, separator, and year width follow
/// [format]; validation, conversion, and the localized preview follow the
/// active calendar.
class InputModeWidget extends StatefulWidget {
  /// Creates the input mode body.
  const InputModeWidget({
    super.key,
    required this.selectedDate,
    required this.firstDate,
    required this.lastDate,
    required this.system,
    required this.locale,
    required this.format,
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

  /// The field order, separator, and year width for formatting and parsing.
  final DrumDateFormat format;

  /// Called with the new date when valid text is entered.
  final ValueChanged<DateTime> onChanged;

  /// Optional predicate restricting selectable days.
  final bool Function(DateTime day)? selectableDayPredicate;

  /// Error shown when the typed text is not a valid date in [format].
  final String? errorFormatText;

  /// Error shown when the date is valid but out of range or not selectable.
  final String? errorInvalidText;

  /// Hint text for the field. Defaults to the [format]'s display pattern.
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

  /// Formats [date] in the active calendar, following [DrumDateFormat], with
  /// locale aware digits.
  String _format(DateTime date) {
    final c = widget.system.decode(date);
    String fieldText(DrumDateField field) {
      switch (field) {
        case DrumDateField.day:
          return DrumNumerals.formatPadded(c.day, 2, _localeName);
        case DrumDateField.month:
          return DrumNumerals.formatPadded(c.month, 2, _localeName);
        case DrumDateField.year:
          final year = widget.format.twoDigitYear ? c.year % 100 : c.year;
          return DrumNumerals.formatPadded(
              year, widget.format.yearDigits, _localeName);
      }
    }

    return widget.format.order.map(fieldText).join(widget.format.separator);
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

  /// Splits [text] into exactly three parts, preferring the configured
  /// separator but falling back to any run of non-digits.
  List<String>? _split(String text) {
    final normalized = _normalizeDigits(text);
    if (widget.format.separator.isNotEmpty) {
      final bySeparator = normalized.split(widget.format.separator);
      if (bySeparator.length == 3) return bySeparator;
    }
    final byNonDigit =
        normalized.split(RegExp(r'\D+')).where((s) => s.isNotEmpty).toList();
    if (byNonDigit.length == 3) return byNonDigit;
    return null;
  }

  /// Resolves a typed year. A two digit year is mapped into the supported range
  /// at the year nearest the current selection.
  int _resolveYear(int typed) {
    if (!widget.format.twoDigitYear || typed >= 100) return typed;
    final firstYear = widget.system.decode(widget.firstDate).year;
    final lastYear = widget.system.decode(widget.lastDate).year;
    final pivot = widget.system.decode(widget.selectedDate).year;
    int? best;
    for (var year = firstYear; year <= lastYear; year++) {
      if (year % 100 == typed) {
        if (best == null || (year - pivot).abs() < (best - pivot).abs()) {
          best = year;
        }
      }
    }
    return best ?? ((pivot ~/ 100) * 100 + typed);
  }

  /// Parses [text] in the active calendar following [format], returning the
  /// canonical `DateTime`, or null if it is malformed or invalid.
  DateTime? _parse(String text) {
    final parts = _split(text);
    if (parts == null) return null;
    int? day;
    int? month;
    int? year;
    for (var i = 0; i < 3; i++) {
      final value = int.tryParse(parts[i]);
      if (value == null) return null;
      switch (widget.format.order[i]) {
        case DrumDateField.day:
          day = value;
        case DrumDateField.month:
          month = value;
        case DrumDateField.year:
          year = value;
      }
    }
    final resolvedYear = _resolveYear(year!);
    if (!widget.system.isValid(resolvedYear, month!, day!)) return null;
    return widget.system.encode(resolvedYear, month, day);
  }

  void _onChanged(String text) {
    final date = _parse(text);
    if (date == null) {
      setState(() {
        _errorText = widget.errorFormatText ??
            'Invalid format. Use ${widget.format.displayPattern}';
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

  /// Escapes the characters that are special inside a regular expression
  /// character class.
  String _escapeForCharClass(String input) =>
      input.replaceAllMapped(RegExp(r'[\^\]\\-]'), (m) => '\\${m[0]}');

  @override
  Widget build(BuildContext context) {
    final separator = _escapeForCharClass(widget.format.separator);
    final allow = RegExp('[0-9٠-٩۰-۹$separator]');
    final maxLength =
        2 + 2 + widget.format.yearDigits + 2 * widget.format.separator.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        autofocus: false,
        inputFormatters: [
          FilteringTextInputFormatter.allow(allow),
          LengthLimitingTextInputFormatter(maxLength),
        ],
        decoration: (widget.decoration ??
                const InputDecoration(border: OutlineInputBorder()))
            .copyWith(
          labelText: widget.fieldLabelText ?? 'Enter Date',
          hintText: widget.fieldHintText ?? widget.format.displayPattern,
          errorText: _errorText,
          helperText: _helperText,
          suffixIcon: const Icon(Icons.edit_calendar_outlined),
        ),
        onChanged: _onChanged,
      ),
    );
  }
}
