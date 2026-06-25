import 'package:intl/intl.dart';

/// A single source for rendering numbers with locale aware digits.
///
/// Routing every day, month, and year number through this helper means an `ar`
/// locale shows Arabic-Indic digits identically in the drum columns, the
/// calendar grid, the header, and the input field, regardless of the active
/// calendar system. Grouping separators are never used, so a year like 1446
/// renders without a thousands separator.
abstract final class DrumNumerals {
  static final Map<String, NumberFormat> _plain = <String, NumberFormat>{};
  static final Map<String, NumberFormat> _padded = <String, NumberFormat>{};

  /// Formats [value] with [localeName] digits and no grouping (for example
  /// `5` or `1446`).
  static String format(int value, String? localeName) {
    final key = localeName ?? '';
    final fmt = _plain[key] ??= NumberFormat('0', localeName);
    return fmt.format(value);
  }

  /// Formats [value] zero padded to [width] digits with [localeName] digits
  /// (for example `05` for a day, or `1446`).
  static String formatPadded(int value, int width, String? localeName) {
    final key = '$width|${localeName ?? ''}';
    final fmt = _padded[key] ??= NumberFormat('0' * width, localeName);
    return fmt.format(value);
  }
}
