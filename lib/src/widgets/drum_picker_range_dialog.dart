import 'package:flutter/material.dart';

import '../models/drum_quick_select.dart';

/// Shows a `DrumPicker` in range-selection mode.
///
/// **Planned for v1.1.** This stub throws an [UnimplementedError] in v1.0 so
/// that the public API surface is defined and documented now. Use
/// `showDrumDatePicker` twice (for start and end dates) in the meantime.
///
/// Returns a [DateTimeRange] with start and end dates, or `null` on cancel.
Future<DateTimeRange?> showDrumDateRangePicker({
  required BuildContext context,
  required DateTime firstDate,
  required DateTime lastDate,
  DateTimeRange? initialDateRange,
  DateTime? currentDate,
  SelectableDayPredicate? selectableDayPredicate,
  int? maxDateRangeSpan,
  String? helpText,
  String? confirmText,
  String? cancelText,
  String? saveText,
  String? errorFormatText,
  String? errorInvalidText,
  String? errorInvalidRangeText,
  String? fieldStartHintText,
  String? fieldEndHintText,
  String? fieldStartLabelText,
  String? fieldEndLabelText,
  bool showQuickSelects = true,
  List<DrumQuickSelect>? quickSelectOptions,
  Locale? locale,
  TextDirection? textDirection,
  bool barrierDismissible = true,
  Color? barrierColor,
  String? barrierLabel,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
  String? restorationId,
  Offset? anchorPoint,
  TransitionBuilder? builder,
}) async {
  throw UnimplementedError(
    'showDrumDateRangePicker is planned for v1.1. '
    'Use showDrumDatePicker twice for start and end dates in v1.0.',
  );
}
