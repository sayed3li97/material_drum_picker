import 'package:flutter_test/flutter_test.dart';
import 'package:material_drum_picker/material_drum_picker.dart';

void main() {
  group('DrumQuickSelect', () {
    test('relative with offset adds the correct number of days', () {
      final ref = DateTime(2024, 6, 15);
      final chip = DrumQuickSelect.relative(
        label: 'test',
        offset: const Duration(days: 7),
        referenceDate: ref,
      );
      expect(chip.date, DateTime(2024, 6, 22));
      expect(chip.label, 'test');
    });

    test('relative normalizes to midnight', () {
      final ref = DateTime(2024, 6, 15, 13, 45);
      final chip = DrumQuickSelect.relative(
        label: 'today',
        offset: Duration.zero,
        referenceDate: ref,
      );
      expect(chip.date, DateTime(2024, 6, 15));
    });

    test('relative rolls over month boundaries', () {
      final ref = DateTime(2024, 6, 28);
      final chip = DrumQuickSelect.relative(
        label: '+7',
        offset: const Duration(days: 7),
        referenceDate: ref,
      );
      expect(chip.date, DateTime(2024, 7, 5));
    });

    test('equality is value-based', () {
      final a = DrumQuickSelect(label: 'A', date: DateTime(2024, 6, 15));
      final b = DrumQuickSelect(label: 'A', date: DateTime(2024, 6, 15));
      final c = DrumQuickSelect(label: 'B', date: DateTime(2024, 6, 15));
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(equals(c)));
    });
  });
}
