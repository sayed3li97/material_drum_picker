import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_drum_picker/material_drum_picker.dart';

/// Anchor pairs generated from the MIT-licensed hijridate reference
/// implementation of the Umm al-Qura calendar.
final List<({int hy, int hm, int hd, DateTime g})> _anchors = [
  (hy: 1356, hm: 1, hd: 1, g: DateTime(1937, 3, 14)),
  (hy: 1364, hm: 8, hd: 1, g: DateTime(1945, 7, 11)),
  (hy: 1364, hm: 8, hd: 28, g: DateTime(1945, 8, 7)),
  (hy: 1446, hm: 1, hd: 1, g: DateTime(2024, 7, 7)),
  (hy: 1446, hm: 9, hd: 15, g: DateTime(2025, 3, 15)),
  (hy: 1500, hm: 12, hd: 30, g: DateTime(2077, 11, 16)),
  (hy: 1400, hm: 1, hd: 1, g: DateTime(1979, 11, 20)),
  (hy: 1410, hm: 6, hd: 29, g: DateTime(1990, 1, 26)),
  (hy: 1420, hm: 12, hd: 30, g: DateTime(2000, 4, 5)),
  (hy: 1390, hm: 3, hd: 10, g: DateTime(1970, 5, 16)),
  (hy: 1438, hm: 3, hd: 1, g: DateTime(2016, 11, 30)),
  (hy: 1457, hm: 11, hd: 1, g: DateTime(2035, 12, 30)),
  (hy: 1368, hm: 2, hd: 1, g: DateTime(1948, 12, 2)),
  (hy: 1493, hm: 2, hd: 1, g: DateTime(2070, 3, 14)),
  (hy: 1449, hm: 10, hd: 1, g: DateTime(2028, 2, 26)),
  (hy: 1370, hm: 9, hd: 1, g: DateTime(1951, 6, 6)),
  (hy: 1410, hm: 1, hd: 1, g: DateTime(1989, 8, 2)),
  (hy: 1378, hm: 7, hd: 1, g: DateTime(1959, 1, 11)),
  (hy: 1463, hm: 2, hd: 1, g: DateTime(2041, 2, 2)),
  (hy: 1417, hm: 2, hd: 1, g: DateTime(1996, 6, 17)),
  (hy: 1497, hm: 7, hd: 1, g: DateTime(2074, 6, 26)),
  (hy: 1371, hm: 10, hd: 1, g: DateTime(1952, 6, 23)),
  (hy: 1387, hm: 4, hd: 1, g: DateTime(1967, 7, 8)),
  (hy: 1371, hm: 10, hd: 1, g: DateTime(1952, 6, 23)),
  (hy: 1457, hm: 1, hd: 1, g: DateTime(2035, 3, 11)),
  (hy: 1412, hm: 1, hd: 1, g: DateTime(1991, 7, 12)),
  (hy: 1498, hm: 3, hd: 1, g: DateTime(2075, 2, 16)),
  (hy: 1430, hm: 7, hd: 1, g: DateTime(2009, 6, 24)),
  (hy: 1392, hm: 9, hd: 1, g: DateTime(1972, 10, 8)),
  (hy: 1386, hm: 10, hd: 1, g: DateTime(1967, 1, 12)),
  (hy: 1434, hm: 9, hd: 1, g: DateTime(2013, 7, 9)),
  (hy: 1402, hm: 2, hd: 1, g: DateTime(1981, 11, 27)),
  (hy: 1404, hm: 6, hd: 1, g: DateTime(1984, 3, 3)),
  (hy: 1380, hm: 9, hd: 1, g: DateTime(1961, 2, 16)),
  (hy: 1372, hm: 10, hd: 1, g: DateTime(1953, 6, 13)),
  (hy: 1371, hm: 10, hd: 1, g: DateTime(1952, 6, 23)),
  (hy: 1408, hm: 8, hd: 1, g: DateTime(1988, 3, 19)),
  (hy: 1492, hm: 7, hd: 1, g: DateTime(2069, 8, 18)),
  (hy: 1436, hm: 8, hd: 1, g: DateTime(2015, 5, 19)),
  (hy: 1472, hm: 6, hd: 1, g: DateTime(2050, 2, 23)),
];

void main() {
  const sys = HijriCalendarSystem();

  group('HijriCalendarSystem anchors', () {
    for (final a in _anchors) {
      test('encode \${a.hy}/\${a.hm}/\${a.hd}', () {
        expect(sys.encode(a.hy, a.hm, a.hd), a.g);
      });
      test('decode \${a.g}', () {
        final c = sys.decode(a.g);
        expect(c.year, a.hy);
        expect(c.month, a.hm);
        expect(c.day, a.hd);
      });
    }
  });

  test('round trip across the supported range', () {
    var d = sys.minSupported;
    final end = sys.maxSupported;
    while (!d.isAfter(end)) {
      final c = sys.decode(d);
      final back = sys.encode(c.year, c.month, c.day);
      expect(back, DateTime(d.year, d.month, d.day),
          reason: 'round trip at \$d');
      d = d.add(const Duration(days: 17));
    }
  });

  test('supported range matches the published Umm al-Qura bounds', () {
    expect(sys.minSupported, DateTime(1937, 3, 14));
    expect(sys.maxSupported, DateTime(2077, 11, 16));
  });

  test('a normal year has 12 months of 29 or 30 days summing to 354 or 355',
      () {
    var total = 0;
    for (var m = 1; m <= 12; m++) {
      final len = sys.daysInMonth(1446, m);
      expect(len == 29 || len == 30, isTrue, reason: 'month \$m is \$len');
      total += len;
    }
    expect(total == 354 || total == 355, isTrue, reason: 'year is \$total');
  });

  test('faithfully reproduces the tabular short month at 1364/8', () {
    // The official Umm al-Qura table records this early month as 28 days.
    // Reproducing it exactly is what keeps decode and encode round tripping.
    expect(sys.daysInMonth(1364, 8), 28);
  });

  test('does not throw at or beyond the range boundary', () {
    expect(() => sys.decode(DateTime(1800, 1, 1)), returnsNormally);
    expect(() => sys.decode(DateTime(2200, 1, 1)), returnsNormally);
    expect(() => sys.encode(1356, 1, 1), returnsNormally);
    expect(() => sys.encode(1500, 12, 30), returnsNormally);
  });

  test('month names localize for en and ar', () {
    expect(sys.monthName(9, abbreviated: false, locale: const Locale('en')),
        'Ramadan');
    expect(sys.monthName(9, abbreviated: false, locale: const Locale('ar')),
        'رمضان');
  });
}
