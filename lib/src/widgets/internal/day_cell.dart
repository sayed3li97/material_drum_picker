import 'package:flutter/material.dart';

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
  });

  /// The day-of-month number shown in the cell.
  final int day;

  /// Whether the cell may be tapped. Disabled cells are greyed out.
  final bool isEnabled;

  /// Whether this cell is the current selection.
  final bool isSelected;

  /// Whether this cell represents "today".
  final bool isToday;

  /// Called when an enabled cell is tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    Color background = Colors.transparent;
    Color foreground = scheme.onSurface;
    if (isSelected) {
      background = scheme.primary;
      foreground = scheme.onPrimary;
    } else if (!isEnabled) {
      foreground = scheme.onSurface.withValues(alpha: 0.38);
    } else if (isToday) {
      foreground = scheme.primary;
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
          child: Material(
            color: background,
            shape: CircleBorder(
              side: isToday && !isSelected
                  ? BorderSide(color: scheme.primary)
                  : BorderSide.none,
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: isEnabled ? onTap : null,
              child: Center(
                child: Text(
                  '$day',
                  style: TextStyle(
                    color: foreground,
                    fontWeight: isSelected || isToday ? FontWeight.w600 : null,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
