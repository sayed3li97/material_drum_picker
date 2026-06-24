import 'package:flutter/foundation.dart';

/// Decoded calendar fields (year, month, day) in the active calendar system.
///
/// The canonical value handled by the picker is always a Gregorian `DateTime`.
/// A [CalendarDate] is only the decoded view used to drive the columns, grid,
/// and input field for a non Gregorian calendar.
@immutable
class CalendarDate {
  /// Creates a calendar date with the 1 based [month] and [day].
  const CalendarDate(this.year, this.month, this.day);

  /// The year in the active calendar.
  final int year;

  /// The 1 based month in the active calendar.
  final int month;

  /// The 1 based day of the month in the active calendar.
  final int day;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CalendarDate &&
          year == other.year &&
          month == other.month &&
          day == other.day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => 'CalendarDate($year, $month, $day)';
}
