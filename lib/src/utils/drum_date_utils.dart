/// Date helpers used throughout the package.
///
/// Named `DrumDateUtils` to avoid a conflict with Flutter's own `DateUtils`.
abstract final class DrumDateUtils {
  /// The number of days in [month] of [year], accounting for leap years.
  static int daysInMonth(int year, int month) {
    const daysPerMonth = <int>[31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    if (month == DateTime.february && _isLeapYear(year)) {
      return 29;
    }
    return daysPerMonth[month - 1];
  }

  static bool _isLeapYear(int year) =>
      (year % 4 == 0) && (year % 100 != 0) || (year % 400 == 0);

  /// Whether [a] and [b] fall on the same calendar day.
  static bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Whether [a] and [b] fall in the same calendar month.
  static bool isSameMonth(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month;
  }

  /// Returns [date] with its time-of-day stripped (midnight, local time).
  static DateTime dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  /// Clamps [date] to the inclusive range `[first, last]`.
  static DateTime clamp(DateTime date, DateTime first, DateTime last) {
    final d = dateOnly(date);
    if (d.isBefore(dateOnly(first))) return dateOnly(first);
    if (d.isAfter(dateOnly(last))) return dateOnly(last);
    return d;
  }

  /// Whether [date] is within the inclusive range `[first, last]`.
  static bool isInRange(DateTime date, DateTime first, DateTime last) {
    final d = dateOnly(date);
    return !d.isBefore(dateOnly(first)) && !d.isAfter(dateOnly(last));
  }

  /// The number of whole months between [first] and [last], inclusive.
  static int monthCount(DateTime first, DateTime last) {
    return (last.year - first.year) * 12 + (last.month - first.month) + 1;
  }

  /// Adds [monthsToAdd] months to the first-of-month derived from [base],
  /// clamping the day to the resulting month length.
  static DateTime addMonths(DateTime base, int monthsToAdd) {
    final totalMonths = base.month - 1 + monthsToAdd;
    // Floor division so that negative deltas roll the year back correctly.
    final year = base.year + (totalMonths / 12).floor();
    final month = totalMonths % 12 + 1;
    final day = base.day.clamp(1, daysInMonth(year, month));
    return DateTime(year, month, day);
  }
}
