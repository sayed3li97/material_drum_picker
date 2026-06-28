import 'package:flutter/foundation.dart';

/// Decoded calendar fields (year, month, day) in the active calendar system.
///
/// The canonical value handled by the picker is always a Gregorian `DateTime`.
/// A [CalendarDate] is only the decoded view used to drive the columns, grid,
/// and input field for a non Gregorian calendar.
@immutable
class CalendarDate {
  /// Creates a calendar date with the 1 based [month] and [day].
  ///
  /// [month] is the 1 based position of the month within the year. For
  /// calendars with leap months (such as the Chinese lunisolar calendar) the
  /// leap month occupies its own position and is flagged with [isLeapMonth];
  /// for all other calendars [isLeapMonth] is always false and the position is
  /// the ordinary month number.
  const CalendarDate(this.year, this.month, this.day,
      {this.isLeapMonth = false});

  /// The year in the active calendar.
  final int year;

  /// The 1 based month position in the active calendar.
  final int month;

  /// The 1 based day of the month in the active calendar.
  final int day;

  /// Whether [month] is a leap month (only ever true for calendars that have
  /// them, such as the Chinese lunisolar calendar).
  final bool isLeapMonth;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CalendarDate &&
          year == other.year &&
          month == other.month &&
          day == other.day &&
          isLeapMonth == other.isLeapMonth;

  @override
  int get hashCode => Object.hash(year, month, day, isLeapMonth);

  @override
  String toString() =>
      'CalendarDate($year, $month, $day${isLeapMonth ? ', leap' : ''})';
}
