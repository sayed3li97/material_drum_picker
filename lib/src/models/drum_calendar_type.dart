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
}
