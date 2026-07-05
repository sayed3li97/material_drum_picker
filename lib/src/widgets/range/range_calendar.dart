import 'package:flutter/material.dart';

import '../../calendar/calendar_date.dart';
import '../../calendar/drum_calendar_system.dart';
import '../../theme/drum_picker_theme.dart';
import '../../utils/drum_date_utils.dart';
import '../../utils/drum_locale_utils.dart';
import '../../utils/drum_numerals.dart';
import '../internal/day_cell.dart';

/// A controlled calendar grid for range or multi selection in the active
/// [system] calendar. It owns only the displayed month; the selection is held
/// by the parent and reported through [onDaySelected].
///
/// Exposed (non-private) for widget tests. Not part of the public package API;
/// the public surface is `DrumDateRangePicker`, `DrumMultiDatePicker`,
/// `showDrumDateRangePicker`, and `showDrumMultiDatePicker`.
class RangeCalendar extends StatefulWidget {
  /// Creates a controlled range or multi selection grid.
  const RangeCalendar({
    super.key,
    required this.firstDate,
    required this.lastDate,
    required this.currentDate,
    required this.displayAnchor,
    required this.system,
    required this.locale,
    required this.tokens,
    required this.multiSelect,
    required this.onDaySelected,
    this.firstDayOfWeek,
    this.selectableDayPredicate,
    this.rangeStart,
    this.rangeEnd,
    this.selectedDates = const {},
  });

  /// The earliest selectable date.
  final DateTime firstDate;

  /// The latest selectable date.
  final DateTime lastDate;

  /// The date marked as today.
  final DateTime currentDate;

  /// The month to display initially.
  final DateTime displayAnchor;

  /// The active calendar system.
  final DrumCalendarSystem system;

  /// The resolved locale.
  final Locale locale;

  /// Resolved visual tokens.
  final DrumPickerResolved tokens;

  /// Whether this is a multi selection grid (true) or a range grid (false).
  final bool multiSelect;

  /// Called with a selectable day when it is tapped.
  final ValueChanged<DateTime> onDaySelected;

  /// First weekday override (`DateTime.monday` to `DateTime.sunday`).
  final int? firstDayOfWeek;

  /// A predicate restricting selectable days.
  final bool Function(DateTime day)? selectableDayPredicate;

  /// The current range start (range mode).
  final DateTime? rangeStart;

  /// The current range end (range mode).
  final DateTime? rangeEnd;

  /// The current set of selected days (multi mode).
  final Set<DateTime> selectedDates;

  @override
  State<RangeCalendar> createState() => _RangeCalendarState();
}

class _RangeCalendarState extends State<RangeCalendar> {
  late int _year;
  late int _month;

  String? get _localeName => DrumLocaleUtils.toIntlLocale(widget.locale);

  @override
  void initState() {
    super.initState();
    final clamped = DrumDateUtils.clamp(
        widget.displayAnchor, widget.firstDate, widget.lastDate);
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

  bool _dayIsSelected(DateTime date) {
    if (widget.multiSelect) return widget.selectedDates.contains(date);
    return DrumDateUtils.isSameDay(date, widget.rangeStart) ||
        DrumDateUtils.isSameDay(date, widget.rangeEnd);
  }

  bool _dayInRange(DateTime date) {
    if (widget.multiSelect ||
        widget.rangeStart == null ||
        widget.rangeEnd == null) {
      return false;
    }
    return !date.isBefore(widget.rangeStart!) &&
        !date.isAfter(widget.rangeEnd!);
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
      final enabled = _isSelectable(date);
      cells.add(DayCell(
        day: day,
        label: DrumNumerals.format(day, _localeName),
        isEnabled: enabled,
        isSelected: _dayIsSelected(date),
        isInRange: _dayInRange(date),
        isToday: DrumDateUtils.isSameDay(date, widget.currentDate),
        tokens: widget.tokens,
        onTap: () => widget.onDaySelected(date),
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
