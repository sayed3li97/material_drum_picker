import 'package:flutter/material.dart';

import '../../models/drum_picker_mode.dart';

/// The segmented control that switches between Calendar, Drum and Input modes.
///
/// Exposed (non-private) for widget tests. Not part of the public package API.
class ModeTabBar extends StatelessWidget {
  /// Creates a mode tab bar.
  const ModeTabBar({
    super.key,
    required this.mode,
    required this.onModeChanged,
  });

  /// The currently selected mode.
  final DrumPickerMode mode;

  /// Called when the user selects a different mode.
  final ValueChanged<DrumPickerMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SegmentedButton<DrumPickerMode>(
        showSelectedIcon: false,
        segments: const [
          ButtonSegment<DrumPickerMode>(
            value: DrumPickerMode.calendar,
            icon: Icon(Icons.calendar_today_outlined, size: 18),
            label: Text('Calendar'),
          ),
          ButtonSegment<DrumPickerMode>(
            value: DrumPickerMode.drum,
            icon: Icon(Icons.view_day_outlined, size: 18),
            label: Text('Drum'),
          ),
          ButtonSegment<DrumPickerMode>(
            value: DrumPickerMode.input,
            icon: Icon(Icons.keyboard_outlined, size: 18),
            label: Text('Input'),
          ),
        ],
        selected: <DrumPickerMode>{mode},
        onSelectionChanged: (selection) => onModeChanged(selection.first),
      ),
    );
  }
}
