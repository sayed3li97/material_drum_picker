import 'package:flutter/cupertino.dart'
    show CupertinoDatePickerMode, DatePickerDateOrder;
import 'package:flutter/material.dart';

import '../calendar/drum_calendar_system.dart';
import '../models/drum_calendar_type.dart';
import '../models/drum_column_order.dart';
import '../models/drum_picker_mode.dart';
import '../theme/drum_picker_theme.dart';
import '../widgets/drum_picker.dart';
import '../widgets/drum_time_picker.dart';

/// A drop in replacement for Cupertino's `CupertinoDatePicker`.
///
/// Mirrors `CupertinoDatePicker`'s constructor (the same `mode`,
/// `initialDateTime`, streaming `onDateTimeChanged`, `minimumDate`,
/// `maximumDate`, `minimumYear`, `maximumYear`, `minuteInterval`,
/// `use24hFormat`, `dateOrder`, `backgroundColor`, `showDayOfWeek`, and
/// `itemExtent`), so an existing call can be migrated by changing only the
/// widget name, while gaining a Material 3 look:
///
/// ```dart
/// // Before
/// CupertinoDatePicker(
///   mode: CupertinoDatePickerMode.date,
///   initialDateTime: _date,
///   onDateTimeChanged: (d) => setState(() => _date = d),
/// );
///
/// // After
/// DrumCupertinoDatePicker(
///   mode: CupertinoDatePickerMode.date,
///   initialDateTime: _date,
///   onDateTimeChanged: (d) => setState(() => _date = d),
/// );
/// ```
///
/// It also unlocks options the Cupertino widget does not have: alternative
/// calendars ([calendar], [calendarSystem]), working day and holiday rules
/// ([disabledWeekdays], [holidays]), a [selectableDayPredicate], and per
/// instance [theme] overrides.
///
/// `CupertinoDatePickerMode.monthYear` is approximated with the full date
/// columns (the day column is still shown).
class DrumCupertinoDatePicker extends StatelessWidget {
  /// Creates a header less inline wheel, matching `CupertinoDatePicker`.
  DrumCupertinoDatePicker({
    super.key,
    this.mode = CupertinoDatePickerMode.dateAndTime,
    required this.onDateTimeChanged,
    DateTime? initialDateTime,
    this.minimumDate,
    this.maximumDate,
    this.minimumYear = 1,
    this.maximumYear,
    this.minuteInterval = 1,
    this.use24hFormat = false,
    this.dateOrder,
    this.backgroundColor,
    this.showDayOfWeek = false,
    this.itemExtent = 40.0,
    this.selectableDayPredicate,
    this.calendar = DrumCalendarType.gregorian,
    this.calendarSystem,
    this.disabledWeekdays,
    this.holidays,
    this.theme,
    this.locale,
  })  : initialDateTime = initialDateTime ?? DateTime.now(),
        assert(minuteInterval > 0 && 60 % minuteInterval == 0,
            'minuteInterval must be a positive divisor of 60');

  /// The columns to show. Defaults to [CupertinoDatePickerMode.dateAndTime].
  final CupertinoDatePickerMode mode;

  /// Called whenever the selection changes (streaming, as the wheels settle).
  final ValueChanged<DateTime> onDateTimeChanged;

  /// The initially selected value. Defaults to `DateTime.now()`.
  final DateTime initialDateTime;

  /// The earliest selectable date. Falls back to [minimumYear] when null.
  final DateTime? minimumDate;

  /// The latest selectable date. Falls back to [maximumYear] (or 2100) when
  /// null.
  final DateTime? maximumDate;

  /// The earliest selectable year when [minimumDate] is null. Defaults to 1.
  final int minimumYear;

  /// The latest selectable year when [maximumDate] is null.
  final int? maximumYear;

  /// The granularity of the minute column. Must divide 60.
  final int minuteInterval;

  /// Whether the time uses 24 hour format (no AM/PM column).
  final bool use24hFormat;

  /// The order of the day, month, and year columns. Falls back to the locale
  /// default when null.
  final DatePickerDateOrder? dateOrder;

  /// The background color behind the wheel.
  final Color? backgroundColor;

  /// Whether to show the weekday under each day number in the day column.
  final bool showDayOfWeek;

  /// The height of each wheel item.
  final double itemExtent;

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

  /// Per instance visual token overrides.
  final DrumPickerTheme? theme;

  /// Locale override.
  final Locale? locale;

  DateTime get _firstDate => minimumDate ?? DateTime(minimumYear);
  DateTime get _lastDate =>
      maximumDate ?? DateTime(maximumYear ?? 2100, 12, 31);

  DrumColumnOrder? get _columnOrder => switch (dateOrder) {
        null => null,
        DatePickerDateOrder.dmy => DrumColumnOrder.dmy,
        DatePickerDateOrder.mdy => DrumColumnOrder.mdy,
        DatePickerDateOrder.ymd => DrumColumnOrder.ymd,
        DatePickerDateOrder.ydm => DrumColumnOrder.ydm,
      };

  DrumPickerTheme get _theme =>
      (theme ?? const DrumPickerTheme()).merge(DrumPickerTheme(
        itemExtent: itemExtent,
      ));

  @override
  Widget build(BuildContext context) {
    final Widget inner;
    if (mode == CupertinoDatePickerMode.time) {
      inner = DrumTimePicker(
        initialTime: TimeOfDay.fromDateTime(initialDateTime),
        use24hFormat: use24hFormat,
        minuteInterval: minuteInterval,
        showHeader: false,
        showActions: false,
        theme: _theme,
        locale: locale,
        onChanged: (t) => onDateTimeChanged(DateTime(
          initialDateTime.year,
          initialDateTime.month,
          initialDateTime.day,
          t.hour,
          t.minute,
        )),
      );
    } else {
      inner = DrumPicker(
        initialDate: initialDateTime,
        currentDate: initialDateTime,
        firstDate: _firstDate,
        lastDate: _lastDate,
        initialMode: DrumPickerMode.drum,
        showHeader: false,
        showModeToggle: false,
        showActions: false,
        showQuickSelects: false,
        columnOrder: _columnOrder,
        showDayOfWeekInDrum: showDayOfWeek,
        pickTime: mode == CupertinoDatePickerMode.dateAndTime,
        use24hFormat: use24hFormat,
        minuteInterval: minuteInterval,
        calendar: calendar,
        calendarSystem: calendarSystem,
        disabledWeekdays: disabledWeekdays,
        holidays: holidays,
        selectableDayPredicate: selectableDayPredicate,
        theme: _theme,
        locale: locale,
        onChanged: onDateTimeChanged,
      );
    }
    if (backgroundColor != null) {
      return ColoredBox(color: backgroundColor!, child: inner);
    }
    return inner;
  }
}
