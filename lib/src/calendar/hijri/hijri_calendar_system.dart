import 'dart:ui' show Locale;

import '../calendar_date.dart';
import '../drum_calendar_system.dart';
import '../jdn.dart';
import 'umm_al_qura_data.dart';

/// Full lunar Hijri month names, keyed by locale language code.
const Map<String, List<String>> _hijriMonthsFull = {
  'en': [
    'Muharram',
    'Safar',
    "Rabi al-Awwal",
    "Rabi al-Thani",
    'Jumada al-Awwal',
    'Jumada al-Thani',
    'Rajab',
    "Sha'ban",
    'Ramadan',
    'Shawwal',
    "Dhu al-Qi'dah",
    'Dhu al-Hijjah',
  ],
  'ar': [
    'محرم',
    'صفر',
    'ربيع الأول',
    'ربيع الآخر',
    'جمادى الأولى',
    'جمادى الآخرة',
    'رجب',
    'شعبان',
    'رمضان',
    'شوال',
    'ذو القعدة',
    'ذو الحجة',
  ],
};

/// Abbreviated lunar Hijri month names, keyed by locale language code. Arabic
/// uses the full names, which are already compact and the conventional form.
const Map<String, List<String>> _hijriMonthsShort = {
  'en': [
    'Muh',
    'Saf',
    'Rab1',
    'Rab2',
    'Jum1',
    'Jum2',
    'Raj',
    'Shab',
    'Ram',
    'Shaw',
    'DhuQ',
    'DhuH',
  ],
  'ar': [
    'محرم',
    'صفر',
    'ربيع١',
    'ربيع٢',
    'جمادى١',
    'جمادى٢',
    'رجب',
    'شعبان',
    'رمضان',
    'شوال',
    'ذو القعدة',
    'ذو الحجة',
  ],
};

/// The lunar Hijri calendar backed by the Umm al-Qura tabular data.
///
/// The Umm al-Qura calendar is the official civil calendar of Saudi Arabia.
/// This system reproduces the tabular data exactly, including its rare short
/// months in the earliest covered years, so that decoding and encoding round
/// trip. Conversion never throws at the supported range boundary; out of range
/// values are clamped.
///
/// ```dart
/// final picked = await showDrumDatePicker(
///   context: context,
///   firstDate: DateTime(2000),
///   lastDate: DateTime(2050),
///   calendar: DrumCalendarType.hijri,
///   locale: const Locale('ar'),
/// );
/// ```
class HijriCalendarSystem extends DrumCalendarSystem {
  /// Creates the Umm al-Qura Hijri calendar system.
  ///
  /// [adjustment] shifts every conversion by a whole number of days, to align
  /// with a regional sighting that differs from the tabular data by plus or
  /// minus one day. It defaults to 0 (no adjustment).
  const HijriCalendarSystem({this.adjustment = 0});

  /// A whole day offset applied to every conversion, defaulting to 0.
  final int adjustment;

  static const List<int> _starts = kUmmAlQuraMonthStarts;
  static const int _firstYear = kUmmAlQuraFirstYear;

  int get _lastIndex => _starts.length - 1; // sentinel index

  int _clampJdn(int jdn) {
    final lo = _starts.first;
    final hi = _starts.last - 1;
    if (jdn < lo) return lo;
    if (jdn > hi) return hi;
    return jdn;
  }

  @override
  CalendarDate decode(DateTime date) {
    final jdn = _clampJdn(dateToJdn(date) - adjustment);
    // Largest month index whose start is on or before jdn.
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
    final idx = lo;
    final year = _firstYear + idx ~/ 12;
    final month = idx % 12 + 1;
    final day = jdn - _starts[idx] + 1;
    return CalendarDate(year, month, day);
  }

  @override
  DateTime encode(int year, int month, int day) {
    final idx =
        ((year - _firstYear) * 12 + (month - 1)).clamp(0, _lastIndex - 1);
    final jdn = _clampJdn(_starts[idx] + (day - 1)) + adjustment;
    return jdnToGregorian(jdn);
  }

  @override
  int daysInMonth(int year, int month) {
    final idx =
        ((year - _firstYear) * 12 + (month - 1)).clamp(0, _lastIndex - 1);
    return _starts[idx + 1] - _starts[idx];
  }

  @override
  String monthName(int month,
      {required bool abbreviated, required Locale locale}) {
    final table = abbreviated ? _hijriMonthsShort : _hijriMonthsFull;
    final names = table[locale.languageCode] ?? table['en']!;
    return names[(month - 1).clamp(0, 11)];
  }

  @override
  DateTime get minSupported => jdnToGregorian(_starts.first + adjustment);

  @override
  DateTime get maxSupported => jdnToGregorian(_starts.last - 1 + adjustment);

  @override
  bool isValid(int year, int month, int day) {
    if (month < 1 || month > 12 || day < 1) return false;
    final idx = (year - _firstYear) * 12 + (month - 1);
    if (idx < 0 || idx > _lastIndex - 1) return false;
    return day <= _starts[idx + 1] - _starts[idx];
  }
}
