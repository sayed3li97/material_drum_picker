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
    Color background = Colors.transparent;
    Color foreground = tokens.dayForegroundColor;
    if (isSelected) {
      background = tokens.selectedDayBackgroundColor;
      foreground = tokens.selectedDayForegroundColor;
    } else if (!isEnabled) {
      foreground = tokens.disabledDayColor;
    } else if (isToday) {
      foreground = tokens.todayColor;
    }

    if (isInRange && !isSelected && isEnabled) {
      // An in-range day that is not an endpoint keeps the normal foreground.
      foreground = tokens.dayForegroundColor;
    }

    final shape = isToday && !isSelected
        ? tokens.dayShape.copyWith(side: BorderSide(color: tokens.todayColor))
        : tokens.dayShape;

    final markerRow = _buildMarkers(context);

    // The day circle with its number and any event markers.
    Widget cell = Material(
      color: background,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: Text(
                label ?? '$day',
                style: TextStyle(
                  color: foreground,
                  fontWeight: isSelected || isToday ? FontWeight.w600 : null,
                ),
              ),
            ),
            if (markerRow != null) Positioned(bottom: 5, child: markerRow),
          ],
        ),
      ),
    );

    if (isInRange) {
      // A soft fill behind the cell marks the days within the range.
      cell = Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: tokens.selectedDayBackgroundColor.withValues(alpha: 0.2),
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
