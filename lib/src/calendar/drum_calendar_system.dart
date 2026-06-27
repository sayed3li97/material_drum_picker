import 'dart:ui' show Locale;

import '../utils/drum_locale_utils.dart';
import '../utils/drum_numerals.dart';
import 'calendar_date.dart';

/// A pluggable calendar system for a `DrumPicker`.
///
/// The Gregorian `DateTime` is always the canonical source of truth. An
/// implementation only translates to and from it and supplies display
/// metadata (month names and supported range). Implementations may be
/// algorithmic (computed, like the Umm al-Qura Hijri calendar) or data backed
/// (looked up from a dataset, like an official committee lunar calendar).
///
/// Implementations must round trip: `encode(decode(d))` equals `d` normalized
/// to local midnight for every date in the supported range.
abstract class DrumCalendarSystem {
  /// Const constructor for subclasses.
  const DrumCalendarSystem();

  /// Decomposes a canonical [date] into this calendar's year, month, and day.
  CalendarDate decode(DateTime date);

  /// Recomposes [year], [month], and [day] in this calendar into a canonical
  /// `DateTime` at local midnight.
  DateTime encode(int year, int month, int day);

  /// The number of months in a year. Always 12 for the calendars handled here.
  ///
  /// For calendars with a fixed month count, prefer this. For calendars whose
  /// month count varies by year (leap months), override [monthsInYear].
  int get monthsPerYear => 12;

  /// The number of months in [year]. Defaults to [monthsPerYear].
  ///
  /// The Chinese lunisolar calendar returns 12 or 13 (a leap year has an extra
  /// month). The 1 based month positions then run from 1 to this value.
  int monthsInYear(int year) => monthsPerYear;

  /// The number of days in [month] of [year] in this calendar.
  ///
  /// For lunar calendars this is typically 29 or 30, derived from the data
  /// rather than from arithmetic.
  int daysInMonth(int year, int month);

  /// The localized name of the 1 based [month].
  ///
  /// When [abbreviated] is true a short form is returned, mirroring the
  /// abbreviated and full distinction the Gregorian path uses.
  String monthName(int month,
      {required bool abbreviated, required Locale locale});

  /// The label shown for the 1 based month [index] of [year] in the column,
  /// headline, and grid header.
  ///
  /// The default renders a localized number when [numeric] is true, otherwise
  /// the [monthName]. Calendars with leap months override this to account for
  /// the leap marker and the difference between the sequence position and the
  /// civil month number.
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

  /// An optional short annotation shown under the year in the drum year column
  /// (for example the Chinese sexagenary cycle name and zodiac animal), or null
  /// for none.
  String? yearAnnotation(int year, Locale locale) => null;

  /// The earliest date this system can represent.
  DateTime get minSupported;

  /// The latest date this system can represent.
  DateTime get maxSupported;

  /// Whether [year], [month], and [day] form a valid date in this calendar
  /// (correct number of days in the month, and inside the supported range).
  bool isValid(int year, int month, int day);
}
