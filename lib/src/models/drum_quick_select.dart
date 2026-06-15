import 'package:flutter/foundation.dart';

/// A quick-select option displayed as a chip in `DrumPickerMode.calendar`.
///
/// Use [DrumQuickSelect.relative] for options calculated from a reference date
/// (avoids hardcoding `DateTime.now()`, which breaks tests).
@immutable
class DrumQuickSelect {
  /// Creates a quick-select chip with an absolute [date].
  const DrumQuickSelect({
    required this.label,
    required this.date,
  });

  /// Creates a quick-select relative to [referenceDate] (or today if null).
  ///
  /// The resulting [date] is normalized to midnight (year/month/day only).
  factory DrumQuickSelect.relative({
    required String label,
    required Duration offset,
    DateTime? referenceDate,
  }) {
    final base = referenceDate ?? DateTime.now();
    final d = base.add(offset);
    return DrumQuickSelect(
      label: label,
      date: DateTime(d.year, d.month, d.day),
    );
  }

  /// The chip label shown to the user.
  final String label;

  /// The date this option selects.
  ///
  /// Must be within the picker's `firstDate` and `lastDate`. Out-of-range
  /// options are shown greyed out and are not tappable.
  final DateTime date;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DrumQuickSelect &&
          runtimeType == other.runtimeType &&
          label == other.label &&
          date == other.date;

  @override
  int get hashCode => Object.hash(label, date);

  @override
  String toString() => 'DrumQuickSelect(label: $label, date: $date)';
}
