/// The built in calendar systems a `DrumPicker` can present its dates in.
///
/// This selects a calendar for display and interaction only. The value the
/// picker returns is always a Gregorian `DateTime`. For a custom or data
/// backed calendar (for example a committee lunar calendar), pass a
/// `DrumCalendarSystem` through the `calendarSystem` parameter instead, which
/// takes precedence over this enum.
enum DrumCalendarType {
  /// The Gregorian (Western) calendar. This is the default.
  gregorian,

  /// The lunar Hijri calendar using the Umm al-Qura tabular data, the official
  /// civil calendar of Saudi Arabia.
  hijri,

  /// The Chinese lunisolar calendar, with leap months (12 or 13 months a year),
  /// astronomically computed month lengths, and sexagenary year names.
  chinese,

  /// The Persian Solar Hijri (Jalali) calendar, the official calendar of Iran
  /// and Afghanistan, computed arithmetically with no dataset.
  jalali,
}
