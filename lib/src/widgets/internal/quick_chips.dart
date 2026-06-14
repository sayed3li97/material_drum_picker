import 'package:flutter/material.dart';

import '../../models/drum_quick_select.dart';

/// A horizontal wrap of quick-select chips shown in calendar mode.
///
/// Exposed (non-private) for widget tests. Not part of the public package API.
class QuickChips extends StatelessWidget {
  /// Creates a row of quick-select chips.
  const QuickChips({
    super.key,
    required this.options,
    required this.isEnabled,
    required this.onSelected,
  });

  /// The chips to display.
  final List<DrumQuickSelect> options;

  /// Returns whether [option] is currently selectable (in range + predicate).
  final bool Function(DrumQuickSelect option) isEnabled;

  /// Called when an enabled chip is tapped.
  final ValueChanged<DrumQuickSelect> onSelected;

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: [
          for (final option in options) _buildChip(context, option),
        ],
      ),
    );
  }

  Widget _buildChip(BuildContext context, DrumQuickSelect option) {
    final enabled = isEnabled(option);
    return ActionChip(
      label: Text(option.label),
      // A null onPressed renders the chip in the disabled (greyed) state and
      // makes it non-tappable.
      onPressed: enabled ? () => onSelected(option) : null,
    );
  }
}
