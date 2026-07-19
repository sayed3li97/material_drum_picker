import 'package:flutter/material.dart';

import '../../models/drum_event_marker.dart';
import '../../theme/drum_picker_theme.dart';

/// A single day cell in the calendar grid.
///
/// Exposed (non-private) for widget tests. Not part of the public package API.
class DayCell extends StatelessWidget {
  /// Creates a day cell.
  const DayCell({
    super.key,
    required this.day,
    required this.isEnabled,
    required this.isSelected,
    required this.isToday,
    required this.onTap,
    required this.tokens,
    this.label,
    this.markers = const [],
    this.markerBuilder,
    this.markerDate,
    this.maxMarkers = kDefaultMaxEventMarkers,
    this.isInRange = false,
  });

  /// The day-of-month number shown in the cell.
  final int day;

  /// The text to display, defaulting to [day]. Pass a localized numeral string
  /// so non Latin locales render their own digits.
  final String? label;

  /// Whether the cell may be tapped. Disabled cells are greyed out.
  final bool isEnabled;

  /// Whether this cell is the current selection.
  final bool isSelected;

  /// Whether this cell represents "today".
  final bool isToday;

  /// Called when an enabled cell is tapped.
  final VoidCallback onTap;

  /// Resolved visual tokens.
  final DrumPickerResolved tokens;

  /// Event markers to show under the day. Empty for days with no events.
  final List<DrumEventMarker> markers;

  /// Optional builder that replaces the default row of dots. When it returns
  /// null (or is null) the default dots are used.
  final DrumMarkerBuilder? markerBuilder;

  /// The canonical Gregorian date of this cell, passed to [markerBuilder].
  final DateTime? markerDate;

  /// The maximum number of dots the default marker row renders.
  final int maxMarkers;

  /// Whether this day falls inside a selected range (drawn with a soft fill
  /// behind the cell). The range endpoints also set [isSelected].
  final bool isInRange;

  Widget? _buildMarkers(BuildContext context) {
    if (markers.isEmpty) return null;
    if (markerBuilder != null && markerDate != null) {
      final custom = markerBuilder!(context, markerDate!, markers);
      if (custom != null) return custom;
    }
    final shown = markers.length > maxMarkers ? maxMarkers : markers.length;
    final defaultColor = isSelected
        ? tokens.selectedDayForegroundColor
        : tokens.eventMarkerColor;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < shown; i++)
          Container(
            width: 5,
            height: 5,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              color: markers[i].color ?? defaultColor,
              shape: BoxShape.circle,
            ),
          ),
      ],
    );
  }

  String _semanticsLabel() {
    if (markers.isEmpty) return '$day';
    final described = markers
        .map((m) => m.semanticLabel)
        .whereType<String>()
        .where((s) => s.isNotEmpty)
        .toList();
    if (described.isNotEmpty) return '$day, ${described.join(', ')}';
    final n = markers.length;
    return '$day, $n ${n == 1 ? 'event' : 'events'}';
  }

  @override
  Widget build(BuildContext context) {
    Color foreground = tokens.dayForegroundColor;
    if (isSelected) {
      foreground = tokens.selectedDayForegroundColor;
    } else if (!isEnabled) {
      foreground = tokens.disabledDayColor;
    } else if (isToday) {
      foreground = tokens.todayColor;
    }

    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final animDuration =
        reduceMotion ? Duration.zero : tokens.selectionAnimationDuration;

    // Today (when not selected) gets a thicker accent ring on the day shape.
    final shape = isToday && !isSelected
        ? tokens.dayShape
            .copyWith(side: BorderSide(color: tokens.todayColor, width: 1.5))
        : tokens.dayShape;

    final markerRow = _buildMarkers(context);

    final content = Material(
      type: MaterialType.transparency,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: AnimatedDefaultTextStyle(
                duration: animDuration,
                curve: Curves.easeOutCubic,
                // Merge over the ambient default so the app's font family is
                // kept (AnimatedDefaultTextStyle otherwise replaces it).
                style: DefaultTextStyle.of(context)
                    .style
                    .merge(tokens.dayTextStyle)
                    .copyWith(
                      color: foreground,
                      fontWeight: isSelected || isToday
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                child: Text(label ?? '$day'),
              ),
            ),
            if (markerRow != null) Positioned(bottom: 5, child: markerRow),
          ],
        ),
      ),
    );

    // The selection chip: an animated fill with a soft lift shadow, using the
    // themed day shape (not a hardcoded circle) so a custom shape still works.
    // A DecoratedBox (not AnimatedContainer) keeps the widget tree free of an
    // extra Container so tests can count marker dots cleanly.
    Widget cell = TweenAnimationBuilder<double>(
      tween: Tween<double>(end: isSelected ? 1 : 0),
      duration: animDuration,
      curve: Curves.easeOutCubic,
      child: content,
      builder: (context, t, child) {
        return DecoratedBox(
          decoration: ShapeDecoration(
            shape: shape,
            color: Color.lerp(
                Colors.transparent, tokens.selectedDayBackgroundColor, t),
            shadows: t > 0
                ? [
                    BoxShadow(
                      color: tokens.selectedDayShadowColor.withValues(
                          alpha: tokens.selectedDayShadowColor.a * t),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: child,
        );
      },
    );

    if (isInRange) {
      // A soft fill behind the cell marks the days within the range.
      cell = Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: tokens.rangeHighlightColor
                    .withValues(alpha: tokens.rangeFillOpacity),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          cell,
        ],
      );
    }

    return Semantics(
      button: true,
      container: true,
      excludeSemantics: true,
      enabled: isEnabled,
      selected: isSelected,
      label: _semanticsLabel(),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: SizedBox(
          // 44dp minimum touch target (WCAG 2.5.5).
          width: 44,
          height: 44,
          child: cell,
        ),
      ),
    );
  }
}
