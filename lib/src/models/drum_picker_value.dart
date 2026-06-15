import 'package:flutter/foundation.dart';

import 'drum_picker_mode.dart';

/// An immutable snapshot of a `DrumPicker`'s state: the selected [date] and
/// the active [mode].
///
/// This is used internally to drive the picker and is also exposed publicly so
/// that callers embedding the inline widget can reason about its state.
@immutable
class DrumPickerValue {
  /// Creates a picker value with the given [date] and [mode].
  const DrumPickerValue({
    required this.date,
    required this.mode,
  });

  /// The currently selected date (normalized to year/month/day).
  final DateTime date;

  /// The currently active input mode.
  final DrumPickerMode mode;

  /// Returns a copy of this value with the given fields replaced.
  DrumPickerValue copyWith({
    DateTime? date,
    DrumPickerMode? mode,
  }) {
    return DrumPickerValue(
      date: date ?? this.date,
      mode: mode ?? this.mode,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DrumPickerValue &&
          runtimeType == other.runtimeType &&
          date == other.date &&
          mode == other.mode;

  @override
  int get hashCode => Object.hash(date, mode);

  @override
  String toString() => 'DrumPickerValue(date: $date, mode: $mode)';
}
