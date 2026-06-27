import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../calendar/calendar_date.dart';
import '../../calendar/drum_calendar_system.dart';
import '../../theme/drum_picker_theme.dart';
import '../../utils/drum_date_utils.dart';
import '../../utils/drum_locale_utils.dart';
import '../../utils/drum_numerals.dart';
import '../internal/day_cell.dart';

/// The calendar grid input mode, rendered in the active [system] calendar.
class CalendarModeWidget extends StatefulWidget {
  /// Creates the calendar mode body.
  const CalendarModeWidget({
    super.key,
    required this.selectedDate,
    required this.firstDate,
    required this.lastDate,
    required this.currentDate,
    required this.system,
    required this.locale,
    required this.tokens,
    required this.onChanged,
    this.selectableDayPredicate,
  });

  /// The currently-selected date (canonical Gregorian value).
  final DateTime selectedDate;

  /// The earliest selectable date.
  final DateTime firstDate;

  /// The latest selectable date.
  final DateTime lastDate;

  /// The date highlighted as "today".
  final DateTime currentDate;

  /// The active calendar system.
  final DrumCalendarSystem system;

  /// The resolved locale for names and numerals.
  final Locale locale;

  /// Resolved visual tokens.
  final DrumPickerResolved tokens;

  /// Called with the new date when a day is tapped.
  final ValueChanged<DateTime> onChanged;

  /// Optional predicate restricting selectable days.
  final bool Function(DateTime day)? selectableDayPredicate;

  @override
  State<CalendarModeWidget> createState() => _CalendarModeWidgetState();
}

class _CalendarModeWidgetState extends State<CalendarModeWidget> {
  late int _year;
  late int _month;
  bool _showYearGrid = false;
  final FocusNode _focusNode = FocusNode();

  String? get _localeName => DrumLocaleUtils.toIntlLocale(widget.locale);

  @override
  void initState() {
    super.initState();
    _syncDisplayed(widget.selectedDate);
  }

  @override
  void didUpdateWidget(CalendarModeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!DrumDateUtils.isSameDay(widget.selectedDate, oldWidget.selectedDate)) {
      _syncDisplayed(widget.selectedDate);
    }
  }

  void _syncDisplayed(DateTime date) {
    final c = widget.system.decode(date);
    _year = c.year;
    _month = c.month;
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  bool _isSelectable(DateTime date) {
    return DrumDateUtils.isInRange(date, widget.firstDate, widget.lastDate) &&
        (widget.selectableDayPredicate?.call(date) ?? true);
  }

  // Month navigation is expressed as (year, monthIndex) pairs rather than a
  // single linear index, because a year can have a variable number of months
  // (the Chinese calendar has 12 or 13). Comparison is lexicographic.
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

  void _selectDay(DateTime date) {
    if (!_isSelectable(date)) return;
    widget.onChanged(DrumDateUtils.dateOnly(date));
  }

  void _moveSelection(int dayDelta) {
    final target = widget.selectedDate.add(Duration(days: dayDelta));
    if (!DrumDateUtils.isInRange(target, widget.firstDate, widget.lastDate)) {
      return;
    }
    setState(() => _syncDisplayed(target));
    if (_isSelectable(target)) {
      widget.onChanged(DrumDateUtils.dateOnly(target));
    }
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowLeft:
        _moveSelection(-1);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowRight:
        _moveSelection(1);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowUp:
        _moveSelection(-7);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowDown:
        _moveSelection(7);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.pageUp:
        _changeMonth(-1);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.pageDown:
        _changeMonth(1);
        return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      onKeyEvent: _onKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            if (_showYearGrid)
              _buildYearGrid(context)
            else ...[
              _buildWeekdayRow(context),
              _buildDayGrid(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final monthName = widget.system.monthLabel(_year, _month,
        numeric: false, abbreviated: false, locale: widget.locale);
    final label = '$monthName ${DrumNumerals.format(_year, _localeName)}';
    return Row(
      children: [
        TextButton.icon(
          onPressed: () => setState(() => _showYearGrid = !_showYearGrid),
          icon:
              Icon(_showYearGrid ? Icons.arrow_drop_up : Icons.arrow_drop_down),
          label: Text(label),
        ),
        const Spacer(),
        if (!_showYearGrid) ...[
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
      ],
    );
  }

  Widget _buildWeekdayRow(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final firstDay = localizations.firstDayOfWeekIndex;
    final narrow = localizations.narrowWeekdays;
    return Row(
      children: [
        for (var i = 0; i < 7; i++)
          Expanded(
            child: Center(
              child: Text(
                narrow[(firstDay + i) % 7],
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDayGrid(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final firstDayOfWeek = localizations.firstDayOfWeekIndex;
    final daysInMonth = widget.system.daysInMonth(_year, _month);

    // weekday: Mon=1..Sun=7; convert to 0-based from firstDayOfWeek.
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
        isSelected: DrumDateUtils.isSameDay(date, widget.selectedDate),
        isToday: DrumDateUtils.isSameDay(date, widget.currentDate),
        tokens: widget.tokens,
        onTap: () => _selectDay(date),
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

  Widget _buildYearGrid(BuildContext context) {
    final firstYear = widget.system.decode(widget.firstDate).year;
    final lastYear = widget.system.decode(widget.lastDate).year;
    return SizedBox(
      height: 240,
      child: GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 2.2,
        children: [
          for (var year = firstYear; year <= lastYear; year++)
            _buildYearTile(context, year),
        ],
      ),
    );
  }

  Widget _buildYearTile(BuildContext context, int year) {
    final tokens = widget.tokens;
    final isSelected = year == _year;
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Material(
        color:
            isSelected ? tokens.selectedDayBackgroundColor : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            setState(() {
              _year = year;
              _month = _month.clamp(1, widget.system.monthsInYear(year));
              _showYearGrid = false;
            });
          },
          child: Center(
            child: Text(
              DrumNumerals.format(year, _localeName),
              style: TextStyle(
                color: isSelected
                    ? tokens.selectedDayForegroundColor
                    : tokens.dayForegroundColor,
                fontWeight: isSelected ? FontWeight.w600 : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
