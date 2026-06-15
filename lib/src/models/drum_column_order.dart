/// Determines the left-to-right order of columns in `DrumPickerMode.drum`.
///
/// Matches `DatePickerDateOrder` from `CupertinoDatePicker`.
enum DrumColumnOrder {
  /// Day – Month – Year (used in UK, Europe, Australia, Middle East).
  ///
  /// Example: 15 Jun 2024.
  dmy,

  /// Month – Day – Year (used in the United States).
  ///
  /// Example: Jun 15 2024.
  mdy,

  /// Year – Month – Day (ISO 8601, used in Japan, China, Korea).
  ///
  /// Example: 2024 Jun 15.
  ymd,

  /// Year – Day – Month.
  ydm,
}
