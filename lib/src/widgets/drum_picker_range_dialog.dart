import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../calendar/drum_calendar_system.dart';
import '../models/drum_calendar_type.dart';
import '../models/drum_range_mode.dart';
import '../theme/drum_picker_theme.dart';
import '../utils/drum_date_utils.dart';
import '../utils/drum_locale_utils.dart';
import 'internal/picker_header.dart';
import 'range/drum_range_pickers.dart';
import 'range/range_calendar.dart';

/// Shows a modal that selects a contiguous date range, a drop in style
/// replacement for Flutter's `showDateRangePicker`.
///
/// The user can pick on a calendar grid or two drum rollers, switching between
/// them with the mode toggle (set [showModeToggle] to false and [initialMode]
/// to lock one). Returns the selected [DateTimeRange], or null if cancelled.
///
/// Beyond the standard range UI it accepts this package's extras: alternative
/// [calendar]s, working day and holiday rules ([disabledWeekdays],
/// [holidays]), a custom [firstDayOfWeek], a [selectableDayPredicate], and per
/// instance [theme] overrides.
///
/// ```dart
/// final range = await showDrumDateRangePicker(
///   context: context,
///   firstDate: DateTime(2024, 1, 1),
///   lastDate: DateTime(2024, 12, 31),
/// );
/// ```
Future<DateTimeRange?> showDrumDateRangePicker({
  required BuildContext context,
  required DateTime firstDate,
  required DateTime lastDate,
  DateTimeRange? initialDateRange,
  DateTime? currentDate,
  DrumRangeMode initialMode = DrumRangeMode.calendar,
  bool showModeToggle = true,
  SelectableDayPredicate? selectableDayPredicate,
  DrumCalendarType calendar = DrumCalendarType.gregorian,
  DrumCalendarSystem? calendarSystem,
  Set<int>? disabledWeekdays,
  Set<DateTime>? holidays,
  int? firstDayOfWeek,
  String? helpText,
  String? saveText,
  String? cancelText,
  Locale? locale,
  TextDirection? textDirection,
  DrumPickerTheme? theme,
  bool barrierDismissible = true,
  Color? barrierColor,
  String? barrierLabel,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
  Offset? anchorPoint,
}) {
  assert(
      !firstDate.isAfter(lastDate), 'firstDate must be on or before lastDate');

  Widget dialog = _RangeDialog(
    firstDate: firstDate,
    lastDate: lastDate,
    initialDateRange: initialDateRange,
    currentDate: currentDate,
    initialMode: initialMode,
    showModeToggle: showModeToggle,
    selectableDayPredicate: selectableDayPredicate,
    calendar: calendar,
    calendarSystem: calendarSystem,
    disabledWeekdays: disabledWeekdays,
    holidays: holidays,
    firstDayOfWeek: firstDayOfWeek,
    helpText: helpText,
    saveText: saveText,
    cancelText: cancelText,
    locale: locale,
    theme: theme,
  );
  if (locale != null) {
    dialog =
        Localizations.override(context: context, locale: locale, child: dialog);
  }
  if (textDirection != null) {
    dialog = Directionality(textDirection: textDirection, child: dialog);
  }

  return showDialog<DateTimeRange>(
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

/// Shows a modal that selects any number of individual days.
///
/// Returns the sorted list of selected days, or null if the user cancels.
/// Accepts the same extras as [showDrumDateRangePicker].
Future<List<DateTime>?> showDrumMultiDatePicker({
  required BuildContext context,
  required DateTime firstDate,
  required DateTime lastDate,
  List<DateTime>? initialDates,
  DateTime? currentDate,
  SelectableDayPredicate? selectableDayPredicate,
  DrumCalendarType calendar = DrumCalendarType.gregorian,
  DrumCalendarSystem? calendarSystem,
  Set<int>? disabledWeekdays,
  Set<DateTime>? holidays,
  int? firstDayOfWeek,
  String? helpText,
  String? saveText,
  String? cancelText,
  Locale? locale,
  TextDirection? textDirection,
  DrumPickerTheme? theme,
  bool barrierDismissible = true,
  Color? barrierColor,
  String? barrierLabel,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
  Offset? anchorPoint,
}) {
  assert(
      !firstDate.isAfter(lastDate), 'firstDate must be on or before lastDate');

  Widget dialog = _MultiDialog(
    firstDate: firstDate,
    lastDate: lastDate,
    initialDates: initialDates,
    currentDate: currentDate,
    selectableDayPredicate: selectableDayPredicate,
    calendar: calendar,
    calendarSystem: calendarSystem,
    disabledWeekdays: disabledWeekdays,
    holidays: holidays,
    firstDayOfWeek: firstDayOfWeek,
    helpText: helpText,
    saveText: saveText,
    cancelText: cancelText,
    locale: locale,
    theme: theme,
  );
  if (locale != null) {
    dialog =
        Localizations.override(context: context, locale: locale, child: dialog);
  }
  if (textDirection != null) {
    dialog = Directionality(textDirection: textDirection, child: dialog);
  }

  return showDialog<List<DateTime>>(
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

class _RangeDialog extends StatefulWidget {
  const _RangeDialog({
    required this.firstDate,
    required this.lastDate,
    this.initialDateRange,
    this.currentDate,
    required this.initialMode,
    required this.showModeToggle,
    this.selectableDayPredicate,
    required this.calendar,
    this.calendarSystem,
    this.disabledWeekdays,
    this.holidays,
    this.firstDayOfWeek,
    this.helpText,
    this.saveText,
    this.cancelText,
    this.locale,
    this.theme,
  });

  final DateTime firstDate;
  final DateTime lastDate;
  final DateTimeRange? initialDateRange;
  final DateTime? currentDate;
  final DrumRangeMode initialMode;
  final bool showModeToggle;
  final SelectableDayPredicate? selectableDayPredicate;
  final DrumCalendarType calendar;
  final DrumCalendarSystem? calendarSystem;
  final Set<int>? disabledWeekdays;
  final Set<DateTime>? holidays;
  final int? firstDayOfWeek;
  final String? helpText;
  final String? saveText;
  final String? cancelText;
  final Locale? locale;
  final DrumPickerTheme? theme;

  @override
  State<_RangeDialog> createState() => _RangeDialogState();
}

class _RangeDialogState extends State<_RangeDialog> {
  DateTime? _start;
  DateTime? _end;

  @override
  void initState() {
    super.initState();
    _start = widget.initialDateRange?.start;
    _end = widget.initialDateRange?.end;
  }

  @override
  Widget build(BuildContext context) {
    final config = RangeConfig.of(
      context,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
      currentDate: widget.currentDate,
      calendar: widget.calendar,
      calendarSystem: widget.calendarSystem,
      disabledWeekdays: widget.disabledWeekdays,
      holidays: widget.holidays,
      selectableDayPredicate: widget.selectableDayPredicate,
      locale: widget.locale,
      theme: widget.theme,
    );
    final localeName = DrumLocaleUtils.toIntlLocale(config.locale);
    final fmt = DateFormat.MMMd(localeName);
    final arrow = String.fromCharCode(0x2192);
    final headline = _start == null
        ? 'Select a start date'
        : _end == null
            ? '${fmt.format(_start!)} $arrow ...'
            : '${fmt.format(_start!)} $arrow ${fmt.format(_end!)}';

    return Dialog(
      clipBehavior: Clip.antiAlias,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380, maxHeight: 660),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PickerHeader(
                helpText: widget.helpText ?? 'SELECT RANGE',
                headline: headline,
                tokens: config.tokens,
              ),
              RangeBody(
                config: config,
                initialDateRange: widget.initialDateRange,
                initialMode: widget.initialMode,
                showModeToggle: widget.showModeToggle,
                firstDayOfWeek: widget.firstDayOfWeek,
                onChanged: (start, end) => setState(() {
                  _start = start;
                  _end = end;
                }),
              ),
              _actions(
                context,
                cancelText: widget.cancelText,
                saveText: widget.saveText,
                onSave: _start != null && _end != null
                    ? () => Navigator.of(context).pop(
                          DateTimeRange(start: _start!, end: _end!),
                        )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MultiDialog extends StatefulWidget {
  const _MultiDialog({
    required this.firstDate,
    required this.lastDate,
    this.initialDates,
    this.currentDate,
    this.selectableDayPredicate,
    required this.calendar,
    this.calendarSystem,
    this.disabledWeekdays,
    this.holidays,
    this.firstDayOfWeek,
    this.helpText,
    this.saveText,
    this.cancelText,
    this.locale,
    this.theme,
  });

  final DateTime firstDate;
  final DateTime lastDate;
  final List<DateTime>? initialDates;
  final DateTime? currentDate;
  final SelectableDayPredicate? selectableDayPredicate;
  final DrumCalendarType calendar;
  final DrumCalendarSystem? calendarSystem;
  final Set<int>? disabledWeekdays;
  final Set<DateTime>? holidays;
  final int? firstDayOfWeek;
  final String? helpText;
  final String? saveText;
  final String? cancelText;
  final Locale? locale;
  final DrumPickerTheme? theme;

  @override
  State<_MultiDialog> createState() => _MultiDialogState();
}

class _MultiDialogState extends State<_MultiDialog> {
  final Set<DateTime> _selected = {};

  @override
  void initState() {
    super.initState();
    _selected
        .addAll((widget.initialDates ?? const []).map(DrumDateUtils.dateOnly));
  }

  @override
  Widget build(BuildContext context) {
    final config = RangeConfig.of(
      context,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
      currentDate: widget.currentDate,
      calendar: widget.calendar,
      calendarSystem: widget.calendarSystem,
      disabledWeekdays: widget.disabledWeekdays,
      holidays: widget.holidays,
      selectableDayPredicate: widget.selectableDayPredicate,
      locale: widget.locale,
      theme: widget.theme,
    );
    final headline =
        _selected.isEmpty ? 'None selected' : '${_selected.length} selected';
    final anchor = _selected.isEmpty
        ? config.current
        : _selected.reduce((a, b) => a.isBefore(b) ? a : b);

    return Dialog(
      clipBehavior: Clip.antiAlias,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380, maxHeight: 560),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PickerHeader(
                helpText: widget.helpText ?? 'SELECT DATES',
                headline: headline,
                tokens: config.tokens,
              ),
              RangeCalendar(
                firstDate: config.first,
                lastDate: config.last,
                currentDate: config.current,
                displayAnchor: anchor,
                system: config.system,
                locale: config.locale,
                tokens: config.tokens,
                multiSelect: true,
                firstDayOfWeek: widget.firstDayOfWeek,
                selectableDayPredicate: config.isSelectable,
                selectedDates: _selected,
                onDaySelected: (date) {
                  if (!config.isSelectable(date)) return;
                  setState(() {
                    if (!_selected.remove(date)) _selected.add(date);
                  });
                },
              ),
              _actions(
                context,
                cancelText: widget.cancelText,
                saveText: widget.saveText,
                onSave: () => Navigator.of(context).pop(
                  _selected.toList()..sort(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _actions(
  BuildContext context, {
  String? cancelText,
  String? saveText,
  VoidCallback? onSave,
}) {
  final localizations = MaterialLocalizations.of(context);
  return Padding(
    padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
    child: OverflowBar(
      alignment: MainAxisAlignment.end,
      spacing: 8,
      children: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(cancelText ?? localizations.cancelButtonLabel),
        ),
        TextButton(
          onPressed: onSave,
          child: Text(saveText ?? localizations.saveButtonLabel),
        ),
      ],
    ),
  );
}
