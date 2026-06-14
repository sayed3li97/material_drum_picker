import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_drum_picker/src/utils/drum_locale_utils.dart';

void main() {
  group('DrumLocaleUtils.toIntlLocale', () {
    test('returns null for a null locale', () {
      expect(DrumLocaleUtils.toIntlLocale(null), isNull);
    });

    test('returns the language code when there is no country', () {
      expect(DrumLocaleUtils.toIntlLocale(const Locale('fr')), 'fr');
    });

    test('joins language and country with an underscore', () {
      expect(
        DrumLocaleUtils.toIntlLocale(const Locale('en', 'US')),
        'en_US',
      );
    });
  });
}
