# Changelog

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
