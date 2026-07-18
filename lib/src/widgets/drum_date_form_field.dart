import 'package:flutter/material.dart';

import '../calendar/chinese/chinese_calendar_system.dart';
import '../calendar/drum_calendar_system.dart';
import '../calendar/gregorian_calendar_system.dart';
import '../calendar/hijri/hijri_calendar_system.dart';
import '../calendar/jalali/jalali_calendar_system.dart';
import '../models/drum_calendar_type.dart';
import '../models/drum_column_order.dart';
import '../models/drum_date_format.dart';
import '../models/drum_month_format.dart';
import '../models/drum_picker_labels.dart';
import '../models/drum_picker_mode.dart';
import '../models/drum_precision.dart';
import '../theme/drum_picker_theme.dart';
import '../utils/drum_locale_utils.dart';
import '../utils/drum_numerals.dart';
import 'drum_picker.dart';
import 'drum_picker_dialog.dart';

/// Formats a picked [DateTime] into the string shown in the field.
typedef DrumDateFieldFormatter = String Function(DateTime value);

/// A [FormField] that shows the selected date in a decorated, read-only field
/// and opens a `DrumPicker` dialog when tapped.
///
/// It plugs a drum date picker into a Flutter [Form] the way [TextFormField]
/// plugs in a text field: it participates in [Form.validate], [Form.save], and
/// [Form.reset], reports errors through its [InputDecoration], and calls
/// [onChanged] and [onSaved]. The value is always a Gregorian `DateTime`, even
/// when a non Gregorian [calendar] is shown.
///
/// ```dart
/// DrumDateFormField(
///   firstDate: DateTime(1900),
///   lastDate: DateTime.now(),
///   decoration: const InputDecoration(labelText: 'Date of birth'),
///   validator: (value) => value == null ? 'Required' : null,
///   onSaved: (value) => _dob = value,
/// )
/// ```
///
/// By default the field shows the date in the active [calendar] and [locale]
/// (for example a Persian date when `calendar: DrumCalendarType.jalali`). Pass
/// [formatValue] to render it however you like.
class DrumDateFormField extends FormField<DateTime> {
  /// Creates a form field that picks a date with a `DrumPicker` dialog.
  DrumDateFormField({
    super.key,
    super.onSaved,
    super.validator,
    super.restorationId,
    super.initialValue,
    AutovalidateMode? autovalidateMode,
    this.onChanged,
    required this.firstDate,
    required this.lastDate,
    this.currentDate,
    this.calendar = DrumCalendarType.gregorian,
    this.calendarSystem,
    this.precision = DrumPrecision.day,
    this.decoration = const InputDecoration(),
    this.formatValue,
    this.hintText,
    super.enabled = true,
    this.locale,
    this.textDirection,
    this.theme,
    this.labels = const DrumPickerLabels(),
    this.initialPickerMode = DrumPickerMode.calendar,
    this.initialEntryMode,
    this.columnOrder,
    this.monthFormat = DrumMonthFormat.name,
    this.inputFormat = DrumDateFormat.mdy,
    this.disabledWeekdays,
    this.holidays,
    this.firstDayOfWeek,
    this.selectableDayPredicate,
    this.helpText,
    this.confirmText,
    this.cancelText,
    this.useRootNavigator = true,
  }) : super(
          autovalidateMode: autovalidateMode ?? AutovalidateMode.disabled,
          builder: (FormFieldState<DateTime> field) {
            final state = field as _DrumDateFormFieldState;
            final theme = Theme.of(field.context);
            final value = field.value;
            final text = value == null
                ? null
                : (formatValue ?? state._defaultFormat)(value);
            final effectiveDecoration =
                decoration.applyDefaults(theme.inputDecorationTheme).copyWith(
                      errorText: field.errorText,
                      // Route the placeholder to the decoration so the label
                      // and hint lay out correctly instead of overlapping.
                      hintText: decoration.hintText ?? hintText,
                      suffixIcon: decoration.suffixIcon ??
                          const Icon(Icons.calendar_today_outlined),
                    );

            return UnmanagedRestorationScope(
              bucket: field.bucket,
              child: InkWell(
                onTap: enabled ? state._pick : null,
                borderRadius: BorderRadius.circular(4),
                child: InputDecorator(
                  decoration: effectiveDecoration,
                  isEmpty: value == null,
                  isFocused: false,
                  child: text == null
                      ? null
                      : Text(text, style: theme.textTheme.titleMedium),
                ),
              ),
            );
          },
        );

  /// Called when the user picks a new date (or clears it). Not called on
  /// programmatic [FormFieldState.reset].
  final ValueChanged<DateTime?>? onChanged;

  /// The earliest date the user may select.
  final DateTime firstDate;

  /// The latest date the user may select.
  final DateTime lastDate;

  /// The date marked as today in the picker. Defaults to `DateTime.now()`.
  final DateTime? currentDate;

  /// The built in calendar system to present dates in.
  final DrumCalendarType calendar;

  /// A custom calendar system, taking precedence over [calendar].
  final DrumCalendarSystem? calendarSystem;

  /// The selection granularity: a full day (default), a month, or a year. At
  /// month or year precision the picker becomes a month or year picker and the
  /// stored value is the first day of the selected period. The display also
  /// narrows (for example `March 2024` or `2024`) unless [formatValue] is set.
  final DrumPrecision precision;

  /// The decoration around the field. The error text and a default calendar
  /// suffix icon are filled in automatically.
  final InputDecoration decoration;

  /// Formats the selected value for display. Defaults to a calendar and locale
  /// aware medium date.
  final DrumDateFieldFormatter? formatValue;

  /// Placeholder text shown when no date is selected. Prefer
  /// `decoration.hintText`; this is a convenience that maps to the child text.
  final String? hintText;

  /// Locale override for the picker and the default formatting.
  final Locale? locale;

  /// Text direction override for the picker dialog.
  final TextDirection? textDirection;

  /// Per instance visual token overrides for the picker.
  final DrumPickerTheme? theme;

  /// Overridable strings for the picker.
  final DrumPickerLabels labels;

  /// The mode the picker opens in. Defaults to the calendar grid.
  final DrumPickerMode initialPickerMode;

  /// Flutter's [DatePickerEntryMode], mapped onto the picker's mode and toggle.
  /// Takes precedence over [initialPickerMode] when set.
  final DatePickerEntryMode? initialEntryMode;

  /// The drum column order.
  final DrumColumnOrder? columnOrder;

  /// Whether the drum month column shows the month name or its number.
  final DrumMonthFormat monthFormat;

  /// The keyboard input field format.
  final DrumDateFormat inputFormat;

  /// Weekdays that cannot be selected (`DateTime.monday` to `DateTime.sunday`).
  final Set<int>? disabledWeekdays;

  /// Specific dates that cannot be selected.
  final Set<DateTime>? holidays;

  /// The first day of the week (`DateTime.monday` to `DateTime.sunday`).
  final int? firstDayOfWeek;

  /// A predicate restricting which days are selectable.
  final DrumSelectableDayPredicate? selectableDayPredicate;

  /// The picker's help text.
  final String? helpText;

  /// The confirm button label.
  final String? confirmText;

  /// The cancel button label.
  final String? cancelText;

  /// Whether the dialog uses the root navigator.
  final bool useRootNavigator;

  @override
  FormFieldState<DateTime> createState() => _DrumDateFormFieldState();
}

class _DrumDateFormFieldState extends FormFieldState<DateTime> {
  DrumDateFormField get _field => widget as DrumDateFormField;

  DrumCalendarSystem get _system =>
      _field.calendarSystem ??
      switch (_field.calendar) {
        DrumCalendarType.hijri => const HijriCalendarSystem(),
        DrumCalendarType.chinese => const ChineseCalendarSystem(),
        DrumCalendarType.jalali => const JalaliCalendarSystem(),
        DrumCalendarType.gregorian => const GregorianCalendarSystem(),
      };

  // A calendar and locale aware label, narrowed to the field's precision:
  // "Month day, year", "Month year", or "year".
  String _defaultFormat(DateTime value) {
    final localeName = DrumLocaleUtils.toIntlLocale(_field.locale);
    final c = _system.decode(value);
    final year = DrumNumerals.format(c.year, localeName);
    if (_field.precision == DrumPrecision.year) return year;
    final month = _system.monthLabel(
      c.year,
      c.month,
      numeric: false,
      abbreviated: false,
      locale: _field.locale ?? const Locale('en'),
    );
    if (_field.precision == DrumPrecision.month) return '$month $year';
    final day = DrumNumerals.format(c.day, localeName);
    return '$month $day, $year';
  }

  Future<void> _pick() async {
    final picked = await showDrumDatePicker(
      context: context,
      firstDate: _field.firstDate,
      lastDate: _field.lastDate,
      initialDate: value,
      currentDate: _field.currentDate,
      calendar: _field.calendar,
      calendarSystem: _field.calendarSystem,
      precision: _field.precision,
      initialMode: _field.initialPickerMode,
      initialEntryMode: _field.initialEntryMode,
      columnOrder: _field.columnOrder,
      monthFormat: _field.monthFormat,
      inputFormat: _field.inputFormat,
      disabledWeekdays: _field.disabledWeekdays,
      holidays: _field.holidays,
      firstDayOfWeek: _field.firstDayOfWeek,
      selectableDayPredicate: _field.selectableDayPredicate,
      helpText: _field.helpText,
      confirmText: _field.confirmText,
      cancelText: _field.cancelText,
      locale: _field.locale,
      textDirection: _field.textDirection,
      theme: _field.theme,
      labels: _field.labels,
      useRootNavigator: _field.useRootNavigator,
    );
    if (picked == null) return; // cancelled: keep the current value
    didChange(picked);
    _field.onChanged?.call(picked);
  }
}
