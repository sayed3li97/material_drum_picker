import 'package:flutter/material.dart';

import '../../theme/drum_picker_theme.dart';

/// The header at the top of the picker, showing the help text and the
/// currently-selected date in a large headline.
///
/// The [headline] (and optional [secondaryText]) are precomputed by the parent
/// so that the active calendar system and locale numerals are applied in one
/// place. Exposed (non-private) for widget tests. Not part of the public API.
class PickerHeader extends StatelessWidget {
  /// Creates a picker header.
  const PickerHeader({
    super.key,
    required this.helpText,
    required this.headline,
    required this.tokens,
    this.timeText,
    this.secondaryText,
  });

  /// The uppercase label shown above the headline date.
  final String helpText;

  /// The formatted, calendar and locale aware selected date.
  final String headline;

  /// Resolved visual tokens.
  final DrumPickerResolved tokens;

  /// The formatted time shown beside the date, or null to hide it.
  final String? timeText;

  /// An optional secondary line (for example the Gregorian equivalent) shown
  /// smaller under the headline, or null to hide it.
  final String? secondaryText;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: tokens.headerBackgroundColor,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            helpText,
            style: TextStyle(
              color: tokens.headerTextColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            timeText == null ? headline : '$headline  ·  $timeText',
            style: TextStyle(
              color: tokens.headerTextColor,
              fontSize: 30,
              fontWeight: FontWeight.w400,
            ),
          ),
          if (secondaryText != null) ...[
            const SizedBox(height: 2),
            Text(
              secondaryText!,
              style: TextStyle(
                color: tokens.headerTextColor.withValues(alpha: 0.7),
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
