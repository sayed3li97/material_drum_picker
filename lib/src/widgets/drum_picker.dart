import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../calendar/drum_calendar_system.dart';
import '../calendar/gregorian_calendar_system.dart';
import '../calendar/hijri/hijri_calendar_system.dart';
import '../models/drum_calendar_type.dart';
import '../models/drum_column_order.dart';
import '../models/drum_picker_labels.dart';
import '../models/drum_picker_mode.dart';
import '../models/drum_quick_select.dart';
import '../theme/drum_picker_theme.dart';
import '../utils/drum_date_utils.dart';
import '../utils/drum_locale_utils.dart';
import '../utils/drum_numerals.dart';
import 'internal/mode_tab_bar.dart';
import 'internal/picker_header.dart';
import 'internal/quick_chips.dart';
import 'internal/time_strip.dart';
import 'modes/calendar_mode_widget.dart';
import 'modes/drum_mode_widget.dart';
import 'modes/input_mode_widget.dart';

/// Signature for a function that returns true if [day] may be selected.
///
/// Identical to Flutter's own `SelectableDayPredicate`; aliased here for
/// documentation clarity.
typedef DrumSelectableDayPredicate = bool Function(DateTime day);

/// A Material Design 3 date picker with an iOS-style drum roller and three
/// context-aware input modes (drum, calendar, input).
///
/// Use this widget directly to embed the picker inline in a form (set
/// [showActions] to `false`), or use `showDrumDatePicker` to present it in a
/// modal dialog.
class DrumPicker extends StatefulWidget {
  /// Creates a drum date picker.
  DrumPicker({
    super.key,
    this.initialDate,
    required this.firstDate,
    required this.lastDate,
    this.currentDate,
    this.selectableDayPredicate,
    this.initialMode = DrumPickerMode.drum,
    this.showModeToggle = true,
    this.columnOrder,
    this.showDayOfWeekInDrum = false,
    this.showQuickSelects = true,
    this.quickSelectOptions,
    this.calendar = DrumCalendarType.gregorian,
    this.calendarSystem,
    this.showGregorianAlongside = false,
    this.pickTime = false,
    this.use24hFormat,
    this.minuteInterval = 1,
    this.helpText,
    this.confirmText,
    this.cancelText,
    this.errorFormatText,
    this.errorInvalidText,
    this.fieldHintText,
    this.fieldLabelText,
    this.showActions = true,
    this.locale,
    this.textDirection,
    this.theme,
    this.labels = const DrumPickerLabels(),
    this.inputDecoration,
    this.onChanged,
    this.onConfirmed,
    this.onCancelled,
    this.onModeChanged,
  })  : assert(!firstDate.isAfter(lastDate),
            'firstDate must be on or before lastDate'),
        assert(
            60 % minuteInterval == 0, 'minuteInterval must be a divisor of 60');

  /// The date initially selected when the picker opens.
  ///
  /// Defaults to [currentDate] (or today) clamped into range if null.
  final DateTime? initialDate;

  /// The earliest date the user may select.
  final DateTime firstDate;

  /// The latest date the user may select.
  final DateTime lastDate;

  /// The date representing "today", highlighted in the calendar grid.
  ///
  /// Defaults to `DateTime.now()`. Pass a fixed value in tests.
  final DateTime? currentDate;

  /// A function that returns true if the given date may be selected.
  final SelectableDayPredicate? selectableDayPredicate;

  /// The input mode shown when the picker first opens.
  final DrumPickerMode initialMode;

  /// Whether to show the mode toggle tabs.
  final bool showModeToggle;

  /// The order of the day/month/year columns in drum mode.
  ///
  /// Falls back to a locale-based default if null.
  final DrumColumnOrder? columnOrder;

  /// Whether to show the day-of-week abbreviation below each day in the drum
  /// day column.
  final bool showDayOfWeekInDrum;

  /// Whether to show quick-select chips in calendar mode.
  final bool showQuickSelects;

  /// Custom quick-select options. Replaces the defaults if provided.
  final List<DrumQuickSelect>? quickSelectOptions;

  /// The built in calendar system to present dates in. Defaults to
  /// [DrumCalendarType.gregorian]. Ignored when [calendarSystem] is non null.
  ///
  /// The returned value is always a Gregorian `DateTime`.
  final DrumCalendarType calendar;

  /// A custom calendar system. When non null it takes precedence over
  /// [calendar], letting you inject any system, including a
  /// `TabularLunarCalendarSystem` built from a committee dataset.
  final DrumCalendarSystem? calendarSystem;

  /// Whether to show the Gregorian equivalent as a small secondary line under
  /// the headline. Off by default. Only meaningful for a non Gregorian
  /// calendar.
  final bool showGregorianAlongside;

  /// Whether to also let the user pick a time of day.
  ///
  /// When true, a compact time drum strip (hour, minute, and AM/PM in
  /// 12-hour mode) is shown below the date selector and the confirmed value
  /// includes the selected time.
  final bool pickTime;

  /// Whether the time strip uses 24-hour format.
  ///
  /// When null, falls back to `MediaQuery.alwaysUse24HourFormat`. Only relevant
  /// when [pickTime] is true.
  final bool? use24hFormat;

  /// The granularity, in minutes, of the time strip's minute column.
  ///
  /// Must be a divisor of 60 (e.g. 1, 5, 15). Only relevant when [pickTime]
  /// is true.
  final int minuteInterval;

  /// The label displayed at the top of the picker header.
  final String? helpText;

  /// The label of the confirm/OK button.
  final String? confirmText;

  /// The label of the cancel button.
  final String? cancelText;

  /// Error message shown in input mode when the typed format is invalid.
  final String? errorFormatText;

  /// Error message shown in input mode when the date is out of range or not
  /// selectable.
  final String? errorInvalidText;

  /// Hint text for the input field.
  final String? fieldHintText;

  /// Label text for the input field.
  final String? fieldLabelText;

  /// Whether to show Cancel/OK action buttons below the picker.
  final bool showActions;

  /// Locale override for date formatting.
  final Locale? locale;

  /// Text direction override.
  final TextDirection? textDirection;

  /// Per instance visual token overrides, merged over any ambient
  /// [DrumPickerTheme] extension and the Material 3 defaults. Style a single
  /// picker without touching the app theme.
  final DrumPickerTheme? theme;

  /// Overridable UI strings (drum column headers, time strip headers, mode tab
  /// labels, and the default quick select chips). Defaults to English.
  final DrumPickerLabels labels;

  /// Optional base [InputDecoration] for the input mode text field. When null,
  /// a default outlined decoration is used. The picker always overlays the
  /// label, hint, error, helper, and suffix icon on top of it.
  final InputDecoration? inputDecoration;

  /// Called every time the user changes the selected date (before confirming).
  final ValueChanged<DateTime>? onChanged;

  /// Called when the user taps OK.
  final ValueChanged<DateTime>? onConfirmed;

  /// Called when the user taps Cancel.
  final VoidCallback? onCancelled;

  /// Called when the user switches between input modes.
  final ValueChanged<DrumPickerMode>? onModeChanged;

  @override
  State<DrumPicker> createState() => _DrumPickerState();
}

class _DrumPickerState extends State<DrumPicker> {
  late DateTime _selectedDate;
  late DrumPickerMode _mode;
  late final DrumCalendarSystem _system;
  late final DateTime _first;
  late final DateTime _last;

  DateTime get _currentDate =>
      DrumDateUtils.dateOnly(widget.currentDate ?? DateTime.now());

  @override
  void initState() {
    super.initState();
    // The local date-symbol data populates synchronously, so all locales are
    // available immediately for DateFormat (prevents crashes for non-en apps).
    initializeDateFormatting();
    _mode = widget.initialMode;

    // Resolve the active calendar system. An explicit system wins over the
    // enum.
    _system = widget.calendarSystem ??
        (widget.calendar == DrumCalendarType.hijri
            ? const HijriCalendarSystem()
            : const GregorianCalendarSystem());

    // Intersect the caller's range with the system's supported range so that
    // conversions never run past the calendar's bounds.
    final lo = DrumDateUtils.dateOnly(widget.firstDate);
    final hi = DrumDateUtils.dateOnly(widget.lastDate);
    final sysLo = DrumDateUtils.dateOnly(_system.minSupported);
    final sysHi = DrumDateUtils.dateOnly(_system.maxSupported);
    _first = lo.isBefore(sysLo) ? sysLo : lo;
    _last = hi.isAfter(sysHi) ? sysHi : hi;

    final initial = widget.initialDate ?? widget.currentDate ?? DateTime.now();
    final clampedDate = DrumDateUtils.clamp(initial, _first, _last);
    if (widget.pickTime) {
      _selectedDate = DrumDateUtils.combine(
        clampedDate,
        initial.hour,
        DrumDateUtils.snapMinute(initial.minute, widget.minuteInterval),
      );
    } else {
      _selectedDate = clampedDate;
    }
  }

  Locale? _effectiveLocale(BuildContext context) =>
      widget.locale ?? Localizations.maybeLocaleOf(context);

  DrumColumnOrder _resolveColumnOrder(BuildContext context) {
    if (widget.columnOrder != null) return widget.columnOrder!;
    return DrumLocaleUtils.columnOrderForLocale(_effectiveLocale(context));
  }

  void _onDateChanged(DateTime date) {
    final merged = widget.pickTime
        ? DrumDateUtils.combine(date, _selectedDate.hour, _selectedDate.minute)
        : DrumDateUtils.dateOnly(date);
    if (merged == _selectedDate) return;
    setState(() => _selectedDate = merged);
    widget.onChanged?.call(merged);
  }

  void _onTimeChanged(TimeOfDay time) {
    final merged = DrumDateUtils.combine(_selectedDate, time.hour, time.minute);
    if (merged == _selectedDate) return;
    setState(() => _selectedDate = merged);
    widget.onChanged?.call(merged);
  }

  void _onModeChanged(DrumPickerMode mode) {
    if (mode == _mode) return;
    setState(() => _mode = mode);
    widget.onModeChanged?.call(mode);
    SemanticsService.sendAnnouncement(
      View.of(context),
      'Switched to ${mode.name} mode',
      Directionality.of(context),
    );
  }

  List<DrumQuickSelect> _resolveQuickSelects() {
    if (widget.quickSelectOptions != null) return widget.quickSelectOptions!;
    final reference = _currentDate;
    return [
      DrumQuickSelect.relative(
          label: widget.labels.today,
          offset: Duration.zero,
          referenceDate: reference),
      DrumQuickSelect.relative(
          label: widget.labels.tomorrow,
          offset: const Duration(days: 1),
          referenceDate: reference),
      DrumQuickSelect.relative(
          label: widget.labels.nextWeek,
          offset: const Duration(days: 7),
          referenceDate: reference),
    ];
  }

  bool _isQuickSelectEnabled(DrumQuickSelect chip) {
    return DrumDateUtils.isInRange(chip.date, _first, _last) &&
        (widget.selectableDayPredicate?.call(chip.date) ?? true);
  }

  /// The calendar and locale aware headline for the selected date.
  String _headline(Locale locale, String? localeName) {
    if (_system is GregorianCalendarSystem) {
      // Keep the exact Gregorian formatting so existing output is unchanged.
      return DateFormat.MMMEd(localeName).format(_selectedDate);
    }
    final c = _system.decode(_selectedDate);
    final weekday = DateFormat.E(localeName).format(_selectedDate);
    final month = _system.monthName(c.month, abbreviated: true, locale: locale);
    final day = DrumNumerals.format(c.day, localeName);
    return '$weekday, $month $day';
  }

  @override
  Widget build(BuildContext context) {
    final tokens = DrumPickerTheme.resolve(context, widget.theme);
    final locale = _effectiveLocale(context) ?? const Locale('en');
    final localeName = DrumLocaleUtils.toIntlLocale(locale);
    final materialLocalizations = MaterialLocalizations.of(context);
    final use24h = widget.use24hFormat ??
        MediaQuery.maybeOf(context)?.alwaysUse24HourFormat ??
        false;

    final secondary =
        widget.showGregorianAlongside && _system is! GregorianCalendarSystem
            ? DateFormat.yMMMMd(localeName).format(_selectedDate)
            : null;

    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PickerHeader(
          helpText: widget.helpText ??
              (widget.pickTime ? 'SELECT DATE & TIME' : 'SELECT DATE'),
          headline: _headline(locale, localeName),
          tokens: tokens,
          timeText: widget.pickTime
              ? (use24h ? DateFormat.Hm(localeName) : DateFormat.jm(localeName))
                  .format(_selectedDate)
              : null,
          secondaryText: secondary,
        ),
        if (widget.showModeToggle)
          ModeTabBar(
            mode: _mode,
            labels: widget.labels,
            onModeChanged: _onModeChanged,
          ),
        _buildBody(tokens, locale),
        if (widget.pickTime)
          TimeStrip(
            time: TimeOfDay.fromDateTime(_selectedDate),
            use24hFormat: use24h,
            minuteInterval: widget.minuteInterval,
            tokens: tokens,
            labels: widget.labels,
            localeName: localeName,
            onChanged: _onTimeChanged,
          ),
        if (_mode == DrumPickerMode.calendar && widget.showQuickSelects)
          QuickChips(
            options: _resolveQuickSelects(),
            isEnabled: _isQuickSelectEnabled,
            onSelected: (chip) => _onDateChanged(chip.date),
          ),
        if (widget.showActions) _buildActions(context, materialLocalizations),
      ],
    );

    final direction = widget.textDirection;
    if (direction != null) {
      content = Directionality(textDirection: direction, child: content);
    }
    return content;
  }

  Widget _buildBody(DrumPickerResolved tokens, Locale locale) {
    switch (_mode) {
      case DrumPickerMode.drum:
        return DrumModeWidget(
          selectedDate: _selectedDate,
          firstDate: _first,
          lastDate: _last,
          columnOrder: _resolveColumnOrder(context),
          showDayOfWeek: widget.showDayOfWeekInDrum,
          tokens: tokens,
          system: _system,
          locale: locale,
          labels: widget.labels,
          selectableDayPredicate: widget.selectableDayPredicate,
          onChanged: _onDateChanged,
        );
      case DrumPickerMode.calendar:
        return CalendarModeWidget(
          selectedDate: _selectedDate,
          firstDate: _first,
          lastDate: _last,
          currentDate: _currentDate,
          system: _system,
          locale: locale,
          tokens: tokens,
          selectableDayPredicate: widget.selectableDayPredicate,
          onChanged: _onDateChanged,
        );
      case DrumPickerMode.input:
        return InputModeWidget(
          selectedDate: _selectedDate,
          firstDate: _first,
          lastDate: _last,
          system: _system,
          locale: locale,
          selectableDayPredicate: widget.selectableDayPredicate,
          errorFormatText: widget.errorFormatText,
          errorInvalidText: widget.errorInvalidText,
          fieldHintText: widget.fieldHintText,
          fieldLabelText: widget.fieldLabelText,
          decoration: widget.inputDecoration,
          onChanged: _onDateChanged,
        );
    }
  }

  Widget _buildActions(
    BuildContext context,
    MaterialLocalizations localizations,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: OverflowBar(
        alignment: MainAxisAlignment.end,
        spacing: 8,
        children: [
          TextButton(
            onPressed: () => widget.onCancelled?.call(),
            child: Text(widget.cancelText ?? localizations.cancelButtonLabel),
          ),
          TextButton(
            onPressed: () => widget.onConfirmed?.call(_selectedDate),
            child: Text(widget.confirmText ?? localizations.okButtonLabel),
          ),
        ],
      ),
    );
  }
}
