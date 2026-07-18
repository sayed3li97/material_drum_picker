import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../calendar/calendar_date.dart';
import '../../calendar/drum_calendar_system.dart';
import '../../models/drum_event_marker.dart';
import '../../models/drum_precision.dart';
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
    this.firstDayOfWeek,
    this.precision = DrumPrecision.day,
    this.selectableDayPredicate,
    this.eventLoader,
    this.markerBuilder,
    this.maxEventMarkers = kDefaultMaxEventMarkers,
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

  /// Overrides the first day of the week (`DateTime.monday` == 1 to
  /// `DateTime.sunday` == 7). Null uses the locale default.
  final int? firstDayOfWeek;

  /// The selection granularity. At [DrumPrecision.month] the grid is a month
  /// chooser; at [DrumPrecision.year] it is a year chooser.
  final DrumPrecision precision;

  /// Called with the new date when a day is tapped.
  final ValueChanged<DateTime> onChanged;

  /// Optional predicate restricting selectable days.
  final bool Function(DateTime day)? selectableDayPredicate;

  /// Returns the event markers for a given day, or null for no events.
  final DrumEventLoader? eventLoader;

  /// Optional builder that replaces the default marker dots.
  final DrumMarkerBuilder? markerBuilder;

  /// The maximum number of default marker dots rendered under a day.
  final int maxEventMarkers;

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
    // Arrow-key day navigation only makes sense at day precision.
    if (widget.precision != DrumPrecision.day) return KeyEventResult.ignored;
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
          children: _bodyChildren(context),
        ),
      ),
    );
  }

  List<Widget> _bodyChildren(BuildContext context) {
    switch (widget.precision) {
      case DrumPrecision.year:
        // The year chooser is the whole body; it scrolls the supported range.
        return [_buildYearGrid(context)];
      case DrumPrecision.month:
        return [
          _buildHeader(context),
          if (_showYearGrid)
            _buildYearGrid(context)
          else
            _buildMonthGrid(context),
        ];
      case DrumPrecision.day:
        return [
          _buildHeader(context),
          if (_showYearGrid)
            _buildYearGrid(context)
          else ...[
            _buildWeekdayRow(context),
            _buildDayGrid(context),
          ],
        ];
    }
  }

  Widget _buildHeader(BuildContext context) {
    // At month precision the header shows just the year and steps by year; at
    // day precision it shows the month and year and steps by month.
    final byMonth = widget.precision == DrumPrecision.day;
    final label = byMonth
        ? '${widget.system.monthLabel(_year, _month, numeric: false, abbreviated: false, locale: widget.locale)} '
            '${DrumNumerals.format(_year, _localeName)}'
        : DrumNumerals.format(_year, _localeName);
    final localizations = MaterialLocalizations.of(context);
    final canPrev = byMonth ? _canGoPrev : _canGoPrevYear;
    final canNext = byMonth ? _canGoNext : _canGoNextYear;
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
            tooltip: localizations.previousMonthTooltip,
            onPressed: canPrev
                ? () => byMonth ? _changeMonth(-1) : _changeYear(-1)
                : null,
            icon: const Icon(Icons.chevron_left),
          ),
          IconButton(
            tooltip: localizations.nextMonthTooltip,
            onPressed: canNext
                ? () => byMonth ? _changeMonth(1) : _changeYear(1)
                : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ],
    );
  }

  bool get _canGoPrevYear => _year > _firstYm.year;
  bool get _canGoNextYear => _year < _lastYm.year;

  void _changeYear(int delta) {
    final y = (_year + delta).clamp(_firstYm.year, _lastYm.year);
    setState(() {
      _year = y;
      _month = _month.clamp(1, widget.system.monthsInYear(y));
    });
  }

  /// Whether month [month] of [year] overlaps the selectable range at all, so a
  /// mid-month firstDate/lastDate still leaves that boundary month selectable.
  bool _monthInRange(int year, int month) {
    final start = widget.system.encode(year, month, 1);
    final end = widget.system
        .encode(year, month, widget.system.daysInMonth(year, month));
    return !end.isBefore(widget.firstDate) && !start.isAfter(widget.lastDate);
  }

  Widget _buildMonthGrid(BuildContext context) {
    final months = widget.system.monthsInYear(_year);
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.2,
      children: [
        for (var m = 1; m <= months; m++) _buildMonthTile(context, m),
      ],
    );
  }

  Widget _buildMonthTile(BuildContext context, int month) {
    final tokens = widget.tokens;
    final selected = widget.system.decode(widget.selectedDate);
    final today = widget.system.decode(widget.currentDate);
    final isSelected = selected.year == _year && selected.month == month;
    final isToday = today.year == _year && today.month == month;
    final isEnabled = _monthInRange(_year, month);
    final label = widget.system.monthLabel(_year, month,
        numeric: false, abbreviated: true, locale: widget.locale);
    Color foreground = tokens.dayForegroundColor;
    if (isSelected) {
      foreground = tokens.selectedDayForegroundColor;
    } else if (!isEnabled) {
      foreground = tokens.disabledDayColor;
    } else if (isToday) {
      foreground = tokens.todayColor;
    }
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Material(
        color:
            isSelected ? tokens.selectedDayBackgroundColor : Colors.transparent,
        shape: isToday && !isSelected
            ? const StadiumBorder()
                .copyWith(side: BorderSide(color: tokens.todayColor))
            : const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: isEnabled
              ? () => widget.onChanged(widget.system.encode(_year, month, 1))
              : null,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: foreground,
                fontWeight: isSelected || isToday ? FontWeight.w600 : null,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// The 0 based (0 == Sunday .. 6 == Saturday) index of the first weekday,
  /// from the [CalendarModeWidget.firstDayOfWeek] override or the locale.
  int _firstDayIndex(MaterialLocalizations localizations) =>
      widget.firstDayOfWeek != null
          ? widget.firstDayOfWeek! % 7
          : localizations.firstDayOfWeekIndex;

  Widget _buildWeekdayRow(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final firstDay = _firstDayIndex(localizations);
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
    final firstDayOfWeek = _firstDayIndex(localizations);
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
      final markers =
          widget.eventLoader?.call(date) ?? const <DrumEventMarker>[];
      cells.add(DayCell(
        day: day,
        label: DrumNumerals.format(day, _localeName),
        isEnabled: _isSelectable(date),
        isSelected: DrumDateUtils.isSameDay(date, widget.selectedDate),
        isToday: DrumDateUtils.isSameDay(date, widget.currentDate),
        tokens: widget.tokens,
        markers: markers,
        markerBuilder: widget.markerBuilder,
        markerDate: date,
        maxMarkers: widget.maxEventMarkers,
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
    // At year precision the grid IS the selection, so it highlights the actual
    // selected year and a tap commits; otherwise it only navigates.
    final yearPrecision = widget.precision == DrumPrecision.year;
    final isSelected = yearPrecision
        ? widget.system.decode(widget.selectedDate).year == year
        : year == _year;
    final isToday =
        yearPrecision && widget.system.decode(widget.currentDate).year == year;
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Material(
        color:
            isSelected ? tokens.selectedDayBackgroundColor : Colors.transparent,
        shape: isToday && !isSelected
            ? StadiumBorder(side: BorderSide(color: tokens.todayColor))
            : const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            if (yearPrecision) {
              widget.onChanged(widget.system.encode(year, 1, 1));
            } else {
              setState(() {
                _year = year;
                _month = _month.clamp(1, widget.system.monthsInYear(year));
                _showYearGrid = false;
              });
            }
          },
          child: Center(
            child: Text(
              DrumNumerals.format(year, _localeName),
              style: TextStyle(
                color: isSelected
                    ? tokens.selectedDayForegroundColor
                    : isToday
                        ? tokens.todayColor
                        : tokens.dayForegroundColor,
                fontWeight: isSelected || isToday ? FontWeight.w600 : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
