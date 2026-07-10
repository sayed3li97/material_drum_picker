/// The presentation used by the date range pickers.
///
/// The calendar grid is the default (and the convention for ranges). The drum
/// presentation stacks a Start and an End wheel for users who prefer the
/// scroll roller. The end user can switch between them when the range picker's
/// mode toggle is shown.
enum DrumRangeMode {
  /// A Material 3 calendar grid: tap a start day, then an end day.
  calendar,

  /// Two iOS-style drum rollers, one for the start and one for the end.
  drum,
}
