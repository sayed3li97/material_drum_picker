import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../theme/drum_picker_theme.dart';

/// The header at the top of the picker, showing the help text and the
/// currently-selected date in a large headline.
///
/// Exposed (non-private) for widget tests. Not part of the public package API.
class PickerHeader extends StatelessWidget {
  /// Creates a picker header.
  const PickerHeader({
    super.key,
    required this.helpText,
    required this.selectedDate,
    required this.tokens,
    required this.localeName,
  });

  /// The uppercase label shown above the headline date.
  final String helpText;

  /// The currently-selected date.
  final DateTime selectedDate;

  /// Resolved visual tokens.
  final DrumPickerResolved tokens;

  /// The `intl` locale used to format the headline date.
  final String? localeName;

  @override
  Widget build(BuildContext context) {
    final headline = DateFormat.MMMEd(localeName).format(selectedDate);

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
            headline,
            style: TextStyle(
              color: tokens.headerTextColor,
              fontSize: 30,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
