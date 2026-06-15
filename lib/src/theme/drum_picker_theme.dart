import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// A [ThemeExtension] that overrides individual visual tokens of a
/// `DrumPicker`.
///
/// Add it to [ThemeData.extensions] to customize the picker app-wide without
/// touching the global [ColorScheme]. Any field left `null` falls back to a
/// sensible Material 3 default derived from the ambient theme.
///
/// ```dart
/// ThemeData(
///   useMaterial3: true,
///   extensions: const [
///     DrumPickerTheme(
///       headerBackgroundColor: Color(0xFF004D40),
///       headerTextColor: Colors.white,
///       itemExtent: 48,
///       visibleItemCount: 3,
///     ),
///   ],
/// )
/// ```
@immutable
class DrumPickerTheme extends ThemeExtension<DrumPickerTheme> {
  /// Creates a set of [DrumPicker] token overrides.
  const DrumPickerTheme({
    this.headerBackgroundColor,
    this.headerTextColor,
    this.cardBackgroundColor,
    this.selectorBandColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.itemExtent,
    this.visibleItemCount,
  });

  /// Background color of the picker header.
  final Color? headerBackgroundColor;

  /// Foreground (text/icon) color of the picker header.
  final Color? headerTextColor;

  /// Background color of the picker card/body.
  final Color? cardBackgroundColor;

  /// Color of the highlight band drawn over the centered drum item.
  final Color? selectorBandColor;

  /// Color of the centered (selected) drum item text.
  final Color? selectedItemColor;

  /// Color of the non-centered drum item text.
  final Color? unselectedItemColor;

  /// Height of a single drum item, in logical pixels. Defaults to `44`.
  final double? itemExtent;

  /// The number of items visible in a drum column. Defaults to `5`.
  ///
  /// Should be an odd number so that one item is centered.
  final int? visibleItemCount;

  @override
  DrumPickerTheme copyWith({
    Color? headerBackgroundColor,
    Color? headerTextColor,
    Color? cardBackgroundColor,
    Color? selectorBandColor,
    Color? selectedItemColor,
    Color? unselectedItemColor,
    double? itemExtent,
    int? visibleItemCount,
  }) {
    return DrumPickerTheme(
      headerBackgroundColor:
          headerBackgroundColor ?? this.headerBackgroundColor,
      headerTextColor: headerTextColor ?? this.headerTextColor,
      cardBackgroundColor: cardBackgroundColor ?? this.cardBackgroundColor,
      selectorBandColor: selectorBandColor ?? this.selectorBandColor,
      selectedItemColor: selectedItemColor ?? this.selectedItemColor,
      unselectedItemColor: unselectedItemColor ?? this.unselectedItemColor,
      itemExtent: itemExtent ?? this.itemExtent,
      visibleItemCount: visibleItemCount ?? this.visibleItemCount,
    );
  }

  @override
  DrumPickerTheme lerp(ThemeExtension<DrumPickerTheme>? other, double t) {
    if (other is! DrumPickerTheme) return this;
    return DrumPickerTheme(
      headerBackgroundColor:
          Color.lerp(headerBackgroundColor, other.headerBackgroundColor, t),
      headerTextColor: Color.lerp(headerTextColor, other.headerTextColor, t),
      cardBackgroundColor:
          Color.lerp(cardBackgroundColor, other.cardBackgroundColor, t),
      selectorBandColor:
          Color.lerp(selectorBandColor, other.selectorBandColor, t),
      selectedItemColor:
          Color.lerp(selectedItemColor, other.selectedItemColor, t),
      unselectedItemColor:
          Color.lerp(unselectedItemColor, other.unselectedItemColor, t),
      itemExtent: lerpDouble(itemExtent, other.itemExtent, t),
      visibleItemCount: t < 0.5 ? visibleItemCount : other.visibleItemCount,
    );
  }

  /// Returns the effective theme for [context], merging any ambient
  /// [DrumPickerTheme] extension with this package's defaults.
  static DrumPickerResolved resolve(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final ext = theme.extension<DrumPickerTheme>();

    return DrumPickerResolved(
      headerBackgroundColor:
          ext?.headerBackgroundColor ?? scheme.primaryContainer,
      headerTextColor: ext?.headerTextColor ?? scheme.onPrimaryContainer,
      cardBackgroundColor: ext?.cardBackgroundColor ?? scheme.surface,
      selectorBandColor: ext?.selectorBandColor ??
          scheme.primaryContainer.withValues(alpha: 0.5),
      selectedItemColor: ext?.selectedItemColor ?? scheme.primary,
      unselectedItemColor: ext?.unselectedItemColor ?? scheme.onSurfaceVariant,
      itemExtent: ext?.itemExtent ?? 44.0,
      visibleItemCount: ext?.visibleItemCount ?? 5,
    );
  }
}

/// A fully-resolved set of [DrumPicker] tokens, with no `null` fields.
///
/// Produced by [DrumPickerTheme.resolve].
@immutable
class DrumPickerResolved {
  /// Creates a resolved token set. All fields are required.
  const DrumPickerResolved({
    required this.headerBackgroundColor,
    required this.headerTextColor,
    required this.cardBackgroundColor,
    required this.selectorBandColor,
    required this.selectedItemColor,
    required this.unselectedItemColor,
    required this.itemExtent,
    required this.visibleItemCount,
  });

  /// Background color of the picker header.
  final Color headerBackgroundColor;

  /// Foreground color of the picker header.
  final Color headerTextColor;

  /// Background color of the picker card/body.
  final Color cardBackgroundColor;

  /// Color of the highlight band over the centered drum item.
  final Color selectorBandColor;

  /// Color of the centered (selected) drum item.
  final Color selectedItemColor;

  /// Color of the non-centered drum items.
  final Color unselectedItemColor;

  /// Height of a single drum item, in logical pixels.
  final double itemExtent;

  /// The number of items visible in a drum column.
  final int visibleItemCount;
}
