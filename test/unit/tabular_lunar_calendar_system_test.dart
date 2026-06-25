import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_drum_picker/material_drum_picker.dart';

/// Builds a clearly synthetic, valid dataset that alternates 30 and 29 day
/// months starting at 1446/1 on 2024-07-07. The final entry is the sentinel.
List<TabularLunarMonth> _synthetic({int months = 24}) {
  final out = <TabularLunarMonth>[];
  var g = DateTime(2024, 7, 7);
  var hy = 1446;
  var hm = 1;
  for (var i = 0; i <= months; i++) {
    out.add(
        TabularLunarMonth(hijriYear: hy, hijriMonth: hm, gregorianStart: g));
    final length = i.isEven ? 30 : 29;
    g = g.add(Duration(days: length));
    hm++;
    if (hm > 12) {
      hm = 1;
      hy++;
    }
  }
  return out;
}

void main() {
  group('TabularLunarCalendarSystem valid dataset', () {
    final sys = TabularLunarCalendarSystem(_synthetic(months: 24));

    test('selectable month count excludes the sentinel', () {
      expect(sys.selectableMonthCount, 24);
    });

    test('month length is the gap between consecutive starts', () {
      expect(sys.daysInMonth(1446, 1), 30);
      expect(sys.daysInMonth(1446, 2), 29);
      expect(sys.daysInMonth(1446, 3), 30);
    });

    test('round trips across the dataset range', () {
      var d = sys.minSupported;
      while (!d.isAfter(sys.maxSupported)) {
        final c = sys.decode(d);
        expect(sys.encode(c.year, c.month, c.day),
            DateTime(d.year, d.month, d.day),
            reason: 'round trip at $d');
        d = d.add(const Duration(days: 1));
      }
    });

    test('bounds match the first start and the last selectable day', () {
      expect(sys.minSupported, DateTime(2024, 7, 7));
      // Month 1 is 30 days, so the last selectable day is well past the start.
      expect(sys.maxSupported.isAfter(sys.minSupported), isTrue);
    });

    test('decode of the first day is 1446/1/1', () {
      final c = sys.decode(DateTime(2024, 7, 7));
      expect(c.year, 1446);
      expect(c.month, 1);
      expect(c.day, 1);
    });

    test('out of range input clamps without throwing', () {
      expect(() => sys.decode(DateTime(1900, 1, 1)), returnsNormally);
      expect(() => sys.decode(DateTime(2200, 1, 1)), returnsNormally);
    });

    test('isValid rejects an impossible day', () {
      expect(sys.isValid(1446, 2, 30), isFalse); // month 2 is 29 days
      expect(sys.isValid(1446, 2, 29), isTrue);
    });

    test('reuses the Hijri month names', () {
      expect(sys.monthName(9, abbreviated: false, locale: const Locale('en')),
          'Ramadan');
      expect(sys.monthName(9, abbreviated: false, locale: const Locale('ar')),
          'رمضان');
    });
  });

  group('TabularLunarCalendarSystem rejects malformed data', () {
    test('too short (missing sentinel)', () {
      expect(
        () => TabularLunarCalendarSystem([
          TabularLunarMonth(
              hijriYear: 1446,
              hijriMonth: 1,
              gregorianStart: DateTime(2024, 7, 7)),
        ]),
        throwsFormatException,
      );
    });

    test('a gap in the month sequence', () {
      final months = _synthetic(months: 6)..removeAt(3);
      expect(() => TabularLunarCalendarSystem(months), throwsFormatException);
    });

    test('non monotonic Gregorian starts', () {
      final months = _synthetic(months: 6);
      final tmp = months[2];
      months[2] = months[3];
      months[3] = tmp;
      expect(() => TabularLunarCalendarSystem(months), throwsFormatException);
    });

    test('a 28 day month', () {
      final months = <TabularLunarMonth>[
        TabularLunarMonth(
            hijriYear: 1446,
            hijriMonth: 1,
            gregorianStart: DateTime(2024, 7, 7)),
        // 28 days later: invalid lunar month length.
        TabularLunarMonth(
            hijriYear: 1446,
            hijriMonth: 2,
            gregorianStart: DateTime(2024, 8, 4)),
        TabularLunarMonth(
            hijriYear: 1446,
            hijriMonth: 3,
            gregorianStart: DateTime(2024, 9, 2)),
      ];
      expect(() => TabularLunarCalendarSystem(months), throwsFormatException);
    });
  });
}
