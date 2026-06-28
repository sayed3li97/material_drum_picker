import 'package:flutter/material.dart';

import '../calendar/drum_calendar_system.dart';
import '../models/drum_calendar_type.dart';
import '../models/drum_column_order.dart';
import '../models/drum_date_format.dart';
import '../models/drum_month_format.dart';
import '../models/drum_picker_labels.dart';
import '../models/drum_picker_mode.dart';
import '../models/drum_quick_select.dart';
import '../theme/drum_picker_theme.dart';
import 'drum_picker_dialog.dart';

/// Shows a [DrumPicker] that selects both a date **and** a time of day.
///
/// This is a thin convenience wrapper around `showDrumDatePicker` with
/// `pickTime: true`. The returned [DateTime] carries the chosen hour and
/// minute; `null` is returned if the user cancels or dismisses the dialog.
///
/// ```dart
/// final when = await showDrumDateTimePicker(
///   context: context,
///   firstDate: DateTime(2020),
///   lastDate: DateTime(2030),
///   minuteInterval: 15,
/// );
/// ```
Future<DateTime?> showDrumDateTimePicker({
  required BuildContext context,
  required DateTime firstDate,
  required DateTime lastDate,
  DateTime? initialDate,
  DateTime? currentDate,
  SelectableDayPredicate? selectableDayPredicate,
  Set<int>? disabledWeekdays,
  Set<DateTime>? holidays,
  int? firstDayOfWeek,
  DrumPickerMode initialMode = DrumPickerMode.drum,
  bool showModeToggle = true,
  DrumColumnOrder? columnOrder,
  bool showDayOfWeekInDrum = false,
  DrumMonthFormat monthFormat = DrumMonthFormat.name,
  DrumDateFormat inputFormat = DrumDateFormat.mdy,
  bool showQuickSelects = true,
  List<DrumQuickSelect>? quickSelectOptions,
  DrumCalendarType calendar = DrumCalendarType.gregorian,
  DrumCalendarSystem? calendarSystem,
  bool showGregorianAlongside = false,
  bool? use24hFormat,
  int minuteInterval = 1,
  String? helpText,
  String? confirmText,
  String? cancelText,
  String? errorFormatText,
  String? errorInvalidText,
  String? fieldHintText,
  String? fieldLabelText,
  Locale? locale,
  TextDirection? textDirection,
  DrumPickerTheme? theme,
  DrumPickerLabels labels = const DrumPickerLabels(),
  InputDecoration? inputDecoration,
  bool barrierDismissible = true,
  Color? barrierColor,
  String? barrierLabel,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
  String? restorationId,
  Offset? anchorPoint,
  TransitionBuilder? builder,
}) {
  return showDrumDatePicker(
    context: context,
    firstDate: firstDate,
    lastDate: lastDate,
    initialDate: initialDate,
    currentDate: currentDate,
    selectableDayPredicate: selectableDayPredicate,
    disabledWeekdays: disabledWeekdays,
    holidays: holidays,
    firstDayOfWeek: firstDayOfWeek,
    initialMode: initialMode,
    showModeToggle: showModeToggle,
    columnOrder: columnOrder,
    showDayOfWeekInDrum: showDayOfWeekInDrum,
    monthFormat: monthFormat,
    inputFormat: inputFormat,
    showQuickSelects: showQuickSelects,
    quickSelectOptions: quickSelectOptions,
    calendar: calendar,
    calendarSystem: calendarSystem,
    showGregorianAlongside: showGregorianAlongside,
    pickTime: true,
    use24hFormat: use24hFormat,
    minuteInterval: minuteInterval,
    helpText: helpText,
    confirmText: confirmText,
    cancelText: cancelText,
    errorFormatText: errorFormatText,
    errorInvalidText: errorInvalidText,
    fieldHintText: fieldHintText,
    fieldLabelText: fieldLabelText,
    locale: locale,
    textDirection: textDirection,
    theme: theme,
    labels: labels,
    inputDecoration: inputDecoration,
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor,
    barrierLabel: barrierLabel,
    useRootNavigator: useRootNavigator,
    routeSettings: routeSettings,
    restorationId: restorationId,
    anchorPoint: anchorPoint,
    builder: builder,
  );
}
