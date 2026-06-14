import 'package:flutter_test/flutter_test.dart';
import 'package:material_drum_picker/material_drum_picker.dart';

void main() {
  group('DrumPickerValue', () {
    test('equality is value-based', () {
      final a = DrumPickerValue(
          date: DateTime(2024, 6, 15), mode: DrumPickerMode.drum);
      final b = DrumPickerValue(
          date: DateTime(2024, 6, 15), mode: DrumPickerMode.drum);
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('inequality on differing fields', () {
      final a = DrumPickerValue(
          date: DateTime(2024, 6, 15), mode: DrumPickerMode.drum);
      final c = DrumPickerValue(
          date: DateTime(2024, 6, 16), mode: DrumPickerMode.drum);
      final d = DrumPickerValue(
          date: DateTime(2024, 6, 15), mode: DrumPickerMode.calendar);
      expect(a, isNot(equals(c)));
      expect(a, isNot(equals(d)));
    });

    test('copyWith replaces only the given fields', () {
      final a = DrumPickerValue(
          date: DateTime(2024, 6, 15), mode: DrumPickerMode.drum);
      final b = a.copyWith(mode: DrumPickerMode.input);
      expect(b.date, a.date);
      expect(b.mode, DrumPickerMode.input);
    });

    test('toString includes both fields', () {
      final a = DrumPickerValue(
          date: DateTime(2024, 6, 15), mode: DrumPickerMode.drum);
      expect(a.toString(), contains('drum'));
    });
  });
}
