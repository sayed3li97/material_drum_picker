import 'package:flutter/material.dart';

import '../../calendar/chinese/chinese_calendar_system.dart';
import '../../calendar/drum_calendar_system.dart';
import '../../calendar/gregorian_calendar_system.dart';
import '../../calendar/hijri/hijri_calendar_system.dart';
import '../../models/drum_calendar_type.dart';
import '../../theme/drum_picker_theme.dart';
import '../../utils/drum_date_utils.dart';
import 'range_calendar.dart';

/// The calendar system, tokens, clamped dates, and effective day predicate
/// shared by the range and multi pickers and their dialogs.
class RangeConfig {
  /// Creates a resolved configuration.
  RangeConfig({
    required this.system,
    required this.tokens,
    required this.first,
    required this.last,
    required this.current,
    required this.locale,
    required this.isSelectable,
  });

  /// The active calendar system.
  final DrumCalendarSystem system;

  /// Resolved visual tokens.
  final DrumPickerResolved tokens;

  /// The clamped earliest date.
  final DateTime first;

  /// The clamped latest date.
  final DateTime last;

  /// The date marked as today.
  final DateTime current;

  /// The resolved locale.
  final Locale locale;

  /// Whether a day passes weekends, holidays, and the caller's predicate.
  final bool Function(DateTime day) isSelectable;

  /// Resolves the configuration from [context] and the picker parameters.
  static RangeConfig of(
    BuildContext context, {
    required DateTime firstDate,
    required DateTime lastDate,
    DateTime? currentDate,
    required DrumCalendarType calendar,
    DrumCalendarSystem? calendarSystem,
    Set<int>? disabledWeekdays,
    Set<DateTime>? holidays,
    SelectableDayPredicate? selectableDayPredicate,
    Locale? locale,
    DrumPickerTheme? theme,
  }) {
    final system = calendarSystem ??
        switch (calendar) {
          DrumCalendarType.hijri => const HijriCalendarSystem(),
          DrumCalendarType.chinese => const ChineseCalendarSystem(),
          DrumCalendarType.gregorian => const GregorianCalendarSystem(),
        };
    final lo = DrumDateUtils.dateOnly(firstDate);
    final hi = DrumDateUtils.dateOnly(lastDate);
    final sysLo = DrumDateUtils.dateOnly(system.minSupported);
    final sysHi = DrumDateUtils.dateOnly(system.maxSupported);
    final first = lo.isBefore(sysLo) ? sysLo : lo;
    final last = hi.isAfter(sysHi) ? sysHi : hi;
    final holidaySet = {
      for (final h in holidays ?? const <DateTime>{}) DrumDateUtils.dateOnly(h),
    };

    bool isSelectable(DateTime day) {
      final d = DrumDateUtils.dateOnly(day);
      if (disabledWeekdays?.contains(d.weekday) ?? false) return false;
      if (holidaySet.contains(d)) return false;
      return selectableDayPredicate?.call(day) ?? true;
    }

    return RangeConfig(
      system: system,
      tokens: DrumPickerTheme.resolve(context, theme),
      first: first,
      last: last,
      current: DrumDateUtils.dateOnly(currentDate ?? DateTime.now()),
      locale:
          locale ?? Localizations.maybeLocaleOf(context) ?? const Locale('en'),
      isSelectable: isSelectable,
    );
  }
}

/// An inline calendar that selects a contiguous date range.
///
/// A header-less grid: tap a start day, then an end day. `onChanged` fires with
/// the complete [DateTimeRange] (or null while the range is incomplete). On top
/// of the standard range UI it accepts this package's extras: alternative
/// [calendar]s, working day and holiday rules, a custom [firstDayOfWeek], a
/// [selectableDayPredicate], and per instance [theme] overrides.
class DrumDateRangePicker extends StatelessWidget {
  /// Creates an inline range calendar.
  const DrumDateRangePicker({
    super.key,
    required this.firstDate,
    required this.lastDate,
    required this.onChanged,
    this.initialDateRange,
    this.currentDate,
    this.calendar = DrumCalendarType.gregorian,
    this.calendarSystem,
    this.disabledWeekdays,
    this.holidays,
    this.firstDayOfWeek,
    this.selectableDayPredicate,
    this.theme,
    this.locale,
  });

  /// The earliest selectable date.
  final DateTime firstDate;

  /// The latest selectable date.
  final DateTime lastDate;

  /// Called with the complete range, or null while it is incomplete.
  final ValueChanged<DateTimeRange?> onChanged;

  /// The initially selected range.
  final DateTimeRange? initialDateRange;

  /// The date marked as today.
  final DateTime? currentDate;

  /// The built in calendar system.
  final DrumCalendarType calendar;

  /// A custom calendar system, taking precedence over [calendar].
  final DrumCalendarSystem? calendarSystem;

  /// Weekdays that cannot be selected (`DateTime.monday` to `DateTime.sunday`).
  final Set<int>? disabledWeekdays;

  /// Specific dates that cannot be selected.
  final Set<DateTime>? holidays;

  /// First day of the week (`DateTime.monday` to `DateTime.sunday`).
  final int? firstDayOfWeek;

  /// A predicate restricting selectable days.
  final SelectableDayPredicate? selectableDayPredicate;

  /// Per instance visual token overrides.
  final DrumPickerTheme? theme;

  /// Locale override.
  final Locale? locale;

  @override
  Widget build(BuildContext context) {
    final config = RangeConfig.of(
      context,
      firstDate: firstDate,
      lastDate: lastDate,
      currentDate: currentDate,
      calendar: calendar,
      calendarSystem: calendarSystem,
      disabledWeekdays: disabledWeekdays,
      holidays: holidays,
      selectableDayPredicate: selectableDayPredicate,
      locale: locale,
      theme: theme,
    );
    return RangeCalendar(
      firstDate: config.first,
      lastDate: config.last,
      currentDate: config.current,
      system: config.system,
      locale: config.locale,
      tokens: config.tokens,
      multiSelect: false,
      firstDayOfWeek: firstDayOfWeek,
      selectableDayPredicate: config.isSelectable,
      initialRange: initialDateRange,
      onRangeChanged: (start, end) => onChanged(
        start != null && end != null
            ? DateTimeRange(start: start, end: end)
            : null,
      ),
    );
  }
}

/// An inline calendar that selects any number of individual days.
///
/// A header-less grid: tap days to add or remove them. `onChanged` fires with
/// the sorted list of selected days. Accepts the same extras as
/// [DrumDateRangePicker].
class DrumMultiDatePicker extends StatelessWidget {
  /// Creates an inline multi date calendar.
  const DrumMultiDatePicker({
    super.key,
    required this.firstDate,
    required this.lastDate,
    required this.onChanged,
    this.initialDates,
    this.currentDate,
    this.calendar = DrumCalendarType.gregorian,
    this.calendarSystem,
    this.disabledWeekdays,
    this.holidays,
    this.firstDayOfWeek,
    this.selectableDayPredicate,
    this.theme,
    this.locale,
  });

  /// The earliest selectable date.
  final DateTime firstDate;

  /// The latest selectable date.
  final DateTime lastDate;

  /// Called with the sorted set of selected days.
  final ValueChanged<List<DateTime>> onChanged;

  /// The initially selected days.
  final List<DateTime>? initialDates;

  /// The date marked as today.
  final DateTime? currentDate;

  /// The built in calendar system.
  final DrumCalendarType calendar;

  /// A custom calendar system, taking precedence over [calendar].
  final DrumCalendarSystem? calendarSystem;

  /// Weekdays that cannot be selected (`DateTime.monday` to `DateTime.sunday`).
  final Set<int>? disabledWeekdays;

  /// Specific dates that cannot be selected.
  final Set<DateTime>? holidays;

  /// First day of the week (`DateTime.monday` to `DateTime.sunday`).
  final int? firstDayOfWeek;

  /// A predicate restricting selectable days.
  final SelectableDayPredicate? selectableDayPredicate;

  /// Per instance visual token overrides.
  final DrumPickerTheme? theme;

  /// Locale override.
  final Locale? locale;

  @override
  Widget build(BuildContext context) {
    final config = RangeConfig.of(
      context,
      firstDate: firstDate,
      lastDate: lastDate,
      currentDate: currentDate,
      calendar: calendar,
      calendarSystem: calendarSystem,
      disabledWeekdays: disabledWeekdays,
      holidays: holidays,
      selectableDayPredicate: selectableDayPredicate,
      locale: locale,
      theme: theme,
    );
    return RangeCalendar(
      firstDate: config.first,
      lastDate: config.last,
      currentDate: config.current,
      system: config.system,
      locale: config.locale,
      tokens: config.tokens,
      multiSelect: true,
      firstDayOfWeek: firstDayOfWeek,
      selectableDayPredicate: config.isSelectable,
      initialDates: initialDates,
      onDatesChanged: onChanged,
    );
  }
}
