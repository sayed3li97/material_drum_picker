import 'dart:ui';

import '../models/drum_column_order.dart';

/// Locale-aware helpers for resolving formatting defaults.
abstract final class DrumLocaleUtils {
  /// Resolves the default [DrumColumnOrder] for [locale].
  ///
  /// * Japanese, Chinese and Korean default to [DrumColumnOrder.ymd].
  /// * US and Canadian English default to [DrumColumnOrder.mdy].
  /// * Everything else (EU, MENA, Australia, …) defaults to
  ///   [DrumColumnOrder.dmy].
  static DrumColumnOrder columnOrderForLocale(Locale? locale) {
    if (locale == null) return DrumColumnOrder.dmy;
    final lang = locale.languageCode;
    final country = locale.countryCode;

    if (lang == 'ja' || lang == 'zh' || lang == 'ko') {
      return DrumColumnOrder.ymd;
    }
    if (lang == 'en' && (country == 'US' || country == 'CA')) {
      return DrumColumnOrder.mdy;
    }
    return DrumColumnOrder.dmy;
  }

  /// Builds an `intl`-compatible locale string (e.g. `en_US`) from [locale],
  /// or `null` to use the ambient default.
  static String? toIntlLocale(Locale? locale) {
    if (locale == null) return null;
    final country = locale.countryCode;
    if (country == null || country.isEmpty) return locale.languageCode;
    return '${locale.languageCode}_$country';
  }
}
