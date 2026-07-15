/// The granularity a `DrumPicker` selects.
///
/// This narrows every date mode (drum, calendar, and keyboard input) to the
/// chosen granularity, for the common cases where a full day is not wanted:
/// a card expiry (`month`), a subscription or statement period (`month`), or a
/// birth year (`year`). The value the picker returns is always a Gregorian
/// `DateTime`, normalized to the first day of the selected period (in the
/// active calendar system's terms, then encoded back to Gregorian) and clamped
/// into `firstDate`..`lastDate`.
///
/// It is purely additive and defaults to [day], so existing pickers are
/// unchanged. It works with every calendar system, so a Hijri, Chinese, or
/// Jalali month or year picker comes for free.
///
/// ```dart
/// // A card expiry month/year picker.
/// final expiry = await showDrumDatePicker(
///   context: context,
///   firstDate: DateTime(2020),
///   lastDate: DateTime(2035, 12),
///   precision: DrumPrecision.month,
/// );
/// ```
enum DrumPrecision {
  /// Full year, month, and day selection. This is the default and the
  /// historic behavior.
  day,

  /// Year and month only. The returned `DateTime` is the first day of the
  /// selected month (clamped into range). The day column, day grid, and day
  /// input field are hidden.
  month,

  /// Year only. The returned `DateTime` is the first day of the selected year
  /// (clamped into range). The month and day are hidden.
  year,
}
