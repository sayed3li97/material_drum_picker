import 'package:flutter/foundation.dart';

/// One field of a [DrumDateFormat].
enum DrumDateField {
  /// The day of the month.
  day,

  /// The month number.
  month,

  /// The year.
  year,
}

/// Describes the textual layout of a date in the keyboard input mode: the order
/// of the day, month, and year fields, the separator between them, and whether
/// the year is two or four digits.
///
/// This is calendar agnostic. It drives how the input field formats the current
/// value, the hint it shows, and how it parses what the user types, in whatever
/// calendar system the picker is using. The default reproduces the historic
/// `MM/DD/YYYY` behavior.
///
/// Build one from a pattern string, which is usually the most readable option:
///
/// ```dart
/// DrumPicker(
///   firstDate: DateTime(2000),
///   lastDate: DateTime(2100),
///   inputFormat: DrumDateFormat.parse('DD-MM-YYYY'),
/// )
/// ```
///
/// Or use a preset: [DrumDateFormat.mdy], [DrumDateFormat.dmy],
/// [DrumDateFormat.ymd].
@immutable
class DrumDateFormat {
  /// Creates a date format from an explicit field [order].
  ///
  /// [order] must contain each of day, month, and year exactly once.
  const DrumDateFormat({
    required this.order,
    this.separator = '/',
    this.twoDigitYear = false,
  });

  /// The left to right order of the three fields.
  final List<DrumDateField> order;

  /// The separator drawn between fields, for example `/`, `-`, or `.`.
  final String separator;

  /// Whether the year is shown and parsed as two digits (`YY`) instead of four
  /// (`YYYY`).
  final bool twoDigitYear;

  /// Month, day, year with slashes (`MM/DD/YYYY`). The default, US style.
  static const DrumDateFormat mdy = DrumDateFormat(
    order: [DrumDateField.month, DrumDateField.day, DrumDateField.year],
  );

  /// Day, month, year with slashes (`DD/MM/YYYY`). Common outside the US.
  static const DrumDateFormat dmy = DrumDateFormat(
    order: [DrumDateField.day, DrumDateField.month, DrumDateField.year],
  );

  /// Year, month, day with dashes (`YYYY-MM-DD`). ISO 8601 style.
  static const DrumDateFormat ymd = DrumDateFormat(
    order: [DrumDateField.year, DrumDateField.month, DrumDateField.day],
    separator: '-',
  );

  /// Parses a pattern such as `MM/DD/YYYY`, `DD-MM-YYYY`, `YYYY.MM.DD`, or
  /// `D/M/YY`.
  ///
  /// Recognizes runs of `D`, `M`, and `Y` (case insensitive) as the day, month,
  /// and year fields, and treats any other run of characters as the separator.
  /// A year run of one or two characters means a two digit year. The pattern
  /// must contain each of day, month, and year exactly once.
  ///
  /// Throws a [FormatException] for a malformed pattern.
  factory DrumDateFormat.parse(String pattern) {
    final order = <DrumDateField>[];
    String? separator;
    var twoDigitYear = false;
    final seen = <DrumDateField>{};

    var i = 0;
    while (i < pattern.length) {
      final ch = pattern[i].toUpperCase();
      if (ch == 'D' || ch == 'M' || ch == 'Y') {
        var j = i;
        while (j < pattern.length && pattern[j].toUpperCase() == ch) {
          j++;
        }
        final runLength = j - i;
        final field = ch == 'D'
            ? DrumDateField.day
            : ch == 'M'
                ? DrumDateField.month
                : DrumDateField.year;
        if (!seen.add(field)) {
          throw FormatException(
              'Field "$ch" appears more than once in pattern', pattern, i);
        }
        if (field == DrumDateField.year) {
          twoDigitYear = runLength <= 2;
        }
        order.add(field);
        i = j;
      } else {
        // A run of one or more separator characters. Keep the first one seen.
        var j = i;
        while (j < pattern.length &&
            pattern[j].toUpperCase() != 'D' &&
            pattern[j].toUpperCase() != 'M' &&
            pattern[j].toUpperCase() != 'Y') {
          j++;
        }
        separator ??= pattern.substring(i, j);
        i = j;
      }
    }

    if (order.length != 3) {
      throw FormatException(
          'Pattern must contain day, month, and year exactly once', pattern);
    }
    return DrumDateFormat(
      order: order,
      separator: separator ?? '/',
      twoDigitYear: twoDigitYear,
    );
  }

  /// The number of digits used to render the year (`2` or `4`).
  int get yearDigits => twoDigitYear ? 2 : 4;

  /// A human readable pattern such as `MM/DD/YYYY`, suitable as the field hint.
  String get displayPattern {
    String token(DrumDateField field) {
      switch (field) {
        case DrumDateField.day:
          return 'DD';
        case DrumDateField.month:
          return 'MM';
        case DrumDateField.year:
          return twoDigitYear ? 'YY' : 'YYYY';
      }
    }

    return order.map(token).join(separator);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DrumDateFormat &&
        listEquals(other.order, order) &&
        other.separator == separator &&
        other.twoDigitYear == twoDigitYear;
  }

  @override
  int get hashCode =>
      Object.hash(Object.hashAll(order), separator, twoDigitYear);
}
