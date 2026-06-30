import 'package:flutter/material.dart';

import '../../calendar/calendar_date.dart';
import '../../calendar/drum_calendar_system.dart';
import '../../theme/drum_picker_theme.dart';
import '../../utils/drum_date_utils.dart';
import '../../utils/drum_locale_utils.dart';
import '../../utils/drum_numerals.dart';
import '../internal/day_cell.dart';

/// A calendar grid that selects a contiguous range, or a set of individual
/// days, in the active [system] calendar.
///
/// Exposed (non-private) for widget tests. Not part of the public package API;
/// the public surface is `DrumDateRangePicker`, `DrumMultiDatePicker`,
/// `showDrumDateRangePicker`, and `showDrumMultiDatePicker`.
class RangeCalendar extends StatefulWidget {
  /// Creates a range or multi selection calendar.
  const RangeCalendar({
    super.key,
    required this.firstDate,
    required this.lastDate,
    required this.currentDate,
    required this.system,
    required this.locale,
    required this.tokens,
    required this.multiSelect,
    this.firstDayOfWeek,
    this.selectableDayPredicate,
    this.initialRange,
    this.initialDates,
    this.onRangeChanged,
    this.onDatesChanged,
  });

  /// The earliest selectable date.
  final DateTime firstDate;

  /// The latest selectable date.
  final DateTime lastDate;

  /// The date marked as today.
  final DateTime currentDate;

  /// The active calendar system.
  final DrumCalendarSystem system;

  /// The resolved locale.
  final Locale locale;

  /// Resolved visual tokens.
  final DrumPickerResolved tokens;

  /// Whether to select a set of days (true) or a contiguous range (false).
  final bool multiSelect;

  /// First weekday override (`DateTime.monday` to `DateTime.sunday`).
  final int? firstDayOfWeek;

  /// A predicate restricting selectable days.
  final bool Function(DateTime day)? selectableDayPredicate;

  /// The initially selected range, in range mode.
  final DateTimeRange? initialRange;

  /// The initially selected days, in multi mode.
  final List<DateTime>? initialDates;

  /// Called with the current start and end as the range is built (either may
  /// be null while the range is incomplete).
  final void Function(DateTime? start, DateTime? end)? onRangeChanged;

  /// Called with the selected days (sorted) in multi mode.
  final ValueChanged<List<DateTime>>? onDatesChanged;

  @override
  State<RangeCalendar> createState() => _RangeCalendarState();
}

class _RangeCalendarState extends State<RangeCalendar> {
  late int _year;
  late int _month;
  DateTime? _start;
  DateTime? _end;
  final Set<DateTime> _selected = {};

  String? get _localeName => DrumLocaleUtils.toIntlLocale(widget.locale);

  @override
  void initState() {
    super.initState();
    if (widget.multiSelect) {
      _selected.addAll(
          (widget.initialDates ?? const []).map(DrumDateUtils.dateOnly));
    } else if (widget.initialRange != null) {
      _start = DrumDateUtils.dateOnly(widget.initialRange!.start);
      _end = DrumDateUtils.dateOnly(widget.initialRange!.end);
    }
    final anchor = _start ??
        (_selected.isEmpty
            ? DrumDateUtils.dateOnly(widget.currentDate)
            : _selected.reduce((a, b) => a.isBefore(b) ? a : b));
    final clamped =
        DrumDateUtils.clamp(anchor, widget.firstDate, widget.lastDate);
    final c = widget.system.decode(clamped);
    _year = c.year;
    _month = c.month;
  }

  bool _isSelectable(DateTime date) =>
      DrumDateUtils.isInRange(date, widget.firstDate, widget.lastDate) &&
      (widget.selectableDayPredicate?.call(date) ?? true);

  CalendarDate get _firstYm => widget.system.decode(widget.firstDate);
  CalendarDate get _lastYm => widget.system.decode(widget.lastDate);

  bool _isBeforeYm(int y1, int m1, int y2, int m2) =>
      y1 < y2 || (y1 == y2 && m1 < m2);

  bool get _canGoPrev =>
      _isBeforeYm(_firstYm.year, _firstYm.month, _year, _month);
  bool get _canGoNext =>
      _isBeforeYm(_year, _month, _lastYm.year, _lastYm.month);

  void _changeMonth(int delta) {
    var y = _year;
    var m = _month;
    for (var i = 0; i < delta.abs(); i++) {
      if (delta > 0) {
        if (m < widget.system.monthsInYear(y)) {
          m++;
        } else {
          y++;
          m = 1;
        }
      } else {
        if (m > 1) {
          m--;
        } else {
          y--;
          m = widget.system.monthsInYear(y);
        }
      }
    }
    if (_isBeforeYm(y, m, _firstYm.year, _firstYm.month)) {
      y = _firstYm.year;
      m = _firstYm.month;
    } else if (_isBeforeYm(_lastYm.year, _lastYm.month, y, m)) {
      y = _lastYm.year;
      m = _lastYm.month;
    }
    setState(() {
      _year = y;
      _month = m;
    });
  }

  void _onTap(DateTime date) {
    if (!_isSelectable(date)) return;
    setState(() {
      if (widget.multiSelect) {
        if (!_selected.remove(date)) _selected.add(date);
        final sorted = _selected.toList()..sort();
        widget.onDatesChanged?.call(sorted);
      } else {
        if (_start == null || _end != null) {
          _start = date;
          _end = null;
        } else if (date.isBefore(_start!)) {
          _start = date;
        } else {
          _end = date;
        }
        widget.onRangeChanged?.call(_start, _end);
      }
    });
  }

  bool _dayIsSelected(DateTime date) {
    if (widget.multiSelect) return _selected.contains(date);
    return DrumDateUtils.isSameDay(date, _start) ||
        DrumDateUtils.isSameDay(date, _end);
  }

  bool _dayInRange(DateTime date) {
    if (widget.multiSelect || _start == null || _end == null) return false;
    return !date.isBefore(_start!) && !date.isAfter(_end!);
  }

  int _firstDayIndex(MaterialLocalizations l) => widget.firstDayOfWeek != null
      ? widget.firstDayOfWeek! % 7
      : l.firstDayOfWeekIndex;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context),
          _buildWeekdayRow(context),
          _buildDayGrid(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final monthName = widget.system.monthLabel(_year, _month,
        numeric: false, abbreviated: false, locale: widget.locale);
    final label = '$monthName ${DrumNumerals.format(_year, _localeName)}';
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(label, style: Theme.of(context).textTheme.titleSmall),
        ),
        const Spacer(),
        IconButton(
          tooltip: MaterialLocalizations.of(context).previousMonthTooltip,
          onPressed: _canGoPrev ? () => _changeMonth(-1) : null,
          icon: const Icon(Icons.chevron_left),
        ),
        IconButton(
          tooltip: MaterialLocalizations.of(context).nextMonthTooltip,
          onPressed: _canGoNext ? () => _changeMonth(1) : null,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  Widget _buildWeekdayRow(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final firstDay = _firstDayIndex(localizations);
    final narrow = localizations.narrowWeekdays;
    return Row(
      children: [
        for (var i = 0; i < 7; i++)
          Expanded(
            child: Center(
              child: Text(narrow[(firstDay + i) % 7],
                  style: Theme.of(context).textTheme.bodySmall),
            ),
          ),
      ],
    );
  }

  Widget _buildDayGrid(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final firstDayOfWeek = _firstDayIndex(localizations);
    final daysInMonth = widget.system.daysInMonth(_year, _month);
    final firstWeekday = widget.system.encode(_year, _month, 1).weekday % 7;
    final leading = (firstWeekday - firstDayOfWeek + 7) % 7;

    final cells = <Widget>[];
    for (var i = 0; i < leading; i++) {
      cells.add(const SizedBox(width: 44, height: 44));
    }
    for (var day = 1; day <= daysInMonth; day++) {
      final date = widget.system.encode(_year, _month, day);
      cells.add(DayCell(
        day: day,
        label: DrumNumerals.format(day, _localeName),
        isEnabled: _isSelectable(date),
        isSelected: _dayIsSelected(date),
        isInRange: _dayInRange(date),
        isToday: DrumDateUtils.isSameDay(date, widget.currentDate),
        tokens: widget.tokens,
        onTap: () => _onTap(date),
      ));
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1,
      children: cells,
    );
  }
}
