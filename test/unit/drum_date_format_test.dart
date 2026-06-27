import 'package:flutter_test/flutter_test.dart';
import 'package:material_drum_picker/material_drum_picker.dart';

void main() {
  group('DrumDateFormat.parse', () {
    test('MM/DD/YYYY', () {
      final f = DrumDateFormat.parse('MM/DD/YYYY');
      expect(f.order, [
        DrumDateField.month,
        DrumDateField.day,
        DrumDateField.year,
      ]);
      expect(f.separator, '/');
      expect(f.twoDigitYear, isFalse);
      expect(f.yearDigits, 4);
      expect(f.displayPattern, 'MM/DD/YYYY');
    });

    test('DD-MM-YYYY uses a dash separator and day-first order', () {
      final f = DrumDateFormat.parse('DD-MM-YYYY');
      expect(f.order.first, DrumDateField.day);
      expect(f.separator, '-');
      expect(f.displayPattern, 'DD-MM-YYYY');
    });

    test('a two digit year is detected', () {
      final f = DrumDateFormat.parse('DD.MM.YY');
      expect(f.twoDigitYear, isTrue);
      expect(f.yearDigits, 2);
      expect(f.separator, '.');
      expect(f.displayPattern, 'DD.MM.YY');
    });

    test('single letter tokens are accepted', () {
      final f = DrumDateFormat.parse('D/M/YY');
      expect(f.order, [
        DrumDateField.day,
        DrumDateField.month,
        DrumDateField.year,
      ]);
      expect(f.twoDigitYear, isTrue);
    });

    test('throws on a missing field', () {
      expect(() => DrumDateFormat.parse('MM/DD'), throwsFormatException);
    });

    test('throws on a duplicate field', () {
      expect(() => DrumDateFormat.parse('MM/DD/MM'), throwsFormatException);
    });
  });

  group('DrumDateFormat presets', () {
    test('mdy, dmy, ymd display patterns', () {
      expect(DrumDateFormat.mdy.displayPattern, 'MM/DD/YYYY');
      expect(DrumDateFormat.dmy.displayPattern, 'DD/MM/YYYY');
      expect(DrumDateFormat.ymd.displayPattern, 'YYYY-MM-DD');
    });

    test('value equality with a parsed equivalent', () {
      expect(DrumDateFormat.parse('MM/DD/YYYY'), DrumDateFormat.mdy);
      expect(DrumDateFormat.parse('YYYY-MM-DD'), DrumDateFormat.ymd);
      expect(DrumDateFormat.mdy, isNot(DrumDateFormat.dmy));
    });
  });
}
