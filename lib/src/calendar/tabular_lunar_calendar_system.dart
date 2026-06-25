import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart';

import 'calendar_date.dart';
import 'drum_calendar_system.dart';
import 'hijri/hijri_calendar_system.dart';
import 'jdn.dart';

/// One month start in a data backed lunar calendar: the Gregorian date on
/// which a given Hijri month begins.
@immutable
class TabularLunarMonth {
  /// Creates a month start entry.
  const TabularLunarMonth({
    required this.hijriYear,
    required this.hijriMonth,
    required this.gregorianStart,
  });

  /// Parses an entry of the form `{ "hy": 1446, "hm": 1, "g": "2024-07-07" }`.
  factory TabularLunarMonth.fromJson(Map<String, dynamic> json) {
    final g = DateTime.parse(json['g'] as String);
    return TabularLunarMonth(
      hijriYear: json['hy'] as int,
      hijriMonth: json['hm'] as int,
      gregorianStart: DateTime(g.year, g.month, g.day),
    );
  }

  /// The Hijri year this month belongs to.
  final int hijriYear;

  /// The 1 based Hijri month.
  final int hijriMonth;

  /// The Gregorian date on which this Hijri month begins.
  final DateTime gregorianStart;
}

/// A lunar calendar defined entirely by a lookup table of month start dates,
/// for official or committee calendars that are published as data rather than
/// computed by a formula (for example a crescent sighting committee calendar).
///
/// The dataset is an ordered, contiguous list of Hijri month starts plus a
/// trailing sentinel entry: the start of the first month after the last
/// selectable month, so the last month's length is well defined. The system
/// derives everything else (month lengths, decoding, encoding, and the
/// supported range) from the table, and it reuses the lunar Hijri month names,
/// the locale aware numerals, and the right to left layout of the built in
/// Hijri calendar.
///
/// The package ships only this mechanism, never any specific publisher's data.
/// Supply the dataset from your own app, with the publisher's permission and
/// attribution. Data backed calendars need periodic dataset refreshes, roughly
/// once a Hijri year. Compare your `lastDate` with [maxSupported] to detect
/// that the data is near its end.
///
/// ```dart
/// final system = TabularLunarCalendarSystem(const [
///   TabularLunarMonth(hijriYear: 1446, hijriMonth: 1, gregorianStart: ...),
///   // ... contiguous months ...
///   TabularLunarMonth(hijriYear: 1447, hijriMonth: 1, gregorianStart: ...),
/// ]);
/// final picked = await showDrumDatePicker(
///   context: context,
///   firstDate: system.minSupported,
///   lastDate: system.maxSupported,
///   calendarSystem: system,
///   locale: const Locale('ar'),
/// );
/// ```
class TabularLunarCalendarSystem extends DrumCalendarSystem {
  /// Builds and validates a data backed calendar from [months].
  ///
  /// The list must be ordered, strictly increasing in both Hijri month and
  /// Gregorian start, contiguous (month 12 is followed by month 1 of the next
  /// year), with every derived month length equal to 29 or 30, and it must
  /// include the trailing sentinel. A malformed dataset throws a
  /// [FormatException] rather than producing wrong dates.
  factory TabularLunarCalendarSystem(List<TabularLunarMonth> months) {
    if (months.length < 2) {
      throw const FormatException(
          'A tabular lunar calendar needs at least one month plus a trailing '
          'sentinel entry.');
    }
    final starts = <int>[];
    final base = months.first.hijriYear * 12 + (months.first.hijriMonth - 1);
    for (var i = 0; i < months.length; i++) {
      final m = months[i];
      final linear = m.hijriYear * 12 + (m.hijriMonth - 1);
      if (linear != base + i) {
        throw FormatException(
            'Hijri months must be contiguous. Entry $i is ${m.hijriYear}/'
            '${m.hijriMonth}, which is out of sequence.');
      }
      starts.add(dateToJdn(m.gregorianStart));
    }
    for (var i = 0; i < starts.length - 1; i++) {
      final length = starts[i + 1] - starts[i];
      if (length <= 0) {
        throw FormatException(
            'Gregorian start dates must strictly increase. Entry ${i + 1} is '
            'not after entry $i.');
      }
      if (length != 29 && length != 30) {
        throw FormatException(
            'Lunar month length must be 29 or 30 days. Month at index $i is '
            '$length days.');
      }
    }
    return TabularLunarCalendarSystem._(starts, base);
  }

  /// Parses a dataset from a decoded JSON list of `{hy, hm, g}` objects.
  factory TabularLunarCalendarSystem.fromJsonList(List<dynamic> json) {
    final months = json
        .map((e) => TabularLunarMonth.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
    return TabularLunarCalendarSystem(months);
  }

  TabularLunarCalendarSystem._(this._starts, this._baseLinear);

  final List<int> _starts;
  final int _baseLinear;

  // Month names, numerals, and direction are shared with the Hijri calendar.
  static const HijriCalendarSystem _names = HijriCalendarSystem();

  int get _lastIndex => _starts.length - 1; // sentinel index

  /// The number of selectable months in the dataset (excluding the sentinel).
  int get selectableMonthCount => _starts.length - 1;

  int _clampJdn(int jdn) {
    final lo = _starts.first;
    final hi = _starts.last - 1;
    if (jdn < lo) return lo;
    if (jdn > hi) return hi;
    return jdn;
  }

  @override
  CalendarDate decode(DateTime date) {
    final jdn = _clampJdn(dateToJdn(date));
    var lo = 0;
    var hi = _lastIndex - 1;
    while (lo < hi) {
      final mid = (lo + hi + 1) >> 1;
      if (_starts[mid] <= jdn) {
        lo = mid;
      } else {
        hi = mid - 1;
      }
    }
    final linear = _baseLinear + lo;
    final year = linear ~/ 12;
    final month = linear % 12 + 1;
    final day = jdn - _starts[lo] + 1;
    return CalendarDate(year, month, day);
  }

  @override
  DateTime encode(int year, int month, int day) {
    final linear = year * 12 + (month - 1);
    final idx = (linear - _baseLinear).clamp(0, _lastIndex - 1);
    final jdn = _clampJdn(_starts[idx] + (day - 1));
    return jdnToGregorian(jdn);
  }

  @override
  int daysInMonth(int year, int month) {
    final linear = year * 12 + (month - 1);
    final idx = (linear - _baseLinear).clamp(0, _lastIndex - 1);
    return _starts[idx + 1] - _starts[idx];
  }

  @override
  String monthName(int month,
          {required bool abbreviated, required Locale locale}) =>
      _names.monthName(month, abbreviated: abbreviated, locale: locale);

  @override
  DateTime get minSupported => jdnToGregorian(_starts.first);

  @override
  DateTime get maxSupported => jdnToGregorian(_starts.last - 1);

  @override
  bool isValid(int year, int month, int day) {
    if (month < 1 || month > 12 || day < 1) return false;
    final linear = year * 12 + (month - 1);
    final idx = linear - _baseLinear;
    if (idx < 0 || idx > _lastIndex - 1) return false;
    return day <= _starts[idx + 1] - _starts[idx];
  }
}
