import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_drum_picker/material_drum_picker.dart';

void main() {
  const sys = JalaliCalendarSystem();

  group('decode and encode anchors (oracle: jdatetime)', () {
    // (gregorianY, M, D) -> (jalaliY, M, D). Generated from the reference
    // Iranian civil calendar (Python jdatetime) and verified to match exactly
    // across the whole supported range.
    const anchors = <List<int>>[
      [1799, 3, 21, 1178, 1, 1], // first supported day (Nowruz 1178)
      [1848, 6, 29, 1227, 4, 8],
      [1848, 9, 26, 1227, 7, 4],
      [1854, 2, 13, 1232, 11, 24],
      [1880, 7, 21, 1259, 4, 31],
      [1915, 6, 15, 1294, 3, 24],
      [1921, 3, 21, 1300, 1, 1],
      [1971, 9, 22, 1350, 6, 31], // last 31 day month
      [1971, 10, 22, 1350, 7, 30],
      [2015, 7, 6, 1394, 4, 15],
      [2017, 3, 21, 1396, 1, 1],
      [2017, 8, 31, 1396, 6, 9],
      [2021, 3, 20, 1399, 12, 30], // leap Esfand
      [2021, 3, 21, 1400, 1, 1],
      [2023, 3, 20, 1401, 12, 29], // common Esfand
      [2024, 3, 20, 1403, 1, 1], // Nowruz 1403
      [2025, 3, 20, 1403, 12, 30], // leap Esfand
      [2025, 3, 21, 1404, 1, 1],
      [2059, 12, 22, 1438, 10, 1],
      [2080, 5, 8, 1459, 2, 19],
      [2088, 7, 13, 1467, 4, 23],
      [2102, 8, 17, 1481, 5, 26],
      [2121, 9, 23, 1500, 7, 1],
      [2128, 4, 20, 1507, 2, 1],
      [2134, 3, 9, 1512, 12, 18],
      [2180, 7, 29, 1559, 5, 8],
      [2191, 8, 26, 1570, 6, 4],
      [2213, 6, 13, 1592, 3, 23],
      [2246, 4, 14, 1625, 1, 25],
      [2255, 3, 20, 1633, 12, 29], // last supported day
    ];

    for (final a in anchors) {
      final gy = a[0], gm = a[1], gd = a[2];
      final jy = a[3], jm = a[4], jd = a[5];
      test('$gy-$gm-$gd <-> $jy/$jm/$jd', () {
        final c = sys.decode(DateTime(gy, gm, gd));
        expect(c.year, jy);
        expect(c.month, jm);
        expect(c.day, jd);
        expect(c.isLeapMonth, isFalse);
        expect(sys.encode(jy, jm, jd), DateTime(gy, gm, gd));
      });
    }
  });

  test('round trips every day across a dense window', () {
    var d = DateTime(2000, 1, 1);
    final end = DateTime(2050, 1, 1);
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
      final back = sys.encode(c.year, c.month, c.day);
      expect(back, DateTime(d.year, d.month, d.day),
          reason: 'round trip at $d');
      d = d.add(const Duration(days: 7));
    }
  });

  group('month lengths', () {
    test('first six months have 31 days, next five have 30', () {
      for (var m = 1; m <= 6; m++) {
        expect(sys.daysInMonth(1400, m), 31, reason: 'month $m');
      }
      for (var m = 7; m <= 11; m++) {
        expect(sys.daysInMonth(1400, m), 30, reason: 'month $m');
      }
    });

    test('Esfand is 29 days in a common year and 30 in a leap year', () {
      expect(sys.daysInMonth(1400, 12), 29); // common
      expect(sys.daysInMonth(1403, 12), 30); // leap
      expect(sys.daysInMonth(1399, 12), 30); // leap
      expect(sys.daysInMonth(1401, 12), 29); // common
    });

    test('every month across the range has 29, 30, or 31 days', () {
      for (var y = 1178; y <= 1633; y++) {
        for (var m = 1; m <= 12; m++) {
          final dim = sys.daysInMonth(y, m);
          expect(dim, anyOf(29, 30, 31), reason: '$y/$m');
        }
      }
    });
  });

  group('isValid', () {
    test('accepts in range dates and rejects out of range', () {
      expect(sys.isValid(1403, 1, 1), isTrue);
      expect(sys.isValid(1403, 12, 30), isTrue); // leap Esfand
      expect(sys.isValid(1400, 12, 30), isFalse); // common Esfand has 29
      expect(sys.isValid(1403, 0, 1), isFalse);
      expect(sys.isValid(1403, 13, 1), isFalse);
      expect(sys.isValid(1403, 1, 0), isFalse);
      expect(sys.isValid(1177, 1, 1), isFalse); // before range
      expect(sys.isValid(1634, 1, 1), isFalse); // after range
    });
  });

  group('month names', () {
    test('English names', () {
      const locale = Locale('en');
      expect(sys.monthName(1, abbreviated: false, locale: locale), 'Farvardin');
      expect(sys.monthName(7, abbreviated: false, locale: locale), 'Mehr');
      expect(sys.monthName(12, abbreviated: false, locale: locale), 'Esfand');
      expect(sys.monthName(1, abbreviated: true, locale: locale), 'Far');
    });

    test('Persian names', () {
      const locale = Locale('fa');
      expect(sys.monthName(1, abbreviated: false, locale: locale), 'فروردین');
      expect(sys.monthName(12, abbreviated: false, locale: locale), 'اسفند');
    });

    test('numeric monthLabel pads to two digits', () {
      const locale = Locale('en');
      expect(
        sys.monthLabel(1400, 3,
            numeric: true, abbreviated: false, locale: locale),
        '03',
      );
    });
  });

  test('out of range dates clamp instead of throwing', () {
    // Well before and after the supported window.
    expect(() => sys.decode(DateTime(1500, 1, 1)), returnsNormally);
    expect(() => sys.decode(DateTime(2400, 1, 1)), returnsNormally);
    final early = sys.decode(DateTime(1500, 1, 1));
    expect(early.year, 1178); // clamped to first supported day
  });
}
