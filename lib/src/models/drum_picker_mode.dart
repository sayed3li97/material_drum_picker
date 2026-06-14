/// The input mode displayed in a `DrumPicker`.
enum DrumPickerMode {
  /// Scrollable drum-wheel columns. Ideal for birth dates and distant dates.
  drum,

  /// Material 3 calendar grid. Ideal for scheduling near-future dates.
  calendar,

  /// Keyboard text field with live validation. Ideal for accessibility tools
  /// and power users.
  input,
}
