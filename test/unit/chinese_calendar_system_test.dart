import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_drum_picker/material_drum_picker.dart';

void main() {
  const sys = ChineseCalendarSystem();

  group('decode and encode anchors (oracle: sxtwl)', () {
    // (gregorianY, M, D) -> (lunarYear, sequenceIndex, day, isLeap).
    const anchors = <List<Object>>[
      [2023, 1, 22, 2023, 1, 1, false], // Chinese New Year 2023
      [2023, 2, 20, 2023, 2, 1, false],
      [2023, 3, 22, 2023, 3, 1, true], // leap month 2 (闰二月)
      [2023, 4, 20, 2023, 4, 1, false],
      [2023, 5, 19, 2023, 5, 1, false],
      [2024, 2, 10, 2024, 1, 1, false], // Chinese New Year 2024
      [2024, 1, 1, 2023, 12, 20, false],
      [2020, 5, 23, 2020, 5, 1, true], // leap month 4 (闰四月)
      [2020, 6, 21, 2020, 6, 1, false],
      [2017, 7, 23, 2017, 7, 1, true], // leap month 6
      [2025, 1, 29, 2025, 1, 1, false],
      [2000, 2, 5, 2000, 1, 1, false],
      [2033, 12, 22, 2033, 12, 1, true],
      [1900, 1, 31, 1900, 1, 1, false], // first supported year
      [2100, 12, 30, 2100, 11, 30, false],
      [2014, 10, 24, 2014, 10, 1, true], // leap month 9
      [2014, 11, 22, 2014, 11, 1, false],
    ];

    for (final a in anchors) {
      final gy = a[0] as int, gm = a[1] as int, gd = a[2] as int;
      final ly = a[3] as int, idx = a[4] as int, day = a[5] as int;
      final leap = a[6] as bool;
      test('$gy-$gm-$gd <-> $ly/$idx/$day leap=$leap', () {
        final c = sys.decode(DateTime(gy, gm, gd));
        expect(c.year, ly);
        expect(c.month, idx);
        expect(c.day, day);
        expect(c.isLeapMonth, leap);
        expect(sys.encode(ly, idx, day), DateTime(gy, gm, gd));
      });
    }
  });

  test('round trips every day across a dense window', () {
    var d = DateTime(2000, 1, 1);
    final end = DateTime(2040, 1, 1);
    while (!d.isAfter(end)) {
      final c = sys.decode(d);
      expect(
          sys.encode(c.year, c.month, c.day), DateTime(d.year, d.month, d.day),
          reason: 'round trip at $d');
      d = d.add(const Duration(days: 1));
    }
  });

  test('round trips weekly across the whole supported range', () {
    var d = sys.minSupported;
    while (!d.isAfter(sys.maxSupported)) {
      final c = sys.decode(d);
      expect(
          sys.encode(c.year, c.month, c.day), DateTime(d.year, d.month, d.day));
      d = d.add(const Duration(days: 7));
    }
  });

  group('leap years and month counts', () {
    test('months in year is 12 or 13 with the leap in the right place', () {
      expect(sys.monthsInYear(2023), 13);
      expect(sys.monthsInYear(2024), 12);
      expect(sys.monthsInYear(2020), 13);
      expect(sys.monthsInYear(2017), 13);
      // 2023's leap month sits at sequence index 3 (闰二月).
      expect(sys.decode(DateTime(2023, 3, 22)).isLeapMonth, isTrue);
      expect(sys.decode(DateTime(2023, 2, 20)).isLeapMonth, isFalse);
    });

    test('day lengths match the 2023 sequence (29/30)', () {
      const lengths = [29, 30, 29, 29, 30, 30, 29, 30, 30, 29, 30, 29, 30];
      for (var i = 0; i < lengths.length; i++) {
        expect(sys.daysInMonth(2023, i + 1), lengths[i],
            reason: 'month ${i + 1}');
      }
    });
  });

  group('isValid', () {
    test('accepts the leap month and rejects a 13th month in a normal year',
        () {
      expect(sys.isValid(2023, 3, 1), isTrue); // leap month
      expect(sys.isValid(2023, 13, 1), isTrue); // 2023 has 13 months
      expect(sys.isValid(2024, 13, 1), isFalse); // 2024 has only 12
      expect(sys.isValid(2023, 3, 30), isFalse); // leap month 2 is 29 days
      expect(sys.isValid(2023, 3, 29), isTrue);
    });

    test('rejects out of range years', () {
      expect(sys.isValid(1800, 1, 1), isFalse);
      expect(sys.isValid(2200, 1, 1), isFalse);
    });
  });

  group('labels', () {
    const zh = Locale('zh');
    const en = Locale('en');

    test('traditional month names with the leap prefix', () {
      // 2023 index 2 = 二月; index 3 = 闰二月; index 4 = 三月.
      expect(
          sys.monthLabel(2023, 2,
              numeric: false, abbreviated: false, locale: zh),
          '二月');
      expect(
          sys.monthLabel(2023, 3,
              numeric: false, abbreviated: false, locale: zh),
          '闰二月');
      expect(
          sys.monthLabel(2023, 4,
              numeric: false, abbreviated: false, locale: zh),
          '三月');
    });

    test('English uses numbered months with a leap marker', () {
      expect(
          sys.monthLabel(2023, 3,
              numeric: false, abbreviated: true, locale: en),
          'Leap 2');
      expect(
          sys.monthLabel(2023, 4,
              numeric: false, abbreviated: true, locale: en),
          '3');
      expect(
          sys.monthLabel(2023, 3,
              numeric: false, abbreviated: false, locale: en),
          'Leap Month 2');
    });

    test('sexagenary year and zodiac', () {
      expect(sys.yearAnnotation(2023, zh), '癸卯');
      expect(sys.yearAnnotation(2023, en), 'Rabbit');
      expect(sys.yearAnnotation(2024, zh), '甲辰');
      expect(sys.yearAnnotation(2024, en), 'Dragon');
    });
  });

  test('supported range covers 1900 to 2100', () {
    expect(sys.minSupported, DateTime(1900, 1, 31));
    expect(sys.maxSupported.year, greaterThanOrEqualTo(2100));
  });
}
