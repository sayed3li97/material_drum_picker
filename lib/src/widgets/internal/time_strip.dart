import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/drum_picker_labels.dart';
import '../../theme/drum_picker_theme.dart';
import '../../utils/drum_date_utils.dart';
import 'drum_column.dart';

/// A compact drum strip for choosing a time: hour, minute, and (in 12-hour
/// mode) an AM/PM column.
///
/// Exposed (non-private) for widget tests. Not part of the public package API.
class TimeStrip extends StatefulWidget {
  /// Creates a time strip.
  const TimeStrip({
    super.key,
    required this.time,
    required this.use24hFormat,
    required this.minuteInterval,
    required this.tokens,
    required this.onChanged,
    this.labels = const DrumPickerLabels(),
    this.localeName,
  });

  /// The currently-selected time.
  final TimeOfDay time;

  /// Whether to use 24-hour format (no AM/PM column) instead of 12-hour.
  final bool use24hFormat;

  /// The granularity of the minute column. Must divide 60.
  final int minuteInterval;

  /// Resolved visual tokens.
  final DrumPickerResolved tokens;

  /// Called with the new time whenever a column settles.
  final ValueChanged<TimeOfDay> onChanged;

  /// Overridable UI strings (column headers).
  final DrumPickerLabels labels;

  /// The `intl` locale used to format AM/PM labels.
  final String? localeName;

  @override
  State<TimeStrip> createState() => _TimeStripState();
}

class _TimeStripState extends State<TimeStrip> {
  late int _hour; // 0..23
  late int _minute; // 0..59 (snapped to interval)

  @override
  void initState() {
    super.initState();
    _syncFrom(widget.time);
  }

  @override
  void didUpdateWidget(TimeStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.time != oldWidget.time &&
        (widget.time.hour != _hour ||
            widget.time.minute != _snappedMinute(widget.time.minute))) {
      setState(() => _syncFrom(widget.time));
    }
  }

  void _syncFrom(TimeOfDay time) {
    _hour = time.hour;
    _minute = _snappedMinute(time.minute);
  }

  int _snappedMinute(int minute) =>
      DrumDateUtils.snapMinute(minute, widget.minuteInterval);

  bool get _isPm => _hour >= 12;

  int get _minuteCount => 60 ~/ widget.minuteInterval;

  void _report() => widget.onChanged(TimeOfDay(hour: _hour, minute: _minute));

  void _onHourChanged(int index) {
    if (widget.use24hFormat) {
      _hour = index;
    } else {
      final display = index + 1; // 1..12
      _hour = (display % 12) + (_isPm ? 12 : 0);
    }
    _report();
  }

  void _onMinuteChanged(int index) {
    _minute = index * widget.minuteInterval;
    _report();
  }

  void _onMeridiemChanged(int index) {
    final pm = index == 1;
    _hour = (_hour % 12) + (pm ? 12 : 0);
    _report();
  }

  String _meridiemLabel(bool pm) => DateFormat('a', widget.localeName)
      .format(DateTime(2020, 1, 1, pm ? 13 : 1));

  @override
  Widget build(BuildContext context) {
    final hourColumn = DrumColumn(
      key: const ValueKey('time-hour'),
      label: widget.labels.hourColumn,
      itemCount: widget.use24hFormat ? 24 : 12,
      selectedIndex: widget.use24hFormat
          ? _hour
          : ((_hour % 12 == 0 ? 12 : _hour % 12) - 1),
      tokens: widget.tokens,
      onSelectedItemChanged: _onHourChanged,
      itemBuilder: (index) => widget.use24hFormat ? '$index' : '${index + 1}',
      semanticLabelBuilder: (index) =>
          widget.use24hFormat ? '${index}h' : '${index + 1}',
    );

    final minuteColumn = DrumColumn(
      key: const ValueKey('time-minute'),
      label: widget.labels.minuteColumn,
      itemCount: _minuteCount,
      selectedIndex: _minute ~/ widget.minuteInterval,
      tokens: widget.tokens,
      onSelectedItemChanged: _onMinuteChanged,
      itemBuilder: (index) =>
          (index * widget.minuteInterval).toString().padLeft(2, '0'),
      semanticLabelBuilder: (index) =>
          '${index * widget.minuteInterval} minutes',
    );

    final columns = <Widget>[hourColumn, minuteColumn];
    if (!widget.use24hFormat) {
      columns.add(DrumColumn(
        key: const ValueKey('time-meridiem'),
        label: widget.labels.meridiemColumn,
        itemCount: 2,
        selectedIndex: _isPm ? 1 : 0,
        tokens: widget.tokens,
        onSelectedItemChanged: _onMeridiemChanged,
        itemBuilder: (index) => _meridiemLabel(index == 1),
        semanticLabelBuilder: (index) => _meridiemLabel(index == 1),
      ));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: columns,
      ),
    );
  }
}
