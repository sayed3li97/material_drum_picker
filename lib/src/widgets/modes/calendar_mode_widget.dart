import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../utils/drum_date_utils.dart';
import '../internal/day_cell.dart';

/// The calendar grid input mode.
class CalendarModeWidget extends StatefulWidget {
  /// Creates the calendar mode body.
  const CalendarModeWidget({
    super.key,
    required this.selectedDate,
    required this.firstDate,
    required this.lastDate,
    required this.currentDate,
    required this.onChanged,
    this.selectableDayPredicate,
    this.localeName,
  });

  /// The currently-selected date.
  final DateTime selectedDate;

  /// The earliest selectable date.
  final DateTime firstDate;

  /// The latest selectable date.
  final DateTime lastDate;

  /// The date highlighted as "today".
  final DateTime currentDate;

  /// Called with the new date when a day is tapped.
  final ValueChanged<DateTime> onChanged;

  /// Optional predicate restricting selectable days.
  final bool Function(DateTime day)? selectableDayPredicate;

  /// The `intl` locale used to format the month/year header.
  final String? localeName;

  @override
  State<CalendarModeWidget> createState() => _CalendarModeWidgetState();
}

class _CalendarModeWidgetState extends State<CalendarModeWidget> {
  late DateTime _displayedMonth;
  bool _showYearGrid = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _displayedMonth =
        DateTime(widget.selectedDate.year, widget.selectedDate.month);
  }

  @override
  void didUpdateWidget(CalendarModeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!DrumDateUtils.isSameMonth(
        widget.selectedDate, oldWidget.selectedDate)) {
      _displayedMonth =
          DateTime(widget.selectedDate.year, widget.selectedDate.month);
    }
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

  bool get _canGoPrev => _displayedMonth
      .isAfter(DateTime(widget.firstDate.year, widget.firstDate.month));

  bool get _canGoNext => _displayedMonth
      .isBefore(DateTime(widget.lastDate.year, widget.lastDate.month));

  void _changeMonth(int delta) {
    setState(() {
      _displayedMonth = DrumDateUtils.addMonths(_displayedMonth, delta);
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
    setState(() {
      _displayedMonth = DateTime(target.year, target.month);
    });
    // Only commit the selection if the target day is itself selectable.
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
    final label = DateFormat.yMMMM(widget.localeName).format(_displayedMonth);
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
    final year = _displayedMonth.year;
    final month = _displayedMonth.month;
    final daysInMonth = DrumDateUtils.daysInMonth(year, month);

    // weekday: Mon=1..Sun=7; convert to 0-based from firstDayOfWeek.
    final firstWeekday = DateTime(year, month).weekday % 7; // Sun=0..Sat=6
    final leading = (firstWeekday - firstDayOfWeek + 7) % 7;

    final cells = <Widget>[];
    for (var i = 0; i < leading; i++) {
      cells.add(const SizedBox(width: 44, height: 44));
    }
    for (var day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      cells.add(DayCell(
        day: day,
        isEnabled: _isSelectable(date),
        isSelected: DrumDateUtils.isSameDay(date, widget.selectedDate),
        isToday: DrumDateUtils.isSameDay(date, widget.currentDate),
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
    final firstYear = widget.firstDate.year;
    final lastYear = widget.lastDate.year;
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
    final scheme = Theme.of(context).colorScheme;
    final isSelected = year == _displayedMonth.year;
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Material(
        color: isSelected ? scheme.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            setState(() {
              _displayedMonth = DateTime(year, _displayedMonth.month);
              _showYearGrid = false;
            });
          },
          child: Center(
            child: Text(
              '$year',
              style: TextStyle(
                color: isSelected ? scheme.onPrimary : scheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
