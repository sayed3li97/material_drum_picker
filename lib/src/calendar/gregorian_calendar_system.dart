import 'dart:ui' show Locale;

import 'package:intl/intl.dart';

import '../utils/drum_date_utils.dart';
import '../utils/drum_locale_utils.dart';
import 'calendar_date.dart';
import 'drum_calendar_system.dart';

/// The Gregorian calendar, a thin adapter over the package's existing
/// behavior. Month names come from `intl`, and the supported range is
/// effectively unbounded for the picker's purposes.
class GregorianCalendarSystem extends DrumCalendarSystem {
  /// Creates the Gregorian calendar system.
  const GregorianCalendarSystem();

  @override
  CalendarDate decode(DateTime date) =>
      CalendarDate(date.year, date.month, date.day);

  @override
  DateTime encode(int year, int month, int day) => DateTime(year, month, day);

  @override
  int daysInMonth(int year, int month) =>
      DrumDateUtils.daysInMonth(year, month);

  @override
  String monthName(int month,
      {required bool abbreviated, required Locale locale}) {
    final localeName = DrumLocaleUtils.toIntlLocale(locale);
    final sample = DateTime(2020, month);
    return abbreviated
        ? DateFormat.MMM(localeName).format(sample)
        : DateFormat.MMMM(localeName).format(sample);
  }

  @override
  DateTime get minSupported => DateTime(1, 1, 1);

  @override
  DateTime get maxSupported => DateTime(9999, 12, 31);

  @override
  bool isValid(int year, int month, int day) =>
      month >= 1 &&
      month <= 12 &&
      day >= 1 &&
      day <= DrumDateUtils.daysInMonth(year, month);
}
