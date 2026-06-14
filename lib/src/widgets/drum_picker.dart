import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../models/drum_column_order.dart';
import '../models/drum_picker_mode.dart';
import '../models/drum_quick_select.dart';
import '../theme/drum_picker_theme.dart';
import '../utils/drum_date_utils.dart';
import '../utils/drum_locale_utils.dart';
import 'internal/mode_tab_bar.dart';
import 'internal/picker_header.dart';
import 'internal/quick_chips.dart';
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
    this.onChanged,
    this.onConfirmed,
    this.onCancelled,
    this.onModeChanged,
  }) : assert(!firstDate.isAfter(lastDate),
            'firstDate must be on or before lastDate');

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

  DateTime get _currentDate =>
      DrumDateUtils.dateOnly(widget.currentDate ?? DateTime.now());

  @override
  void initState() {
    super.initState();
    // The local date-symbol data populates synchronously, so all locales are
    // available immediately for DateFormat (prevents crashes for non-en apps).
    initializeDateFormatting();
    _mode = widget.initialMode;
    final initial = widget.initialDate ?? widget.currentDate ?? DateTime.now();
    _selectedDate =
        DrumDateUtils.clamp(initial, widget.firstDate, widget.lastDate);
  }

  Locale? _effectiveLocale(BuildContext context) =>
      widget.locale ?? Localizations.maybeLocaleOf(context);

  DrumColumnOrder _resolveColumnOrder(BuildContext context) {
    if (widget.columnOrder != null) return widget.columnOrder!;
    return DrumLocaleUtils.columnOrderForLocale(_effectiveLocale(context));
  }

  void _onDateChanged(DateTime date) {
    final normalized = DrumDateUtils.dateOnly(date);
    if (DrumDateUtils.isSameDay(normalized, _selectedDate)) return;
    setState(() => _selectedDate = normalized);
    widget.onChanged?.call(normalized);
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
          label: 'Today', offset: Duration.zero, referenceDate: reference),
      DrumQuickSelect.relative(
          label: 'Tomorrow',
          offset: const Duration(days: 1),
          referenceDate: reference),
      DrumQuickSelect.relative(
          label: 'Next week',
          offset: const Duration(days: 7),
          referenceDate: reference),
    ];
  }

  bool _isQuickSelectEnabled(DrumQuickSelect chip) {
    return DrumDateUtils.isInRange(
          chip.date,
          widget.firstDate,
          widget.lastDate,
        ) &&
        (widget.selectableDayPredicate?.call(chip.date) ?? true);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = DrumPickerTheme.resolve(context);
    final localeName = DrumLocaleUtils.toIntlLocale(_effectiveLocale(context));
    final materialLocalizations = MaterialLocalizations.of(context);

    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PickerHeader(
          helpText: widget.helpText ?? 'SELECT DATE',
          selectedDate: _selectedDate,
          tokens: tokens,
          localeName: localeName,
        ),
        if (widget.showModeToggle)
          ModeTabBar(mode: _mode, onModeChanged: _onModeChanged),
        _buildBody(tokens, localeName),
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

  Widget _buildBody(DrumPickerResolved tokens, String? localeName) {
    switch (_mode) {
      case DrumPickerMode.drum:
        return DrumModeWidget(
          selectedDate: _selectedDate,
          firstDate: widget.firstDate,
          lastDate: widget.lastDate,
          columnOrder: _resolveColumnOrder(context),
          showDayOfWeek: widget.showDayOfWeekInDrum,
          tokens: tokens,
          selectableDayPredicate: widget.selectableDayPredicate,
          localeName: localeName,
          onChanged: _onDateChanged,
        );
      case DrumPickerMode.calendar:
        return CalendarModeWidget(
          selectedDate: _selectedDate,
          firstDate: widget.firstDate,
          lastDate: widget.lastDate,
          currentDate: _currentDate,
          selectableDayPredicate: widget.selectableDayPredicate,
          localeName: localeName,
          onChanged: _onDateChanged,
        );
      case DrumPickerMode.input:
        return InputModeWidget(
          selectedDate: _selectedDate,
          firstDate: widget.firstDate,
          lastDate: widget.lastDate,
          selectableDayPredicate: widget.selectableDayPredicate,
          errorFormatText: widget.errorFormatText,
          errorInvalidText: widget.errorInvalidText,
          fieldHintText: widget.fieldHintText,
          fieldLabelText: widget.fieldLabelText,
          localeName: localeName,
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
