import 'package:flutter_test/flutter_test.dart';
import 'package:material_drum_picker/material_drum_picker.dart';

void main() {
  group('DrumDateUtils.daysInMonth', () {
    test('returns 31 for January', () {
      expect(DrumDateUtils.daysInMonth(2024, 1), 31);
    });

    test('returns 29 for February in a leap year', () {
      expect(DrumDateUtils.daysInMonth(2024, 2), 29);
    });

    test('returns 28 for February in a non-leap year', () {
      expect(DrumDateUtils.daysInMonth(2023, 2), 28);
    });

    test('returns 28 for February in a century non-leap year', () {
      expect(DrumDateUtils.daysInMonth(1900, 2), 28);
    });

    test('returns 29 for February in a 400-divisible year', () {
      expect(DrumDateUtils.daysInMonth(2000, 2), 29);
    });

    test('returns 30 for April', () {
      expect(DrumDateUtils.daysInMonth(2024, 4), 30);
    });
  });

  group('DrumDateUtils.isSameDay', () {
    test('true for same day, different time', () {
      expect(
        DrumDateUtils.isSameDay(
          DateTime(2024, 6, 15, 9),
          DateTime(2024, 6, 15, 23),
        ),
        isTrue,
      );
    });

    test('false for different days', () {
      expect(
        DrumDateUtils.isSameDay(DateTime(2024, 6, 15), DateTime(2024, 6, 16)),
        isFalse,
      );
    });

    test('false when either is null', () {
      expect(DrumDateUtils.isSameDay(null, DateTime(2024)), isFalse);
      expect(DrumDateUtils.isSameDay(DateTime(2024), null), isFalse);
    });
  });

  group('DrumDateUtils.clamp', () {
    final first = DateTime(2024, 6, 1);
    final last = DateTime(2024, 6, 30);

    test('returns date unchanged when in range', () {
      expect(DrumDateUtils.clamp(DateTime(2024, 6, 15), first, last),
          DateTime(2024, 6, 15));
    });

    test('clamps to first when before range', () {
      expect(DrumDateUtils.clamp(DateTime(2024, 1, 1), first, last), first);
    });

    test('clamps to last when after range', () {
      expect(DrumDateUtils.clamp(DateTime(2024, 12, 1), first, last), last);
    });
  });

  group('DrumDateUtils.addMonths', () {
    test('adds months within the same year', () {
      expect(DrumDateUtils.addMonths(DateTime(2024, 1, 15), 2),
          DateTime(2024, 3, 15));
    });

    test('rolls over the year boundary', () {
      expect(DrumDateUtils.addMonths(DateTime(2024, 11, 10), 3),
          DateTime(2025, 2, 10));
    });

    test('clamps the day to the shorter target month', () {
      expect(DrumDateUtils.addMonths(DateTime(2024, 1, 31), 1),
          DateTime(2024, 2, 29));
    });

    test('subtracts months with a negative delta', () {
      expect(DrumDateUtils.addMonths(DateTime(2024, 3, 15), -4),
          DateTime(2023, 11, 15));
    });
  });

  group('DrumDateUtils.isInRange / monthCount', () {
    test('isInRange is inclusive of the bounds', () {
      final first = DateTime(2024, 6, 1);
      final last = DateTime(2024, 6, 30);
      expect(DrumDateUtils.isInRange(first, first, last), isTrue);
      expect(DrumDateUtils.isInRange(last, first, last), isTrue);
      expect(
          DrumDateUtils.isInRange(DateTime(2024, 7, 1), first, last), isFalse);
    });

    test('monthCount counts inclusive months across years', () {
      expect(
          DrumDateUtils.monthCount(DateTime(2024, 1), DateTime(2024, 12)), 12);
      expect(
          DrumDateUtils.monthCount(DateTime(2024, 11), DateTime(2025, 2)), 4);
    });
  });

  group('DrumDateUtils.combine', () {
    test('merges the date part with the given hour and minute', () {
      expect(
        DrumDateUtils.combine(DateTime(2024, 6, 15, 1, 2), 14, 30),
        DateTime(2024, 6, 15, 14, 30),
      );
    });
  });

  group('DrumDateUtils.snapMinute', () {
    test('returns the minute unchanged for interval 1', () {
      expect(DrumDateUtils.snapMinute(37, 1), 37);
    });

    test('snaps down to the nearest multiple of the interval', () {
      expect(DrumDateUtils.snapMinute(37, 15), 30);
      expect(DrumDateUtils.snapMinute(44, 15), 30);
      expect(DrumDateUtils.snapMinute(45, 15), 45);
      expect(DrumDateUtils.snapMinute(7, 5), 5);
    });
  });
}
