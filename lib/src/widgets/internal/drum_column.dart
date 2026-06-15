import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/drum_picker_theme.dart';

/// A scroll behavior that allows dragging the drum with a mouse and trackpad,
/// in addition to touch — required for web and desktop.
class _DrumScrollBehavior extends MaterialScrollBehavior {
  const _DrumScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => <PointerDeviceKind>{
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
        PointerDeviceKind.invertedStylus,
      };
}

/// A single scrollable drum-wheel column (day, month or year).
///
/// Exposed (non-private) so that widget tests can locate columns and read their
/// [label]. It is **not** part of the public package API.
class DrumColumn extends StatefulWidget {
  /// Creates a drum column.
  const DrumColumn({
    super.key,
    required this.label,
    required this.itemCount,
    required this.selectedIndex,
    required this.itemBuilder,
    required this.onSelectedItemChanged,
    required this.tokens,
    this.semanticLabelBuilder,
  });

  /// The uppercase column header (e.g. `DAY`, `MONTH`, `YEAR`).
  final String label;

  /// The number of items in this column.
  final int itemCount;

  /// The currently selected item index.
  final int selectedIndex;

  /// Builds the (text) label for the item at [index].
  final String Function(int index) itemBuilder;

  /// Called when the centered item changes after a scroll settles.
  final ValueChanged<int> onSelectedItemChanged;

  /// Resolved visual tokens.
  final DrumPickerResolved tokens;

  /// Optional builder for a per-item screen-reader label.
  final String Function(int index)? semanticLabelBuilder;

  @override
  State<DrumColumn> createState() => _DrumColumnState();
}

class _DrumColumnState extends State<DrumColumn> {
  late FixedExtentScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        FixedExtentScrollController(initialItem: widget.selectedIndex);
  }

  @override
  void didUpdateWidget(DrumColumn oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != oldWidget.selectedIndex &&
        widget.selectedIndex != _controller.selectedItem) {
      // Sync the wheel to an externally-driven change (e.g. a nearest-valid
      // date jump). Defer until after layout so the controller is attached.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_controller.hasClients) return;
        final reduceMotion =
            MediaQuery.maybeOf(context)?.disableAnimations ?? false;
        if (reduceMotion) {
          _controller.jumpToItem(widget.selectedIndex);
        } else {
          _controller.animateToItem(
            widget.selectedIndex,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = widget.tokens;
    final selectedStyle = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: tokens.selectedItemColor,
    );
    final unselectedStyle = TextStyle(
      fontSize: 18,
      color: tokens.unselectedItemColor,
    );

    return Expanded(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              widget.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
                color: tokens.unselectedItemColor,
              ),
            ),
          ),
          SizedBox(
            height: tokens.itemExtent * tokens.visibleItemCount,
            child: Stack(
              children: [
                // Center highlight band.
                Positioned.fill(
                  child: Center(
                    child: Container(
                      height: tokens.itemExtent,
                      decoration: BoxDecoration(
                        color: tokens.selectorBandColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                ScrollConfiguration(
                  behavior: const _DrumScrollBehavior(),
                  child: ListWheelScrollView.useDelegate(
                    controller: _controller,
                    itemExtent: tokens.itemExtent,
                    physics: const FixedExtentScrollPhysics(),
                    perspective: 0.003,
                    diameterRatio: 1.6,
                    onSelectedItemChanged: (index) {
                      HapticFeedback.selectionClick();
                      widget.onSelectedItemChanged(index);
                    },
                    // ListDelegate (not looping) — the item count changes when
                    // the month/year changes, so looping math would break.
                    childDelegate: ListWheelChildBuilderDelegate(
                      childCount: widget.itemCount,
                      builder: (context, index) {
                        if (index < 0 || index >= widget.itemCount) return null;
                        final isSelected = index == widget.selectedIndex;
                        return Semantics(
                          label: widget.semanticLabelBuilder?.call(index),
                          selected: isSelected,
                          child: Center(
                            child: Text(
                              widget.itemBuilder(index),
                              style:
                                  isSelected ? selectedStyle : unselectedStyle,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
