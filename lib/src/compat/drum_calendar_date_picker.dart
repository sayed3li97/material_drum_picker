import 'package:flutter/material.dart';

import '../calendar/drum_calendar_system.dart';
import '../models/drum_calendar_type.dart';
import '../models/drum_picker_mode.dart';
import '../theme/drum_picker_theme.dart';
import '../widgets/drum_picker.dart';

/// A drop in replacement for Flutter's `CalendarDatePicker`.
///
/// Mirrors `CalendarDatePicker`'s constructor (the same `initialDate`,
/// `firstDate`, `lastDate`, `currentDate`, `onDateChanged`,
/// `onDisplayedMonthChanged`, `initialCalendarMode`, and
/// `selectableDayPredicate`), so an existing call can be migrated by changing
/// only the widget name:
///
/// ```dart
/// // Before
/// CalendarDatePicker(
///   initialDate: _date,
///   firstDate: DateTime(2020),
///   lastDate: DateTime(2030),
///   onDateChanged: (d) => setState(() => _date = d),
/// );
///
/// // After (header less inline calendar grid)
/// DrumCalendarDatePicker(
///   initialDate: _date,
///   firstDate: DateTime(2020),
///   lastDate: DateTime(2030),
///   onDateChanged: (d) => setState(() => _date = d),
/// );
/// ```
///
/// On top of the original API it also exposes this package's extras, which the
/// Material widget does not support: alternative calendars ([calendar],
/// [calendarSystem]), working day and holiday rules ([disabledWeekdays],
/// [holidays]), a custom [firstDayOfWeek], and per instance [theme] overrides.
class DrumCalendarDatePicker extends StatelessWidget {
  /// Creates a header less inline calendar, matching `CalendarDatePicker`.
  const DrumCalendarDatePicker({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    this.currentDate,
    required this.onDateChanged,
    this.onDisplayedMonthChanged,
    this.initialCalendarMode = DatePickerMode.day,
    this.selectableDayPredicate,
    this.calendar = DrumCalendarType.gregorian,
    this.calendarSystem,
    this.disabledWeekdays,
    this.holidays,
    this.firstDayOfWeek,
    this.theme,
    this.locale,
  });

  /// The initially selected date.
  final DateTime? initialDate;

  /// The earliest selectable date.
  final DateTime firstDate;

  /// The latest selectable date.
  final DateTime lastDate;

  /// The date marked as today. Defaults to `DateTime.now()`.
  final DateTime? currentDate;

  /// Called when the user selects a date.
  final ValueChanged<DateTime> onDateChanged;

  /// Called when the displayed month changes. Accepted for API compatibility;
  /// emitted on selection in this implementation.
  final ValueChanged<DateTime>? onDisplayedMonthChanged;

  /// Accepted for API compatibility with `CalendarDatePicker`. The grid always
  /// opens on the day view.
  final DatePickerMode initialCalendarMode;

  /// A predicate restricting which days are selectable.
  final SelectableDayPredicate? selectableDayPredicate;

  /// The built in calendar system to present dates in.
  final DrumCalendarType calendar;

  /// A custom calendar system, taking precedence over [calendar].
  final DrumCalendarSystem? calendarSystem;

  /// Weekdays that cannot be selected (`DateTime.monday` to `DateTime.sunday`).
  final Set<int>? disabledWeekdays;

  /// Specific dates that cannot be selected.
  final Set<DateTime>? holidays;

  /// The first day of the week (`DateTime.monday` to `DateTime.sunday`).
  final int? firstDayOfWeek;

  /// Per instance visual token overrides.
  final DrumPickerTheme? theme;

  /// Locale override.
  final Locale? locale;

  @override
  Widget build(BuildContext context) {
    return DrumPicker(
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      currentDate: currentDate,
      initialMode: DrumPickerMode.calendar,
      showModeToggle: false,
      showHeader: false,
      showActions: false,
      showQuickSelects: false,
      selectableDayPredicate: selectableDayPredicate,
      calendar: calendar,
      calendarSystem: calendarSystem,
      disabledWeekdays: disabledWeekdays,
      holidays: holidays,
      firstDayOfWeek: firstDayOfWeek,
      theme: theme,
      locale: locale,
      onChanged: (date) {
        onDateChanged(date);
        onDisplayedMonthChanged?.call(DateTime(date.year, date.month));
      },
    );
  }
}
