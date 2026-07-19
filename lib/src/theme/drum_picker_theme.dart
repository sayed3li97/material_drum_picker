import 'dart:ui' show FontFeature, lerpDouble;

import 'package:flutter/material.dart';

/// A [ThemeExtension] that overrides individual visual tokens of a
/// `DrumPicker`.
///
/// Add it to [ThemeData.extensions] to customize every picker in the app, or
/// pass it to a single picker through the `theme` parameter to style just that
/// instance. A per instance `theme` is merged over the ambient extension, which
/// is merged over a set of sensible Material 3 defaults derived from the
/// ambient [ColorScheme]. Any field left `null` falls back to the next level
/// down, so you only set what you want to change.
///
/// ```dart
/// // App wide:
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
///
/// // Just one picker:
/// DrumPicker(
///   firstDate: DateTime(2000),
///   lastDate: DateTime(2100),
///   theme: const DrumPickerTheme(
///     selectedDayBackgroundColor: Colors.deepPurple,
///     dayShape: RoundedRectangleBorder(
///       borderRadius: BorderRadius.all(Radius.circular(8)),
///     ),
///     headlineTextStyle: TextStyle(fontWeight: FontWeight.w700),
///   ),
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
    this.dayForegroundColor,
    this.selectedDayBackgroundColor,
    this.selectedDayForegroundColor,
    this.todayColor,
    this.disabledDayColor,
    this.eventMarkerColor,
    this.helpTextStyle,
    this.headlineTextStyle,
    this.secondaryTextStyle,
    this.columnLabelTextStyle,
    this.selectedItemTextStyle,
    this.unselectedItemTextStyle,
    this.dayShape,
    this.selectorBandRadius,
    this.headerPadding,
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

  /// Foreground color of a normal, enabled day in the calendar grid.
  final Color? dayForegroundColor;

  /// Background color of the selected day in the calendar grid.
  final Color? selectedDayBackgroundColor;

  /// Foreground color of the selected day in the calendar grid.
  final Color? selectedDayForegroundColor;

  /// Accent color used for "today" in the calendar grid (its outline and
  /// number).
  final Color? todayColor;

  /// Foreground color of a disabled (out of range or not selectable) day.
  final Color? disabledDayColor;

  /// Default color of an event marker dot under a day in the calendar grid,
  /// used when a `DrumEventMarker` does not specify its own color.
  final Color? eventMarkerColor;

  /// Text style of the small uppercase help label above the headline.
  ///
  /// Merged over the default, so setting only some fields keeps the rest.
  final TextStyle? helpTextStyle;

  /// Text style of the large headline date (and time, when shown together).
  final TextStyle? headlineTextStyle;

  /// Text style of the optional secondary line under the headline (for example
  /// the Gregorian equivalent of a Hijri date).
  final TextStyle? secondaryTextStyle;

  /// Text style of the small uppercase column labels (DAY, MONTH, ...).
  final TextStyle? columnLabelTextStyle;

  /// Text style of the centered (selected) drum item.
  final TextStyle? selectedItemTextStyle;

  /// Text style of the non-centered drum items.
  final TextStyle? unselectedItemTextStyle;

  /// Shape of a calendar day cell. Defaults to a [CircleBorder].
  final OutlinedBorder? dayShape;

  /// Corner radius of the centered drum selector band. Defaults to `8`.
  final double? selectorBandRadius;

  /// Padding inside the picker header. Defaults to
  /// `EdgeInsets.fromLTRB(24, 16, 24, 12)`.
  final EdgeInsetsGeometry? headerPadding;

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
    Color? dayForegroundColor,
    Color? selectedDayBackgroundColor,
    Color? selectedDayForegroundColor,
    Color? todayColor,
    Color? disabledDayColor,
    Color? eventMarkerColor,
    TextStyle? helpTextStyle,
    TextStyle? headlineTextStyle,
    TextStyle? secondaryTextStyle,
    TextStyle? columnLabelTextStyle,
    TextStyle? selectedItemTextStyle,
    TextStyle? unselectedItemTextStyle,
    OutlinedBorder? dayShape,
    double? selectorBandRadius,
    EdgeInsetsGeometry? headerPadding,
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
      dayForegroundColor: dayForegroundColor ?? this.dayForegroundColor,
      selectedDayBackgroundColor:
          selectedDayBackgroundColor ?? this.selectedDayBackgroundColor,
      selectedDayForegroundColor:
          selectedDayForegroundColor ?? this.selectedDayForegroundColor,
      todayColor: todayColor ?? this.todayColor,
      disabledDayColor: disabledDayColor ?? this.disabledDayColor,
      eventMarkerColor: eventMarkerColor ?? this.eventMarkerColor,
      helpTextStyle: helpTextStyle ?? this.helpTextStyle,
      headlineTextStyle: headlineTextStyle ?? this.headlineTextStyle,
      secondaryTextStyle: secondaryTextStyle ?? this.secondaryTextStyle,
      columnLabelTextStyle: columnLabelTextStyle ?? this.columnLabelTextStyle,
      selectedItemTextStyle:
          selectedItemTextStyle ?? this.selectedItemTextStyle,
      unselectedItemTextStyle:
          unselectedItemTextStyle ?? this.unselectedItemTextStyle,
      dayShape: dayShape ?? this.dayShape,
      selectorBandRadius: selectorBandRadius ?? this.selectorBandRadius,
      headerPadding: headerPadding ?? this.headerPadding,
      itemExtent: itemExtent ?? this.itemExtent,
      visibleItemCount: visibleItemCount ?? this.visibleItemCount,
    );
  }

  /// Returns a copy of this theme with every non-null field of [other] taking
  /// precedence. Used to layer a per instance override over the ambient
  /// extension.
  DrumPickerTheme merge(DrumPickerTheme? other) {
    if (other == null) return this;
    return DrumPickerTheme(
      headerBackgroundColor:
          other.headerBackgroundColor ?? headerBackgroundColor,
      headerTextColor: other.headerTextColor ?? headerTextColor,
      cardBackgroundColor: other.cardBackgroundColor ?? cardBackgroundColor,
      selectorBandColor: other.selectorBandColor ?? selectorBandColor,
      selectedItemColor: other.selectedItemColor ?? selectedItemColor,
      unselectedItemColor: other.unselectedItemColor ?? unselectedItemColor,
      dayForegroundColor: other.dayForegroundColor ?? dayForegroundColor,
      selectedDayBackgroundColor:
          other.selectedDayBackgroundColor ?? selectedDayBackgroundColor,
      selectedDayForegroundColor:
          other.selectedDayForegroundColor ?? selectedDayForegroundColor,
      todayColor: other.todayColor ?? todayColor,
      disabledDayColor: other.disabledDayColor ?? disabledDayColor,
      eventMarkerColor: other.eventMarkerColor ?? eventMarkerColor,
      helpTextStyle: other.helpTextStyle ?? helpTextStyle,
      headlineTextStyle: other.headlineTextStyle ?? headlineTextStyle,
      secondaryTextStyle: other.secondaryTextStyle ?? secondaryTextStyle,
      columnLabelTextStyle: other.columnLabelTextStyle ?? columnLabelTextStyle,
      selectedItemTextStyle:
          other.selectedItemTextStyle ?? selectedItemTextStyle,
      unselectedItemTextStyle:
          other.unselectedItemTextStyle ?? unselectedItemTextStyle,
      dayShape: other.dayShape ?? dayShape,
      selectorBandRadius: other.selectorBandRadius ?? selectorBandRadius,
      headerPadding: other.headerPadding ?? headerPadding,
      itemExtent: other.itemExtent ?? itemExtent,
      visibleItemCount: other.visibleItemCount ?? visibleItemCount,
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
      dayForegroundColor:
          Color.lerp(dayForegroundColor, other.dayForegroundColor, t),
      selectedDayBackgroundColor: Color.lerp(
          selectedDayBackgroundColor, other.selectedDayBackgroundColor, t),
      selectedDayForegroundColor: Color.lerp(
          selectedDayForegroundColor, other.selectedDayForegroundColor, t),
      todayColor: Color.lerp(todayColor, other.todayColor, t),
      disabledDayColor: Color.lerp(disabledDayColor, other.disabledDayColor, t),
      eventMarkerColor: Color.lerp(eventMarkerColor, other.eventMarkerColor, t),
      helpTextStyle: TextStyle.lerp(helpTextStyle, other.helpTextStyle, t),
      headlineTextStyle:
          TextStyle.lerp(headlineTextStyle, other.headlineTextStyle, t),
      secondaryTextStyle:
          TextStyle.lerp(secondaryTextStyle, other.secondaryTextStyle, t),
      columnLabelTextStyle:
          TextStyle.lerp(columnLabelTextStyle, other.columnLabelTextStyle, t),
      selectedItemTextStyle:
          TextStyle.lerp(selectedItemTextStyle, other.selectedItemTextStyle, t),
      unselectedItemTextStyle: TextStyle.lerp(
          unselectedItemTextStyle, other.unselectedItemTextStyle, t),
      dayShape: t < 0.5 ? dayShape : other.dayShape,
      selectorBandRadius:
          lerpDouble(selectorBandRadius, other.selectorBandRadius, t),
      headerPadding:
          EdgeInsetsGeometry.lerp(headerPadding, other.headerPadding, t),
      itemExtent: lerpDouble(itemExtent, other.itemExtent, t),
      visibleItemCount: t < 0.5 ? visibleItemCount : other.visibleItemCount,
    );
  }

  /// Returns the effective tokens for [context], layering an optional per
  /// instance [override] over any ambient [DrumPickerTheme] extension, which in
  /// turn falls back to Material 3 defaults derived from the ambient theme.
  static DrumPickerResolved resolve(
    BuildContext context, [
    DrumPickerTheme? override,
  ]) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final ambient = theme.extension<DrumPickerTheme>();
    final ext = (ambient ?? const DrumPickerTheme()).merge(override);

    final headerBackgroundColor =
        ext.headerBackgroundColor ?? scheme.primaryContainer;
    final headerTextColor = ext.headerTextColor ?? scheme.onPrimaryContainer;
    final selectedItemColor = ext.selectedItemColor ?? scheme.primary;
    final unselectedItemColor =
        ext.unselectedItemColor ?? scheme.onSurfaceVariant;
    final selectedDayBackgroundColor =
        ext.selectedDayBackgroundColor ?? scheme.primary;
    final selectedDayForegroundColor =
        ext.selectedDayForegroundColor ?? scheme.onPrimary;
    final todayColor = ext.todayColor ?? scheme.primary;
    final dayForegroundColor = ext.dayForegroundColor ?? scheme.onSurface;
    final disabledDayColor =
        ext.disabledDayColor ?? scheme.onSurface.withValues(alpha: 0.38);
    final eventMarkerColor = ext.eventMarkerColor ?? scheme.tertiary;

    // Default text styles carry the premium refinements (tabular figures,
    // tuned weight and tracking). A non null token is merged on top so a caller
    // can tweak one field (for example weight) without losing the rest.
    TextStyle bake(TextStyle base, TextStyle? override) =>
        override == null ? base : base.merge(override);

    // Tabular figures keep digit advance widths constant, so numbers do not
    // jitter horizontally while the drum scrolls or the headline changes.
    const tnum = <FontFeature>[FontFeature.tabularFigures()];

    return DrumPickerResolved(
      headerBackgroundColor: headerBackgroundColor,
      headerTextColor: headerTextColor,
      cardBackgroundColor: ext.cardBackgroundColor ?? scheme.surface,
      // A single quiet, neutral selection band reads more premium than a loud
      // per column pill.
      selectorBandColor:
          ext.selectorBandColor ?? scheme.onSurface.withValues(alpha: 0.07),
      selectorBandBorderColor: scheme.onSurface.withValues(alpha: 0.12),
      useMagnifier: true,
      magnification: 1.15,
      overAndUnderCenterOpacity: 0.7,
      selectedItemColor: selectedItemColor,
      unselectedItemColor: unselectedItemColor,
      dayForegroundColor: dayForegroundColor,
      selectedDayBackgroundColor: selectedDayBackgroundColor,
      selectedDayForegroundColor: selectedDayForegroundColor,
      selectedDayShadowColor:
          selectedDayBackgroundColor.withValues(alpha: 0.28),
      todayColor: todayColor,
      disabledDayColor: disabledDayColor,
      eventMarkerColor: eventMarkerColor,
      rangeHighlightColor: selectedDayBackgroundColor,
      rangeFillOpacity: 0.2,
      headerBottomBorderColor: headerTextColor.withValues(alpha: 0.08),
      selectionAnimationDuration: const Duration(milliseconds: 180),
      motionDuration: const Duration(milliseconds: 220),
      helpTextStyle: bake(
        TextStyle(
          color: headerTextColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
        ext.helpTextStyle,
      ),
      headlineTextStyle: bake(
        TextStyle(
          color: headerTextColor,
          fontSize: 30,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.5,
          fontFeatures: tnum,
        ),
        ext.headlineTextStyle,
      ),
      timeHeadlineTextStyle: bake(
        TextStyle(
          color: headerTextColor,
          fontSize: 34,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.5,
          fontFeatures: tnum,
        ),
        ext.headlineTextStyle,
      ),
      secondaryTextStyle: bake(
        TextStyle(
          color: headerTextColor.withValues(alpha: 0.7),
          fontSize: 13,
        ),
        ext.secondaryTextStyle,
      ),
      columnLabelTextStyle: bake(
        TextStyle(
          color: unselectedItemColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
        ),
        ext.columnLabelTextStyle,
      ),
      selectedItemTextStyle: bake(
        TextStyle(
          fontSize: 19,
          height: 1,
          fontWeight: FontWeight.w600,
          color: selectedItemColor,
          fontFeatures: tnum,
        ),
        ext.selectedItemTextStyle,
      ),
      unselectedItemTextStyle: bake(
        TextStyle(
          fontSize: 18,
          height: 1,
          color: unselectedItemColor,
          fontFeatures: tnum,
        ),
        ext.unselectedItemTextStyle,
      ),
      dayTextStyle: const TextStyle(fontSize: 14, fontFeatures: tnum),
      daySubLabelTextStyle: TextStyle(
        fontSize: 11,
        height: 1.05,
        fontWeight: FontWeight.w500,
        color: unselectedItemColor.withValues(alpha: 0.75),
      ),
      weekdayLabelTextStyle: TextStyle(
        fontSize: 12,
        letterSpacing: 0.5,
        color: unselectedItemColor,
      ),
      dayShape: ext.dayShape ?? const CircleBorder(),
      selectorBandRadius: ext.selectorBandRadius ?? 12.0,
      headerPadding:
          ext.headerPadding ?? const EdgeInsets.fromLTRB(24, 16, 24, 12),
      itemExtent: ext.itemExtent ?? 52.0,
      visibleItemCount: ext.visibleItemCount ?? 5,
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
    required this.selectorBandBorderColor,
    required this.useMagnifier,
    required this.magnification,
    required this.overAndUnderCenterOpacity,
    required this.selectedItemColor,
    required this.unselectedItemColor,
    required this.dayForegroundColor,
    required this.selectedDayBackgroundColor,
    required this.selectedDayForegroundColor,
    required this.selectedDayShadowColor,
    required this.todayColor,
    required this.disabledDayColor,
    required this.eventMarkerColor,
    required this.rangeHighlightColor,
    required this.rangeFillOpacity,
    required this.headerBottomBorderColor,
    required this.selectionAnimationDuration,
    required this.motionDuration,
    required this.helpTextStyle,
    required this.headlineTextStyle,
    required this.timeHeadlineTextStyle,
    required this.secondaryTextStyle,
    required this.columnLabelTextStyle,
    required this.selectedItemTextStyle,
    required this.unselectedItemTextStyle,
    required this.dayTextStyle,
    required this.daySubLabelTextStyle,
    required this.weekdayLabelTextStyle,
    required this.dayShape,
    required this.selectorBandRadius,
    required this.headerPadding,
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

  /// Color of the hairline drawn at the top and bottom of the selection band.
  final Color selectorBandBorderColor;

  /// Whether the drum magnifies the centered item.
  final bool useMagnifier;

  /// The scale applied to the centered drum item when [useMagnifier] is true.
  final double magnification;

  /// The opacity of the non-centered drum rows, for a depth-of-field falloff.
  final double overAndUnderCenterOpacity;

  /// Color of the centered (selected) drum item.
  final Color selectedItemColor;

  /// Color of the non-centered drum items.
  final Color unselectedItemColor;

  /// Foreground color of a normal, enabled calendar day.
  final Color dayForegroundColor;

  /// Background color of the selected calendar day.
  final Color selectedDayBackgroundColor;

  /// Foreground color of the selected calendar day.
  final Color selectedDayForegroundColor;

  /// Soft shadow color cast by the selected calendar day chip.
  final Color selectedDayShadowColor;

  /// Accent color used for "today" in the calendar grid.
  final Color todayColor;

  /// Foreground color of a disabled calendar day.
  final Color disabledDayColor;

  /// Default color of an event marker dot under a calendar day.
  final Color eventMarkerColor;

  /// Base color of the soft fill behind days inside a selected range.
  final Color rangeHighlightColor;

  /// Opacity of the in-range fill.
  final double rangeFillOpacity;

  /// Color of the hairline separating the header from the body.
  final Color headerBottomBorderColor;

  /// Duration of the calendar day selection animation.
  final Duration selectionAnimationDuration;

  /// Duration of general transitions (mode switch, wheel sync).
  final Duration motionDuration;

  /// Resolved text style of the help label.
  final TextStyle helpTextStyle;

  /// Resolved text style of the date headline.
  final TextStyle headlineTextStyle;

  /// Resolved text style of the time-only picker headline.
  final TextStyle timeHeadlineTextStyle;

  /// Resolved text style of the secondary line.
  final TextStyle secondaryTextStyle;

  /// Resolved text style of the column labels.
  final TextStyle columnLabelTextStyle;

  /// Resolved text style of the centered drum item.
  final TextStyle selectedItemTextStyle;

  /// Resolved text style of the non-centered drum items.
  final TextStyle unselectedItemTextStyle;

  /// Resolved base text style of a calendar day number (color and weight are
  /// applied per state by the cell).
  final TextStyle dayTextStyle;

  /// Resolved text style of the weekday sub-line under a drum day number.
  final TextStyle daySubLabelTextStyle;

  /// Resolved text style of the calendar weekday header row.
  final TextStyle weekdayLabelTextStyle;

  /// Resolved shape of a calendar day cell.
  final OutlinedBorder dayShape;

  /// Resolved corner radius of the drum selector band.
  final double selectorBandRadius;

  /// Resolved header padding.
  final EdgeInsetsGeometry headerPadding;

  /// Height of a single drum item, in logical pixels.
  final double itemExtent;

  /// The number of items visible in a drum column.
  final int visibleItemCount;
}
