import 'package:flutter/material.dart';

import '../../theme/drum_picker_theme.dart';
import 'drum_column.dart';

/// Lays out a row of [DrumColumn]s under their header labels, with a single
/// continuous selection band drawn behind the wheels and centered on the
/// middle (selected) row.
///
/// Shared by the date drum and the time strip so both get the same premium
/// wheel treatment. Not part of the public package API.
class DrumWheelRow extends StatelessWidget {
  /// Creates a labeled drum-wheel row.
  const DrumWheelRow({
    super.key,
    required this.columns,
    required this.tokens,
  });

  /// The columns to show, each paired with its header label.
  final List<(String, DrumColumn)> columns;

  /// Resolved visual tokens.
  final DrumPickerResolved tokens;

  @override
  Widget build(BuildContext context) {
    final wheelHeight = tokens.itemExtent * tokens.visibleItemCount;
    final hairline = 1 / MediaQuery.devicePixelRatioOf(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: [
              for (final (label, _) in columns)
                Expanded(
                  child: Center(
                    child: Text(label, style: tokens.columnLabelTextStyle),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(
          height: wheelHeight,
          child: Stack(
            children: [
              Positioned.fill(
                child: Center(
                  child: Container(
                    height: tokens.itemExtent,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: tokens.selectorBandColor,
                      borderRadius:
                          BorderRadius.circular(tokens.selectorBandRadius),
                      border: Border.all(
                        color: tokens.selectorBandBorderColor,
                        width: hairline,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Row(
                  children: [for (final (_, column) in columns) column],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
