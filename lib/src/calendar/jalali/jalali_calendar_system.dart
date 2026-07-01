import 'dart:ui' show Locale;

import '../../utils/drum_locale_utils.dart';
import '../../utils/drum_numerals.dart';
import '../calendar_date.dart';
import '../drum_calendar_system.dart';
import '../jdn.dart';

/// Full Persian Solar Hijri month names, keyed by locale language code.
const Map<String, List<String>> _jalaliMonthsFull = {
  'en': [
    'Farvardin',
    'Ordibehesht',
    'Khordad',
    'Tir',
    'Mordad',
    'Shahrivar',
    'Mehr',
    'Aban',
    'Azar',
    'Dey',
    'Bahman',
    'Esfand',
  ],
  'fa': [
    'فروردین',
    'اردیبهشت',
    'خرداد',
    'تیر',
    'مرداد',
    'شهریور',
    'مهر',
    'آبان',
    'آذر',
    'دی',
    'بهمن',
    'اسفند',
  ],
};

/// Abbreviated Persian Solar Hijri month names, keyed by locale language code.
/// Persian reuses the full names, which are already compact, mirroring how the
/// Hijri calendar treats its Arabic labels.
const Map<String, List<String>> _jalaliMonthsShort = {
  'en': [
    'Far',
    'Ord',
    'Kho',
    'Tir',
    'Mor',
    'Sha',
    'Meh',
    'Aba',
    'Aza',
    'Dey',
    'Bah',
    'Esf',
  ],
  'fa': [
    'فروردین',
    'اردیبهشت',
    'خرداد',
    'تیر',
    'مرداد',
    'شهریور',
    'مهر',
    'آبان',
    'آذر',
    'دی',
    'بهمن',
    'اسفند',
  ],
};

/// The Persian Solar Hijri (Jalali) calendar, the official calendar of Iran and
/// Afghanistan.
///
/// The year begins at the vernal equinox (Nowruz, around 21 March). The first
/// six months have 31 days, the next five have 30, and the last month (Esfand)
/// has 29 days, or 30 in a leap year. Conversions use the standard arithmetic
/// algorithm (the same one used by the Iranian civil calendar), computed
/// entirely from formulas so no dataset is shipped.
///
/// The Gregorian `DateTime` remains the canonical value the picker returns;
/// this system only translates to and from it and supplies the Persian display
/// metadata. Conversions round trip across the whole supported range, and out
/// of range values are clamped rather than throwing.
///
/// The supported range is Jalali years 1178 to 1633 (Gregorian 1799 to 2255),
/// the window over which the arithmetic algorithm is verified to match the
/// reference implementation exactly.
///
/// ```dart
/// final picked = await showDrumDatePicker(
///   context: context,
///   firstDate: DateTime(2000),
///   lastDate: DateTime(2050),
///   calendar: DrumCalendarType.jalali,
///   locale: const Locale('fa'),
/// );
/// ```
class JalaliCalendarSystem extends DrumCalendarSystem {
  /// Creates the Persian Solar Hijri (Jalali) calendar system.
  const JalaliCalendarSystem();

  /// The earliest supported Jalali year.
  static const int _firstYear = 1178;

  /// The latest supported Jalali year.
  static const int _lastYear = 1633;

  // Truncating integer division (toward zero), matching the reference
  // algorithm. Dart's ~/ already truncates toward zero.
  static int _div(int a, int b) => a ~/ b;

  // Remainder with the sign of the dividend, matching the reference algorithm.
  // Dart's % returns a result with the sign of the divisor, so it is defined
  // explicitly here for the few places where the operand can be negative.
  static int _mod(int a, int b) => a - (a ~/ b) * b;

  /// The Jalali breakpoints used by the arithmetic leap year rule.
  static const List<int> _breaks = [
    -61, 9, 38, 199, 426, 686, 756, 818, 1111, 1181, //
    1210, 1635, 2060, 2097, 2192, 2262, 2324, 2394, 2456, 3178,
  ];

  /// Computes, for Jalali year [jy], the Gregorian year and the day of March on
  /// which its first day (Farvardin 1) falls, plus a leap indicator.
  ///
  /// When [withoutLeap] is true the leap indicator is not computed (returned as
  /// 0), for the encode path that does not need it. The year is a leap year
  /// exactly when the returned leap value is 0.
  static ({int leap, int gy, int march}) _jalCal(int jy, bool withoutLeap) {
    final gy = jy + 621;
    var leapJ = -14;
    var jp = _breaks[0];
    var jump = 0;
    for (var i = 1; i < _breaks.length; i++) {
      final jm = _breaks[i];
      jump = jm - jp;
      if (jy < jm) break;
      leapJ = leapJ + _div(jump, 33) * 8 + _div(_mod(jump, 33), 4);
      jp = jm;
    }
    var n = jy - jp;
    leapJ = leapJ + _div(n, 33) * 8 + _div(_mod(n, 33) + 3, 4);
    if (_mod(jump, 33) == 4 && jump - n == 4) leapJ += 1;
    final leapG = _div(gy, 4) - _div((_div(gy, 100) + 1) * 3, 4) - 150;
    final march = 20 + leapJ - leapG;
    var leap = 0;
    if (!withoutLeap) {
      if (jump - n < 6) n = n - jump + _div(jump + 4, 33) * 33;
      leap = _mod(_mod(n + 1, 33) - 1, 4);
      if (leap == -1) leap = 4;
    }
    return (leap: leap, gy: gy, march: march);
  }

  bool _isLeapYear(int jy) => _jalCal(jy, false).leap == 0;

  /// The Julian Day Number of Jalali [jy], [jm], [jd].
  static int _jalaliToJdn(int jy, int jm, int jd) {
    final r = _jalCal(jy, true);
    return gregorianToJdn(r.gy, 3, r.march) +
        (jm - 1) * 31 -
        _div(jm, 7) * (jm - 7) +
        jd -
        1;
  }

  /// The Jalali year, month, and day for Julian Day Number [jdn].
  static CalendarDate _jdnToJalali(int jdn) {
    final gy = jdnToGregorian(jdn).year;
    var jy = gy - 621;
    final r = _jalCal(jy, false);
    final jdn1f = gregorianToJdn(gy, 3, r.march);
    var k = jdn - jdn1f;
    if (k >= 0) {
      if (k <= 185) {
        return CalendarDate(jy, 1 + _div(k, 31), _mod(k, 31) + 1);
      }
      k -= 186;
    } else {
      jy -= 1;
      k += 179;
      if (r.leap == 1) k += 1;
    }
    return CalendarDate(jy, 7 + _div(k, 30), _mod(k, 30) + 1);
  }

  int get _minJdn => _jalaliToJdn(_firstYear, 1, 1);
  int get _maxJdn => _jalaliToJdn(_lastYear, 12, daysInMonth(_lastYear, 12));

  int _clampJdn(int jdn) {
    if (jdn < _minJdn) return _minJdn;
    if (jdn > _maxJdn) return _maxJdn;
    return jdn;
  }

  @override
  CalendarDate decode(DateTime date) =>
      _jdnToJalali(_clampJdn(dateToJdn(date)));

  @override
  DateTime encode(int year, int month, int day) =>
      jdnToGregorian(_clampJdn(_jalaliToJdn(year, month, day)));

  @override
  int daysInMonth(int year, int month) {
    if (month <= 6) return 31;
    if (month <= 11) return 30;
    return _isLeapYear(year) ? 30 : 29;
  }

  @override
  String monthName(int month,
      {required bool abbreviated, required Locale locale}) {
    final table = abbreviated ? _jalaliMonthsShort : _jalaliMonthsFull;
    final names = table[locale.languageCode] ?? table['en']!;
    return names[(month - 1).clamp(0, 11)];
  }

  @override
  String monthLabel(
    int year,
    int index, {
    required bool numeric,
    required bool abbreviated,
    required Locale locale,
  }) {
    if (numeric) {
      return DrumNumerals.formatPadded(
          index, 2, DrumLocaleUtils.toIntlLocale(locale));
    }
    return monthName(index, abbreviated: abbreviated, locale: locale);
  }

  @override
  DateTime get minSupported => jdnToGregorian(_minJdn);

  @override
  DateTime get maxSupported => jdnToGregorian(_maxJdn);

  @override
  bool isValid(int year, int month, int day) {
    if (year < _firstYear || year > _lastYear) return false;
    if (month < 1 || month > 12 || day < 1) return false;
    return day <= daysInMonth(year, month);
  }
}
