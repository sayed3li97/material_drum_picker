# Changelog

## 1.1.0

- **Date + time picking.** `DrumPicker` gains `pickTime`, `use24hFormat`, and
  `minuteInterval`. When `pickTime` is true, a compact time drum strip (hour,
  minute, and AM/PM in 12-hour mode) appears below the date selector and the
  confirmed value includes the chosen time.
- New `showDrumDateTimePicker` convenience function — same API as
  `showDrumDatePicker` but returns a `DateTime` that carries the time.
- `use24hFormat` falls back to `MediaQuery.alwaysUse24HourFormat`; AM/PM labels
  and the header time are localized. `minuteInterval` snaps the initial minute
  and is asserted to divide 60.

## 1.0.0

Initial release.

- `showDrumDatePicker` — a drop-in replacement for Flutter's `showDatePicker`
  with full parameter parity (`firstDate`, `lastDate`, `initialDate`,
  `currentDate`, `selectableDayPredicate`, `helpText`, `confirmText`,
  `cancelText`, `errorFormatText`, `errorInvalidText`, `fieldHintText`,
  `fieldLabelText`, `locale`, `textDirection`, `barrierDismissible`,
  `barrierColor`, `barrierLabel`, `useRootNavigator`, `routeSettings`,
  `restorationId`, `anchorPoint`, `builder`).
- `DrumPicker` inline widget for embedding in forms (no dialog).
- Three context-aware input modes: `drum`, `calendar`, and `input`, with a mode
  toggle.
- `selectableDayPredicate` enforced in all three modes, including
  nearest-valid-date snapping in drum mode.
- Quick-select chips with `quickSelectOptions` and `DrumQuickSelect.relative`.
- Configurable `columnOrder` (`dmy` / `mdy` / `ymd` / `ydm`) with locale-aware
  defaults, plus `showDayOfWeekInDrum`.
- `DrumPickerTheme` extension for Material 3 token overrides.
- Full RTL and localization support via `intl` and `flutter_localizations`.
- `showDrumDateRangePicker` API stub (throws `UnimplementedError`; full
  implementation planned for 1.1.0).
