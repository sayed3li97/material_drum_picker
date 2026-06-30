import 'package:flutter/material.dart';

import '../../calendar/chinese/chinese_calendar_system.dart';
import '../../calendar/drum_calendar_system.dart';
import '../../calendar/gregorian_calendar_system.dart';
import '../../calendar/hijri/hijri_calendar_system.dart';
import '../../models/drum_calendar_type.dart';
import '../../models/drum_column_order.dart';
import '../../models/drum_month_format.dart';
import '../../models/drum_picker_labels.dart';
import '../../models/drum_range_mode.dart';
import '../../theme/drum_picker_theme.dart';
import '../../utils/drum_date_utils.dart';
import '../../utils/drum_locale_utils.dart';
import 'range_calendar.dart';
import 'range_drum.dart';

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

/// The body of a date range picker, shared by the inline widget and the dialog.
///
/// Holds the start and end selection and switches between the calendar grid and
/// the two-wheel drum presentation. Exposed for tests; not part of the public
/// package API.
class RangeBody extends StatefulWidget {
  /// Creates a range body.
  const RangeBody({
    super.key,
    required this.config,
    required this.onChanged,
    this.initialDateRange,
    this.initialMode = DrumRangeMode.calendar,
    this.showModeToggle = true,
    this.firstDayOfWeek,
    this.columnOrder,
    this.monthFormat = DrumMonthFormat.name,
    this.labels = const DrumPickerLabels(),
  });

  /// The resolved configuration.
  final RangeConfig config;

  /// Called with the current start and end (either may be null while
  /// incomplete).
  final void Function(DateTime? start, DateTime? end) onChanged;

  /// The initially selected range.
  final DateTimeRange? initialDateRange;

  /// The presentation shown first.
  final DrumRangeMode initialMode;

  /// Whether to show the calendar/drum toggle.
  final bool showModeToggle;

  /// First day of the week.
  final int? firstDayOfWeek;

  /// Drum column order (drum mode).
  final DrumColumnOrder? columnOrder;

  /// Month name or number (drum mode).
  final DrumMonthFormat monthFormat;

  /// Overridable column labels (drum mode).
  final DrumPickerLabels labels;

  @override
  State<RangeBody> createState() => _RangeBodyState();
}

class _RangeBodyState extends State<RangeBody> {
  DateTime? _start;
  DateTime? _end;
  late DrumRangeMode _mode;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
    if (widget.initialDateRange != null) {
      _start = DrumDateUtils.dateOnly(widget.initialDateRange!.start);
      _end = DrumDateUtils.dateOnly(widget.initialDateRange!.end);
    }
    if (_mode == DrumRangeMode.drum) _ensureBothEnds();
  }

  void _ensureBothEnds() {
    _start ??= DrumDateUtils.clamp(
        widget.config.current, widget.config.first, widget.config.last);
    _end ??= _start;
  }

  void _report() => widget.onChanged(_start, _end);

  void _onDayTapped(DateTime date) {
    if (!widget.config.isSelectable(date)) return;
    setState(() {
      if (_start == null || _end != null) {
        _start = date;
        _end = null;
      } else if (date.isBefore(_start!)) {
        _start = date;
      } else {
        _end = date;
      }
    });
    _report();
  }

  void _onStartChanged(DateTime date) {
    setState(() {
      _start = DrumDateUtils.dateOnly(date);
      if (_end != null && _end!.isBefore(_start!)) _end = _start;
    });
    _report();
  }

  void _onEndChanged(DateTime date) {
    setState(() => _end = DrumDateUtils.dateOnly(date));
    _report();
  }

  void _setMode(DrumRangeMode mode) {
    setState(() {
      _mode = mode;
      if (mode == DrumRangeMode.drum) _ensureBothEnds();
    });
    if (mode == DrumRangeMode.drum) _report();
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.config;
    final Widget body;
    if (_mode == DrumRangeMode.drum) {
      body = RangeDrum(
        start: _start!,
        end: _end!,
        firstDate: config.first,
        lastDate: config.last,
        system: config.system,
        locale: config.locale,
        tokens: config.tokens,
        columnOrder: widget.columnOrder ??
            DrumLocaleUtils.columnOrderForLocale(config.locale),
        monthFormat: widget.monthFormat,
        labels: widget.labels,
        startLabel: 'Start',
        endLabel: 'End',
        selectableDayPredicate: config.isSelectable,
        onStartChanged: _onStartChanged,
        onEndChanged: _onEndChanged,
      );
    } else {
      body = RangeCalendar(
        firstDate: config.first,
        lastDate: config.last,
        currentDate: config.current,
        displayAnchor: _start ?? config.current,
        system: config.system,
        locale: config.locale,
        tokens: config.tokens,
        multiSelect: false,
        firstDayOfWeek: widget.firstDayOfWeek,
        selectableDayPredicate: config.isSelectable,
        rangeStart: _start,
        rangeEnd: _end,
        onDaySelected: _onDayTapped,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.showModeToggle)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SegmentedButton<DrumRangeMode>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(
                  value: DrumRangeMode.calendar,
                  icon: Icon(Icons.calendar_today_outlined, size: 18),
                  label: Text('Calendar'),
                ),
                ButtonSegment(
                  value: DrumRangeMode.drum,
                  icon: Icon(Icons.view_day_outlined, size: 18),
                  label: Text('Drum'),
                ),
              ],
              selected: {_mode},
              onSelectionChanged: (s) => _setMode(s.first),
            ),
          ),
        body,
      ],
    );
  }
}

/// An inline date range picker, selectable as a calendar grid or two drum
/// rollers.
///
/// Tap a start day then an end day in the calendar, or scroll the Start and End
/// wheels in drum mode. `onChanged` fires with the complete [DateTimeRange] (or
/// null while the range is incomplete). Set [showModeToggle] to false and
/// [initialMode] to lock a single presentation. Accepts this package's extras:
/// alternative [calendar]s, working day and holiday rules, a custom
/// [firstDayOfWeek], a [selectableDayPredicate], and per instance [theme].
class DrumDateRangePicker extends StatelessWidget {
  /// Creates an inline range picker.
  const DrumDateRangePicker({
    super.key,
    required this.firstDate,
    required this.lastDate,
    required this.onChanged,
    this.initialDateRange,
    this.currentDate,
    this.initialMode = DrumRangeMode.calendar,
    this.showModeToggle = true,
    this.calendar = DrumCalendarType.gregorian,
    this.calendarSystem,
    this.disabledWeekdays,
    this.holidays,
    this.firstDayOfWeek,
    this.columnOrder,
    this.monthFormat = DrumMonthFormat.name,
    this.labels = const DrumPickerLabels(),
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

  /// The presentation shown first. Defaults to [DrumRangeMode.calendar].
  final DrumRangeMode initialMode;

  /// Whether to show the calendar/drum toggle. Defaults to true.
  final bool showModeToggle;

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

  /// Drum column order (drum mode).
  final DrumColumnOrder? columnOrder;

  /// Month name or number on the drum (drum mode).
  final DrumMonthFormat monthFormat;

  /// Overridable column labels (drum mode).
  final DrumPickerLabels labels;

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
    return RangeBody(
      config: config,
      initialDateRange: initialDateRange,
      initialMode: initialMode,
      showModeToggle: showModeToggle,
      firstDayOfWeek: firstDayOfWeek,
      columnOrder: columnOrder,
      monthFormat: monthFormat,
      labels: labels,
      onChanged: (start, end) => onChanged(
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
class DrumMultiDatePicker extends StatefulWidget {
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
  State<DrumMultiDatePicker> createState() => _DrumMultiDatePickerState();
}

class _DrumMultiDatePickerState extends State<DrumMultiDatePicker> {
  final Set<DateTime> _selected = {};

  @override
  void initState() {
    super.initState();
    _selected
        .addAll((widget.initialDates ?? const []).map(DrumDateUtils.dateOnly));
  }

  void _onDayTapped(DateTime date, bool Function(DateTime) isSelectable) {
    if (!isSelectable(date)) return;
    setState(() {
      if (!_selected.remove(date)) _selected.add(date);
    });
    widget.onChanged(_selected.toList()..sort());
  }

  @override
  Widget build(BuildContext context) {
    final config = RangeConfig.of(
      context,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
      currentDate: widget.currentDate,
      calendar: widget.calendar,
      calendarSystem: widget.calendarSystem,
      disabledWeekdays: widget.disabledWeekdays,
      holidays: widget.holidays,
      selectableDayPredicate: widget.selectableDayPredicate,
      locale: widget.locale,
      theme: widget.theme,
    );
    final anchor = _selected.isEmpty
        ? config.current
        : _selected.reduce((a, b) => a.isBefore(b) ? a : b);
    return RangeCalendar(
      firstDate: config.first,
      lastDate: config.last,
      currentDate: config.current,
      displayAnchor: anchor,
      system: config.system,
      locale: config.locale,
      tokens: config.tokens,
      multiSelect: true,
      firstDayOfWeek: widget.firstDayOfWeek,
      selectableDayPredicate: config.isSelectable,
      selectedDates: _selected,
      onDaySelected: (d) => _onDayTapped(d, config.isSelectable),
    );
  }
}
