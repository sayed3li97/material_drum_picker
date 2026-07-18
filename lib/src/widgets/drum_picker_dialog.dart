import 'package:flutter/material.dart';

import '../calendar/drum_calendar_system.dart';
import '../models/drum_calendar_type.dart';
import '../models/drum_column_order.dart';
import '../models/drum_date_format.dart';
import '../models/drum_event_marker.dart';
import '../models/drum_month_format.dart';
import '../models/drum_picker_labels.dart';
import '../models/drum_picker_mode.dart';
import '../models/drum_precision.dart';
import '../models/drum_quick_select.dart';
import '../theme/drum_picker_theme.dart';
import 'drum_picker.dart';

/// Shows a [DrumPicker] in a Material Design 3 dialog.
///
/// This function mirrors Flutter's `showDatePicker` so that developers familiar
/// with the built-in picker can adopt it with zero learning curve. Every shared
/// parameter keeps the same name.
///
/// Returns the selected [DateTime], or `null` if the user cancels or dismisses
/// the dialog by tapping the barrier.
///
/// ```dart
/// final picked = await showDrumDatePicker(
///   context: context,
///   firstDate: DateTime(1900),
///   lastDate: DateTime(2100),
/// );
/// ```
Future<DateTime?> showDrumDatePicker({
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
  DatePickerEntryMode? initialEntryMode,
  DrumPrecision precision = DrumPrecision.day,
  bool showModeToggle = true,
  DrumColumnOrder? columnOrder,
  bool showDayOfWeekInDrum = false,
  DrumMonthFormat monthFormat = DrumMonthFormat.name,
  DrumDateFormat inputFormat = DrumDateFormat.mdy,
  bool showQuickSelects = true,
  List<DrumQuickSelect>? quickSelectOptions,
  DrumEventLoader? eventLoader,
  DrumMarkerBuilder? markerBuilder,
  int maxEventMarkers = kDefaultMaxEventMarkers,
  DrumCalendarType calendar = DrumCalendarType.gregorian,
  DrumCalendarSystem? calendarSystem,
  bool showGregorianAlongside = false,
  bool pickTime = false,
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
  assert(
      !firstDate.isAfter(lastDate), 'firstDate must be on or before lastDate');

  // Map Flutter's DatePickerEntryMode onto the picker's mode and toggle, so a
  // call migrated from showDatePicker keeps working unchanged.
  var effectiveMode = initialMode;
  var effectiveShowToggle = showModeToggle;
  switch (initialEntryMode) {
    case null:
      break;
    case DatePickerEntryMode.calendar:
      effectiveMode = DrumPickerMode.calendar;
    case DatePickerEntryMode.input:
      effectiveMode = DrumPickerMode.input;
    case DatePickerEntryMode.calendarOnly:
      effectiveMode = DrumPickerMode.calendar;
      effectiveShowToggle = false;
    case DatePickerEntryMode.inputOnly:
      effectiveMode = DrumPickerMode.input;
      effectiveShowToggle = false;
  }

  Widget dialog = _DrumPickerDialog(
    initialDate: initialDate,
    firstDate: firstDate,
    lastDate: lastDate,
    currentDate: currentDate,
    selectableDayPredicate: selectableDayPredicate,
    disabledWeekdays: disabledWeekdays,
    holidays: holidays,
    firstDayOfWeek: firstDayOfWeek,
    initialMode: effectiveMode,
    precision: precision,
    showModeToggle: effectiveShowToggle,
    columnOrder: columnOrder,
    showDayOfWeekInDrum: showDayOfWeekInDrum,
    monthFormat: monthFormat,
    inputFormat: inputFormat,
    showQuickSelects: showQuickSelects,
    quickSelectOptions: quickSelectOptions,
    eventLoader: eventLoader,
    markerBuilder: markerBuilder,
    maxEventMarkers: maxEventMarkers,
    calendar: calendar,
    calendarSystem: calendarSystem,
    showGregorianAlongside: showGregorianAlongside,
    pickTime: pickTime,
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
  );

  if (locale != null) {
    dialog = Localizations.override(
      context: context,
      locale: locale,
      child: dialog,
    );
  }
  if (textDirection != null) {
    dialog = Directionality(textDirection: textDirection, child: dialog);
  }
  if (builder != null) {
    final wrapped = dialog;
    dialog = Builder(builder: (context) => builder(context, wrapped));
  }

  return showDialog<DateTime>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor,
    barrierLabel: barrierLabel,
    useRootNavigator: useRootNavigator,
    routeSettings: routeSettings,
    anchorPoint: anchorPoint,
    builder: (context) => dialog,
  );
}

/// Internal dialog wrapper that wires the picker's confirm/cancel callbacks to
/// [Navigator.pop].
class _DrumPickerDialog extends StatelessWidget {
  const _DrumPickerDialog({
    required this.firstDate,
    required this.lastDate,
    this.initialDate,
    this.currentDate,
    this.selectableDayPredicate,
    this.disabledWeekdays,
    this.holidays,
    this.firstDayOfWeek,
    required this.initialMode,
    required this.precision,
    required this.showModeToggle,
    this.columnOrder,
    required this.showDayOfWeekInDrum,
    required this.monthFormat,
    required this.inputFormat,
    required this.showQuickSelects,
    this.quickSelectOptions,
    this.eventLoader,
    this.markerBuilder,
    required this.maxEventMarkers,
    required this.calendar,
    this.calendarSystem,
    required this.showGregorianAlongside,
    required this.pickTime,
    this.use24hFormat,
    required this.minuteInterval,
    this.helpText,
    this.confirmText,
    this.cancelText,
    this.errorFormatText,
    this.errorInvalidText,
    this.fieldHintText,
    this.fieldLabelText,
    this.locale,
    this.textDirection,
    this.theme,
    required this.labels,
    this.inputDecoration,
  });

  final DateTime? initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime? currentDate;
  final SelectableDayPredicate? selectableDayPredicate;
  final Set<int>? disabledWeekdays;
  final Set<DateTime>? holidays;
  final int? firstDayOfWeek;
  final DrumPickerMode initialMode;
  final DrumPrecision precision;
  final bool showModeToggle;
  final DrumColumnOrder? columnOrder;
  final bool showDayOfWeekInDrum;
  final DrumMonthFormat monthFormat;
  final DrumDateFormat inputFormat;
  final bool showQuickSelects;
  final List<DrumQuickSelect>? quickSelectOptions;
  final DrumEventLoader? eventLoader;
  final DrumMarkerBuilder? markerBuilder;
  final int maxEventMarkers;
  final DrumCalendarType calendar;
  final DrumCalendarSystem? calendarSystem;
  final bool showGregorianAlongside;
  final bool pickTime;
  final bool? use24hFormat;
  final int minuteInterval;
  final String? helpText;
  final String? confirmText;
  final String? cancelText;
  final String? errorFormatText;
  final String? errorInvalidText;
  final String? fieldHintText;
  final String? fieldLabelText;
  final Locale? locale;
  final TextDirection? textDirection;
  final DrumPickerTheme? theme;
  final DrumPickerLabels labels;
  final InputDecoration? inputDecoration;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      clipBehavior: Clip.antiAlias,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360, maxHeight: 560),
        child: SingleChildScrollView(
          child: DrumPicker(
            initialDate: initialDate,
            firstDate: firstDate,
            lastDate: lastDate,
            currentDate: currentDate,
            selectableDayPredicate: selectableDayPredicate,
            disabledWeekdays: disabledWeekdays,
            holidays: holidays,
            firstDayOfWeek: firstDayOfWeek,
            initialMode: initialMode,
            precision: precision,
            showModeToggle: showModeToggle,
            columnOrder: columnOrder,
            showDayOfWeekInDrum: showDayOfWeekInDrum,
            monthFormat: monthFormat,
            inputFormat: inputFormat,
            showQuickSelects: showQuickSelects,
            quickSelectOptions: quickSelectOptions,
            eventLoader: eventLoader,
            markerBuilder: markerBuilder,
            maxEventMarkers: maxEventMarkers,
            calendar: calendar,
            calendarSystem: calendarSystem,
            showGregorianAlongside: showGregorianAlongside,
            pickTime: pickTime,
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
            onConfirmed: (date) => Navigator.of(context).pop(date),
            onCancelled: () => Navigator.of(context).pop(),
          ),
        ),
      ),
    );
  }
}
