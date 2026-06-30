import 'package:flutter/material.dart';

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

  /// Whether this day falls inside a selected range (drawn with a soft fill
  /// behind the cell). The range endpoints also set [isSelected].
  final bool isInRange;

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

    final shape = isToday && !isSelected
        ? tokens.dayShape.copyWith(side: BorderSide(color: tokens.todayColor))
        : tokens.dayShape;

    if (isInRange && !isSelected && isEnabled) {
      // An in-range day that is not an endpoint keeps the normal foreground.
      foreground = tokens.dayForegroundColor;
    }

    Widget cell = Material(
      color: background,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        child: Center(
          child: Text(
            label ?? '$day',
            style: TextStyle(
              color: foreground,
              fontWeight: isSelected || isToday ? FontWeight.w600 : null,
            ),
          ),
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
      enabled: isEnabled,
      selected: isSelected,
      label: '$day',
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
