import 'package:flutter_test/flutter_test.dart';
import 'package:material_drum_picker/src/utils/drum_numerals.dart';

void main() {
  group('DrumNumerals', () {
    test('formats ASCII digits for en with no grouping', () {
      expect(DrumNumerals.format(5, 'en'), '5');
      expect(DrumNumerals.format(1446, 'en'), '1446');
      expect(DrumNumerals.format(2024, 'en'), '2024');
    });

    test('uses the locale numbering system (Arabic-Indic for ar_EG)', () {
      // The digits follow the locale, matching what DateFormat uses, so the
      // columns and the header always agree.
      expect(DrumNumerals.format(5, 'ar_EG'), '٥');
      expect(DrumNumerals.format(1446, 'ar_EG'), '١٤٤٦');
    });

    test('pads to a fixed width with locale digits', () {
      expect(DrumNumerals.formatPadded(5, 2, 'en'), '05');
      expect(DrumNumerals.formatPadded(2024, 4, 'en'), '2024');
      expect(DrumNumerals.formatPadded(5, 2, 'ar_EG'), '٠٥');
    });
  });
}
