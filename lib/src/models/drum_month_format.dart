/// How the month is rendered in the drum month column.
///
/// This affects only the spinning month wheel in `DrumPickerMode.drum`. The
/// calendar grid header and the headline keep showing the localized month name.
/// It works with every calendar system (Gregorian, Hijri, tabular) and every
/// locale, since a numeric month is just the month index rendered with the
/// locale's digits.
enum DrumMonthFormat {
  /// Show the abbreviated month name, for example `Jun` or `محرم`. The default.
  name,

  /// Show the month number, zero padded to two digits in the locale's digits,
  /// for example `06` or `٠٦`.
  numeric,
}
