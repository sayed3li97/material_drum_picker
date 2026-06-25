/// Gregorian to Julian Day Number conversions, shared by the calendar systems.
///
/// These use the standard proleptic Gregorian algorithm and operate on integer
/// day numbers, so they avoid any `DateTime` arithmetic pitfalls (time zones,
/// daylight saving). Not part of the public API.
library;

/// The Julian Day Number for the Gregorian date [year], [month], [day].
int gregorianToJdn(int year, int month, int day) {
  final a = (14 - month) ~/ 12;
  final y = year + 4800 - a;
  final m = month + 12 * a - 3;
  return day +
      (153 * m + 2) ~/ 5 +
      365 * y +
      y ~/ 4 -
      y ~/ 100 +
      y ~/ 400 -
      32045;
}

/// The Gregorian date (at local midnight) for the Julian Day Number [jdn].
DateTime jdnToGregorian(int jdn) {
  final a = jdn + 32044;
  final b = (4 * a + 3) ~/ 146097;
  final c = a - (146097 * b) ~/ 4;
  final d = (4 * c + 3) ~/ 1461;
  final e = c - (1461 * d) ~/ 4;
  final m = (5 * e + 2) ~/ 153;
  final day = e - (153 * m + 2) ~/ 5 + 1;
  final month = m + 3 - 12 * (m ~/ 10);
  final year = 100 * b + d - 4800 + m ~/ 10;
  return DateTime(year, month, day);
}

/// The Julian Day Number for the date part of [date].
int dateToJdn(DateTime date) => gregorianToJdn(date.year, date.month, date.day);
