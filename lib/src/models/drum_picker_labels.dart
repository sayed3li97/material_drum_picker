import 'package:flutter/foundation.dart';

/// Overridable text labels used by a `DrumPicker`.
///
/// Every field has an English default that matches the picker's historic
/// behavior, so the class is fully optional. Provide an instance through the
/// `labels` parameter to translate or relabel the fixed UI strings (the drum
/// column headers, the time strip headers, the mode toggle, and the default
/// quick select chips) that are not otherwise localized.
///
/// ```dart
/// DrumPicker(
///   firstDate: DateTime(2000),
///   lastDate: DateTime(2100),
///   labels: const DrumPickerLabels(
///     dayColumn: 'JOUR',
///     monthColumn: 'MOIS',
///     yearColumn: 'ANNEE',
///     calendarMode: 'Calendrier',
///     drumMode: 'Molette',
///     inputMode: 'Saisie',
///   ),
/// )
/// ```
@immutable
class DrumPickerLabels {
  /// Creates a set of picker labels. Every field defaults to its English value.
  const DrumPickerLabels({
    this.dayColumn = 'DAY',
    this.monthColumn = 'MONTH',
    this.yearColumn = 'YEAR',
    this.hourColumn = 'HOUR',
    this.minuteColumn = 'MIN',
    this.meridiemColumn = 'AM/PM',
    this.calendarMode = 'Calendar',
    this.drumMode = 'Drum',
    this.inputMode = 'Input',
    this.today = 'Today',
    this.tomorrow = 'Tomorrow',
    this.nextWeek = 'Next week',
  });

  /// Header above the day drum column.
  final String dayColumn;

  /// Header above the month drum column.
  final String monthColumn;

  /// Header above the year drum column.
  final String yearColumn;

  /// Header above the hour drum column in the time strip.
  final String hourColumn;

  /// Header above the minute drum column in the time strip.
  final String minuteColumn;

  /// Header above the AM/PM drum column in the time strip.
  final String meridiemColumn;

  /// Label of the calendar mode tab.
  final String calendarMode;

  /// Label of the drum mode tab.
  final String drumMode;

  /// Label of the input mode tab.
  final String inputMode;

  /// Label of the default "today" quick select chip.
  final String today;

  /// Label of the default "tomorrow" quick select chip.
  final String tomorrow;

  /// Label of the default "next week" quick select chip.
  final String nextWeek;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DrumPickerLabels &&
        other.dayColumn == dayColumn &&
        other.monthColumn == monthColumn &&
        other.yearColumn == yearColumn &&
        other.hourColumn == hourColumn &&
        other.minuteColumn == minuteColumn &&
        other.meridiemColumn == meridiemColumn &&
        other.calendarMode == calendarMode &&
        other.drumMode == drumMode &&
        other.inputMode == inputMode &&
        other.today == today &&
        other.tomorrow == tomorrow &&
        other.nextWeek == nextWeek;
  }

  @override
  int get hashCode => Object.hash(
        dayColumn,
        monthColumn,
        yearColumn,
        hourColumn,
        minuteColumn,
        meridiemColumn,
        calendarMode,
        drumMode,
        inputMode,
        today,
        tomorrow,
        nextWeek,
      );
}
