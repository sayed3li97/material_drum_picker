import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../theme/drum_picker_theme.dart';
import '../utils/drum_date_utils.dart';
import '../utils/drum_locale_utils.dart';
import 'internal/time_strip.dart';

/// A Material Design 3 time picker with an iOS-style drum roller.
///
/// Selects a [TimeOfDay] only (no date). The time strip uses 12-hour format
/// with an AM/PM column by default, or 24-hour format when [use24hFormat] is
/// true. When [use24hFormat] is null it follows
/// `MediaQuery.alwaysUse24HourFormat`.
///
/// Use this widget directly to embed the picker inline (set [showActions] to
/// false), or use [showDrumTimePicker] to present it in a modal dialog.
class DrumTimePicker extends StatefulWidget {
  /// Creates a drum time picker.
  const DrumTimePicker({
    super.key,
    this.initialTime,
    this.use24hFormat,
    this.minuteInterval = 1,
    this.helpText,
    this.confirmText,
    this.cancelText,
    this.showActions = true,
    this.locale,
    this.textDirection,
    this.onChanged,
    this.onConfirmed,
    this.onCancelled,
  }) : assert(
            60 % minuteInterval == 0, 'minuteInterval must be a divisor of 60');

  /// The time initially selected when the picker opens.
  ///
  /// Defaults to the current time of day if null. The minute is snapped to
  /// [minuteInterval].
  final TimeOfDay? initialTime;

  /// Whether the picker uses 24-hour format (no AM/PM column).
  ///
  /// When null, falls back to `MediaQuery.alwaysUse24HourFormat`.
  final bool? use24hFormat;

  /// The granularity, in minutes, of the minute column.
  ///
  /// Must be a divisor of 60 (for example 1, 5, 15).
  final int minuteInterval;

  /// The label displayed at the top of the picker header.
  ///
  /// Defaults to 'SELECT TIME'.
  final String? helpText;

  /// The label of the confirm/OK button.
  final String? confirmText;

  /// The label of the cancel button.
  final String? cancelText;

  /// Whether to show Cancel/OK action buttons below the picker.
  final bool showActions;

  /// Locale override for time formatting.
  final Locale? locale;

  /// Text direction override.
  final TextDirection? textDirection;

  /// Called every time the user changes the selected time.
  final ValueChanged<TimeOfDay>? onChanged;

  /// Called when the user taps OK.
  final ValueChanged<TimeOfDay>? onConfirmed;

  /// Called when the user taps Cancel.
  final VoidCallback? onCancelled;

  @override
  State<DrumTimePicker> createState() => _DrumTimePickerState();
}

class _DrumTimePickerState extends State<DrumTimePicker> {
  late TimeOfDay _time;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
    final initial = widget.initialTime ?? TimeOfDay.now();
    _time = TimeOfDay(
      hour: initial.hour,
      minute: DrumDateUtils.snapMinute(initial.minute, widget.minuteInterval),
    );
  }

  Locale? _effectiveLocale(BuildContext context) =>
      widget.locale ?? Localizations.maybeLocaleOf(context);

  void _onTimeChanged(TimeOfDay time) {
    if (time == _time) return;
    setState(() => _time = time);
    widget.onChanged?.call(time);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = DrumPickerTheme.resolve(context);
    final localeName = DrumLocaleUtils.toIntlLocale(_effectiveLocale(context));
    final materialLocalizations = MaterialLocalizations.of(context);
    final use24h = widget.use24hFormat ??
        MediaQuery.maybeOf(context)?.alwaysUse24HourFormat ??
        false;

    final reference = DateTime(2020, 1, 1, _time.hour, _time.minute);
    final timeText =
        (use24h ? DateFormat.Hm(localeName) : DateFormat.jm(localeName))
            .format(reference);

    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(tokens, timeText),
        TimeStrip(
          time: _time,
          use24hFormat: use24h,
          minuteInterval: widget.minuteInterval,
          tokens: tokens,
          localeName: localeName,
          onChanged: _onTimeChanged,
        ),
        const SizedBox(height: 8),
        if (widget.showActions) _buildActions(materialLocalizations),
      ],
    );

    final direction = widget.textDirection;
    if (direction != null) {
      content = Directionality(textDirection: direction, child: content);
    }
    return content;
  }

  Widget _buildHeader(DrumPickerResolved tokens, String timeText) {
    return Container(
      width: double.infinity,
      color: tokens.headerBackgroundColor,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.helpText ?? 'SELECT TIME',
            style: TextStyle(
              color: tokens.headerTextColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            timeText,
            style: TextStyle(
              color: tokens.headerTextColor,
              fontSize: 34,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(MaterialLocalizations localizations) {
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
            onPressed: () => widget.onConfirmed?.call(_time),
            child: Text(widget.confirmText ?? localizations.okButtonLabel),
          ),
        ],
      ),
    );
  }
}

/// Shows a [DrumTimePicker] in a Material Design 3 dialog.
///
/// Returns the selected [TimeOfDay], or null if the user cancels or dismisses
/// the dialog by tapping the barrier.
///
/// ```dart
/// final time = await showDrumTimePicker(
///   context: context,
///   initialTime: TimeOfDay.now(),
///   use24hFormat: true,
///   minuteInterval: 5,
/// );
/// ```
Future<TimeOfDay?> showDrumTimePicker({
  required BuildContext context,
  TimeOfDay? initialTime,
  bool? use24hFormat,
  int minuteInterval = 1,
  String? helpText,
  String? confirmText,
  String? cancelText,
  Locale? locale,
  TextDirection? textDirection,
  bool barrierDismissible = true,
  Color? barrierColor,
  String? barrierLabel,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
  Offset? anchorPoint,
  TransitionBuilder? builder,
}) {
  Widget dialog = _DrumTimePickerDialog(
    initialTime: initialTime,
    use24hFormat: use24hFormat,
    minuteInterval: minuteInterval,
    helpText: helpText,
    confirmText: confirmText,
    cancelText: cancelText,
    locale: locale,
    textDirection: textDirection,
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

  return showDialog<TimeOfDay>(
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

class _DrumTimePickerDialog extends StatelessWidget {
  const _DrumTimePickerDialog({
    this.initialTime,
    this.use24hFormat,
    required this.minuteInterval,
    this.helpText,
    this.confirmText,
    this.cancelText,
    this.locale,
    this.textDirection,
  });

  final TimeOfDay? initialTime;
  final bool? use24hFormat;
  final int minuteInterval;
  final String? helpText;
  final String? confirmText;
  final String? cancelText;
  final Locale? locale;
  final TextDirection? textDirection;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      clipBehavior: Clip.antiAlias,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320, maxHeight: 480),
        child: SingleChildScrollView(
          child: DrumTimePicker(
            initialTime: initialTime,
            use24hFormat: use24hFormat,
            minuteInterval: minuteInterval,
            helpText: helpText,
            confirmText: confirmText,
            cancelText: cancelText,
            locale: locale,
            textDirection: textDirection,
            onConfirmed: (time) => Navigator.of(context).pop(time),
            onCancelled: () => Navigator.of(context).pop(),
          ),
        ),
      ),
    );
  }
}
