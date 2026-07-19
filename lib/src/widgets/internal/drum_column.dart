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
/// This renders only the wheel; the column header label and the shared
/// selection band are drawn by the parent so the band can span all columns
/// continuously and stay centered on the wheel row.
///
/// Exposed (non-private) so that widget tests can locate columns. It is **not**
/// part of the public package API.
class DrumColumn extends StatefulWidget {
  /// Creates a drum column.
  const DrumColumn({
    super.key,
    required this.itemCount,
    required this.selectedIndex,
    required this.itemBuilder,
    required this.onSelectedItemChanged,
    required this.tokens,
    this.subLabelBuilder,
    this.semanticLabelBuilder,
  });

  /// The number of items in this column.
  final int itemCount;

  /// The currently selected item index.
  final int selectedIndex;

  /// Builds the primary (numeral) label for the item at [index].
  final String Function(int index) itemBuilder;

  /// Optional secondary line under the numeral (for example a weekday). When
  /// non null the item renders as a tight two-line cell.
  final String? Function(int index)? subLabelBuilder;

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

  // True while the wheel is being moved programmatically (an external date
  // change), so the intermediate item crossings do not fire haptics or emit
  // spurious onChanged values.
  bool _programmatic = false;

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
        _programmatic = true;
        if (reduceMotion) {
          _controller.jumpToItem(widget.selectedIndex);
          if (mounted) _programmatic = false;
        } else {
          _controller
              .animateToItem(
            widget.selectedIndex,
            duration: widget.tokens.motionDuration,
            curve: Curves.easeOutCubic,
          )
              .whenComplete(() {
            if (mounted) _programmatic = false;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildItem(int index) {
    final tokens = widget.tokens;
    final isSelected = index == widget.selectedIndex;
    final numberStyle = isSelected
        ? tokens.selectedItemTextStyle
        : tokens.unselectedItemTextStyle;
    final sub = widget.subLabelBuilder?.call(index);
    final Widget visual;
    if (sub == null) {
      visual = Text(widget.itemBuilder(index), style: numberStyle);
    } else {
      visual = Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.itemBuilder(index),
            style: numberStyle,
            strutStyle: const StrutStyle(height: 1, forceStrutHeight: true),
          ),
          Text(
            sub,
            textAlign: TextAlign.center,
            style: tokens.daySubLabelTextStyle,
            strutStyle: const StrutStyle(height: 1.05, forceStrutHeight: true),
          ),
        ],
      );
    }
    return Semantics(
      label: widget.semanticLabelBuilder?.call(index),
      selected: isSelected,
      child: ExcludeSemantics(child: Center(child: visual)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = widget.tokens;
    return Expanded(
      child: ScrollConfiguration(
        behavior: const _DrumScrollBehavior(),
        child: ListWheelScrollView.useDelegate(
          controller: _controller,
          itemExtent: tokens.itemExtent,
          physics: const FixedExtentScrollPhysics(),
          useMagnifier: tokens.useMagnifier,
          magnification: tokens.magnification,
          overAndUnderCenterOpacity: tokens.overAndUnderCenterOpacity,
          diameterRatio: 2.0,
          perspective: 0.0025,
          squeeze: 1.05,
          onSelectedItemChanged: (index) {
            if (_programmatic) return;
            HapticFeedback.selectionClick();
            widget.onSelectedItemChanged(index);
          },
          // ListDelegate (not looping) — the item count changes when the
          // month/year changes, so looping math would break.
          childDelegate: ListWheelChildBuilderDelegate(
            childCount: widget.itemCount,
            builder: (context, index) {
              if (index < 0 || index >= widget.itemCount) return null;
              return _buildItem(index);
            },
          ),
        ),
      ),
    );
  }
}
