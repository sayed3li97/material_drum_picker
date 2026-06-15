import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/drum_column_order.dart';
import '../../theme/drum_picker_theme.dart';
import '../../utils/drum_date_utils.dart';
import '../internal/drum_column.dart';

/// The drum-wheel input mode: scrollable day/month/year columns.
class DrumModeWidget extends StatefulWidget {
  /// Creates the drum mode body.
  const DrumModeWidget({
    super.key,
    required this.selectedDate,
    required this.firstDate,
    required this.lastDate,
    required this.columnOrder,
    required this.showDayOfWeek,
    required this.tokens,
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

  /// The resolved column order.
  final DrumColumnOrder columnOrder;

  /// Whether to show the weekday abbreviation under each day number.
  final bool showDayOfWeek;

  /// Resolved visual tokens.
  final DrumPickerResolved tokens;

  /// Called with the new date whenever a column settles.
  final ValueChanged<DateTime> onChanged;

  /// Optional predicate restricting selectable days.
  final bool Function(DateTime day)? selectableDayPredicate;

  /// The `intl` locale used to format month and weekday names.
  final String? localeName;

  @override
  State<DrumModeWidget> createState() => _DrumModeWidgetState();
}

class _DrumModeWidgetState extends State<DrumModeWidget> {
  late int _year;
  late int _month;
  late int _day;

  int get _firstYear => widget.firstDate.year;
  int get _lastYear => widget.lastDate.year;

  @override
  void initState() {
    super.initState();
    _syncFrom(widget.selectedDate);
  }

  @override
  void didUpdateWidget(DrumModeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!DrumDateUtils.isSameDay(widget.selectedDate, _assembled)) {
      setState(() => _syncFrom(widget.selectedDate));
    }
  }

  DateTime get _assembled => DateTime(_year, _month, _day);

  void _syncFrom(DateTime date) {
    _year = date.year.clamp(_firstYear, _lastYear);
    _month = date.month;
    final maxDay = DrumDateUtils.daysInMonth(_year, _month);
    _day = date.day.clamp(1, maxDay);
  }

  void _onColumnChanged() {
    // Keep the day within the (possibly shorter) selected month.
    final maxDay = DrumDateUtils.daysInMonth(_year, _month);
    if (_day > maxDay) _day = maxDay;

    var candidate = DrumDateUtils.clamp(
      _assembled,
      widget.firstDate,
      widget.lastDate,
    );

    final predicate = widget.selectableDayPredicate;
    if (predicate != null && !predicate(candidate)) {
      final valid = _nearestValidDate(candidate);
      if (valid != null) {
        candidate = valid;
      }
    }

    setState(() => _syncFrom(candidate));
    widget.onChanged(candidate);
  }

  DateTime? _nearestValidDate(DateTime from) {
    for (var delta = 1; delta <= 366; delta++) {
      for (final dir in const [1, -1]) {
        final candidate = from.add(Duration(days: delta * dir));
        if (DrumDateUtils.isInRange(
              candidate,
              widget.firstDate,
              widget.lastDate,
            ) &&
            (widget.selectableDayPredicate?.call(candidate) ?? true)) {
          return DrumDateUtils.dateOnly(candidate);
        }
      }
    }
    return null;
  }

  DrumColumn _buildDayColumn() {
    final dayCount = DrumDateUtils.daysInMonth(_year, _month);
    return DrumColumn(
      key: const ValueKey('drum-day'),
      label: 'DAY',
      itemCount: dayCount,
      selectedIndex: _day - 1,
      tokens: widget.tokens,
      onSelectedItemChanged: (index) {
        _day = index + 1;
        _onColumnChanged();
      },
      itemBuilder: (index) {
        final day = index + 1;
        if (!widget.showDayOfWeek) return '$day';
        final dow = DateFormat.E(widget.localeName)
            .format(DateTime(_year, _month, day));
        return '$day\n$dow';
      },
      semanticLabelBuilder: (index) {
        final day = index + 1;
        return DateFormat.MMMMEEEEd(widget.localeName)
            .format(DateTime(_year, _month, day));
      },
    );
  }

  DrumColumn _buildMonthColumn() {
    return DrumColumn(
      key: const ValueKey('drum-month'),
      label: 'MONTH',
      itemCount: 12,
      selectedIndex: _month - 1,
      tokens: widget.tokens,
      onSelectedItemChanged: (index) {
        _month = index + 1;
        _onColumnChanged();
      },
      itemBuilder: (index) =>
          DateFormat.MMM(widget.localeName).format(DateTime(2020, index + 1)),
      semanticLabelBuilder: (index) =>
          DateFormat.MMMM(widget.localeName).format(DateTime(2020, index + 1)),
    );
  }

  DrumColumn _buildYearColumn() {
    final yearCount = _lastYear - _firstYear + 1;
    return DrumColumn(
      key: const ValueKey('drum-year'),
      label: 'YEAR',
      itemCount: yearCount,
      selectedIndex: _year - _firstYear,
      tokens: widget.tokens,
      onSelectedItemChanged: (index) {
        _year = _firstYear + index;
        _onColumnChanged();
      },
      itemBuilder: (index) => '${_firstYear + index}',
      semanticLabelBuilder: (index) => '${_firstYear + index}',
    );
  }

  List<Widget> _orderedColumns() {
    final dayCol = _buildDayColumn();
    final monthCol = _buildMonthColumn();
    final yearCol = _buildYearColumn();
    return switch (widget.columnOrder) {
      DrumColumnOrder.dmy => [dayCol, monthCol, yearCol],
      DrumColumnOrder.mdy => [monthCol, dayCol, yearCol],
      DrumColumnOrder.ymd => [yearCol, monthCol, dayCol],
      DrumColumnOrder.ydm => [yearCol, dayCol, monthCol],
    };
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: _orderedColumns(),
      ),
    );
  }
}
