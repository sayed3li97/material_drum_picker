import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../calendar/drum_calendar_system.dart';
import '../../models/drum_column_order.dart';
import '../../models/drum_month_format.dart';
import '../../models/drum_picker_labels.dart';
import '../../theme/drum_picker_theme.dart';
import '../../utils/drum_date_utils.dart';
import '../../utils/drum_locale_utils.dart';
import '../../utils/drum_numerals.dart';
import '../internal/drum_column.dart';

/// The drum-wheel input mode: scrollable day/month/year columns, rendered in
/// the active [system] calendar.
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
    required this.system,
    required this.locale,
    required this.labels,
    required this.monthFormat,
    required this.onChanged,
    this.selectableDayPredicate,
  });

  /// The currently-selected date (canonical Gregorian value).
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

  /// The active calendar system.
  final DrumCalendarSystem system;

  /// The resolved locale for names and numerals.
  final Locale locale;

  /// Overridable UI strings (column headers).
  final DrumPickerLabels labels;

  /// Whether the month column shows the month name or its number.
  final DrumMonthFormat monthFormat;

  /// Called with the new date whenever a column settles.
  final ValueChanged<DateTime> onChanged;

  /// Optional predicate restricting selectable days.
  final bool Function(DateTime day)? selectableDayPredicate;

  @override
  State<DrumModeWidget> createState() => _DrumModeWidgetState();
}

class _DrumModeWidgetState extends State<DrumModeWidget> {
  late int _year;
  late int _month;
  late int _day;

  String? get _localeName => DrumLocaleUtils.toIntlLocale(widget.locale);

  int get _firstYear => widget.system.decode(widget.firstDate).year;
  int get _lastYear => widget.system.decode(widget.lastDate).year;

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

  DateTime get _assembled => widget.system.encode(_year, _month, _day);

  void _syncFrom(DateTime date) {
    final c = widget.system.decode(date);
    _year = c.year.clamp(_firstYear, _lastYear);
    _month = c.month;
    final maxDay = widget.system.daysInMonth(_year, _month);
    _day = c.day.clamp(1, maxDay);
  }

  void _onColumnChanged() {
    final maxDay = widget.system.daysInMonth(_year, _month);
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
    final dayCount = widget.system.daysInMonth(_year, _month);
    return DrumColumn(
      key: const ValueKey('drum-day'),
      label: widget.labels.dayColumn,
      itemCount: dayCount,
      selectedIndex: _day - 1,
      tokens: widget.tokens,
      onSelectedItemChanged: (index) {
        _day = index + 1;
        _onColumnChanged();
      },
      itemBuilder: (index) {
        final day = index + 1;
        final number = DrumNumerals.format(day, _localeName);
        if (!widget.showDayOfWeek) return number;
        final dow = DateFormat.E(_localeName)
            .format(widget.system.encode(_year, _month, day));
        return '$number\n$dow';
      },
      semanticLabelBuilder: (index) {
        final day = index + 1;
        return DateFormat.MMMMEEEEd(_localeName)
            .format(widget.system.encode(_year, _month, day));
      },
    );
  }

  DrumColumn _buildMonthColumn() {
    return DrumColumn(
      key: const ValueKey('drum-month'),
      label: widget.labels.monthColumn,
      itemCount: 12,
      selectedIndex: _month - 1,
      tokens: widget.tokens,
      onSelectedItemChanged: (index) {
        _month = index + 1;
        _onColumnChanged();
      },
      itemBuilder: (index) => widget.monthFormat == DrumMonthFormat.numeric
          ? DrumNumerals.formatPadded(index + 1, 2, _localeName)
          : widget.system
              .monthName(index + 1, abbreviated: true, locale: widget.locale),
      // The screen reader always announces the full month name, even when the
      // visible column shows a number, for clarity.
      semanticLabelBuilder: (index) => widget.system
          .monthName(index + 1, abbreviated: false, locale: widget.locale),
    );
  }

  DrumColumn _buildYearColumn() {
    final yearCount = _lastYear - _firstYear + 1;
    return DrumColumn(
      key: const ValueKey('drum-year'),
      label: widget.labels.yearColumn,
      itemCount: yearCount,
      selectedIndex: _year - _firstYear,
      tokens: widget.tokens,
      onSelectedItemChanged: (index) {
        _year = _firstYear + index;
        _onColumnChanged();
      },
      itemBuilder: (index) =>
          DrumNumerals.format(_firstYear + index, _localeName),
      semanticLabelBuilder: (index) =>
          DrumNumerals.format(_firstYear + index, _localeName),
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
