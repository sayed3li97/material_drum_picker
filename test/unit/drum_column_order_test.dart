import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_drum_picker/material_drum_picker.dart';
import 'package:material_drum_picker/src/utils/drum_locale_utils.dart';

void main() {
  group('DrumColumnOrder enum', () {
    test('has four values', () {
      expect(DrumColumnOrder.values.length, 4);
    });
  });

  group('DrumLocaleUtils.columnOrderForLocale', () {
    test('US English defaults to MDY', () {
      expect(
        DrumLocaleUtils.columnOrderForLocale(const Locale('en', 'US')),
        DrumColumnOrder.mdy,
      );
    });

    test('Canadian English defaults to MDY', () {
      expect(
        DrumLocaleUtils.columnOrderForLocale(const Locale('en', 'CA')),
        DrumColumnOrder.mdy,
      );
    });

    test('UK English defaults to DMY', () {
      expect(
        DrumLocaleUtils.columnOrderForLocale(const Locale('en', 'GB')),
        DrumColumnOrder.dmy,
      );
    });

    test('Japanese defaults to YMD', () {
      expect(
        DrumLocaleUtils.columnOrderForLocale(const Locale('ja')),
        DrumColumnOrder.ymd,
      );
    });

    test('Chinese and Korean default to YMD', () {
      expect(DrumLocaleUtils.columnOrderForLocale(const Locale('zh')),
          DrumColumnOrder.ymd);
      expect(DrumLocaleUtils.columnOrderForLocale(const Locale('ko')),
          DrumColumnOrder.ymd);
    });

    test('French defaults to DMY', () {
      expect(
        DrumLocaleUtils.columnOrderForLocale(const Locale('fr', 'FR')),
        DrumColumnOrder.dmy,
      );
    });

    test('null locale defaults to DMY', () {
      expect(DrumLocaleUtils.columnOrderForLocale(null), DrumColumnOrder.dmy);
    });
  });
}
