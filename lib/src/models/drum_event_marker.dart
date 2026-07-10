import 'package:flutter/widgets.dart';

/// The default maximum number of marker dots rendered under a day.
const int kDefaultMaxEventMarkers = 4;

/// A single event marker shown under a day in the calendar grid.
///
/// Return a list of these from a [DrumEventLoader] to render dots (or your own
/// widget through a [DrumMarkerBuilder]) beneath the days that have events, the
/// way an event calendar highlights busy days. Each marker may carry its own
/// [color] (falling back to the theme's `eventMarkerColor`) and an optional
/// [semanticLabel] for accessibility.
@immutable
class DrumEventMarker {
  /// Creates an event marker.
  const DrumEventMarker({this.color, this.semanticLabel});

  /// The dot color. Falls back to the resolved `eventMarkerColor` token when
  /// null, or to the selected day's foreground color on the selected day.
  final Color? color;

  /// An optional label describing the event, announced by screen readers.
  final String? semanticLabel;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DrumEventMarker &&
          color == other.color &&
          semanticLabel == other.semanticLabel;

  @override
  int get hashCode => Object.hash(color, semanticLabel);
}

/// Returns the event markers for [day] (a canonical Gregorian date at midnight).
///
/// Called once per rendered day in the calendar grid. Return an empty list for
/// days with no events. Keep it cheap, or memoize your lookups, since it runs
/// for every visible cell.
///
/// ```dart
/// eventLoader: (day) =>
///     myEventsByDay[DateUtils.dateOnly(day)]
///         ?.map((e) => DrumEventMarker(color: e.color))
///         .toList() ??
///     const [],
/// ```
typedef DrumEventLoader = List<DrumEventMarker> Function(DateTime day);

/// Builds a custom marker overlay for [day], given its [markers].
///
/// Return null to fall back to the default row of dots. The returned widget is
/// laid over the full day cell, so align it yourself (for example with
/// [Align]). Only called for days whose [markers] list is non-empty.
typedef DrumMarkerBuilder = Widget? Function(
  BuildContext context,
  DateTime day,
  List<DrumEventMarker> markers,
);
