import 'package:flutter/material.dart';

import '../../calendar/drum_calendar_system.dart';
import '../../models/drum_column_order.dart';
import '../../models/drum_month_format.dart';
import '../../models/drum_picker_labels.dart';
import '../../theme/drum_picker_theme.dart';
import '../modes/drum_mode_widget.dart';

/// A range selector built from two iOS-style drum rollers, one for the start
/// and one for the end. The end roller is bounded so it cannot go before the
/// start.
///
/// Exposed (non-private) for widget tests. Not part of the public package API.
class RangeDrum extends StatelessWidget {
  /// Creates a two-wheel range selector.
  const RangeDrum({
    super.key,
    required this.start,
    required this.end,
    required this.firstDate,
    required this.lastDate,
    required this.system,
    required this.locale,
    required this.tokens,
    required this.columnOrder,
    required this.monthFormat,
    required this.labels,
    required this.startLabel,
    required this.endLabel,
    required this.onStartChanged,
    required this.onEndChanged,
    this.selectableDayPredicate,
  });

  /// The current start date.
  final DateTime start;

  /// The current end date.
  final DateTime end;

  /// The earliest selectable date.
  final DateTime firstDate;

  /// The latest selectable date.
  final DateTime lastDate;

  /// The active calendar system.
  final DrumCalendarSystem system;

  /// The resolved locale.
  final Locale locale;

  /// Resolved visual tokens.
  final DrumPickerResolved tokens;

  /// The drum column order.
  final DrumColumnOrder columnOrder;

  /// Whether the month is a name or a number.
  final DrumMonthFormat monthFormat;

  /// Overridable column header strings.
  final DrumPickerLabels labels;

  /// The label shown above the start wheel.
  final String startLabel;

  /// The label shown above the end wheel.
  final String endLabel;

  /// Called when the start wheel settles on a new date.
  final ValueChanged<DateTime> onStartChanged;

  /// Called when the end wheel settles on a new date.
  final ValueChanged<DateTime> onEndChanged;

  /// A predicate restricting selectable days.
  final bool Function(DateTime day)? selectableDayPredicate;

  Widget _section(BuildContext context, String label, Widget drum) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Text(label,
              style: tokens.columnLabelTextStyle
                  .copyWith(color: tokens.selectedItemColor)),
        ),
        drum,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _section(
          context,
          startLabel,
          DrumModeWidget(
            key: const ValueKey('range-drum-start'),
            selectedDate: start,
            firstDate: firstDate,
            lastDate: lastDate,
            columnOrder: columnOrder,
            showDayOfWeek: false,
            tokens: tokens,
            system: system,
            locale: locale,
            labels: labels,
            monthFormat: monthFormat,
            selectableDayPredicate: selectableDayPredicate,
            onChanged: onStartChanged,
          ),
        ),
        const Divider(height: 1),
        _section(
          context,
          endLabel,
          DrumModeWidget(
            key: const ValueKey('range-drum-end'),
            selectedDate: end,
            // The end cannot be earlier than the start.
            firstDate: start,
            lastDate: lastDate,
            columnOrder: columnOrder,
            showDayOfWeek: false,
            tokens: tokens,
            system: system,
            locale: locale,
            labels: labels,
            monthFormat: monthFormat,
            selectableDayPredicate: selectableDayPredicate,
            onChanged: onEndChanged,
          ),
        ),
      ],
    );
  }
}
