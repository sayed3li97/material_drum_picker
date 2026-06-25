# Changelog

## 1.3.0

- **Hijri (Umm al-Qura) calendar.** Pass `calendar: DrumCalendarType.hijri` to
  show the drum, calendar, and input modes in the lunar Hijri calendar, fully
  composed with the existing right to left support. The returned value is still
  a Gregorian `DateTime`. The Umm al-Qura table is vendored as pure Dart, so the
  package keeps its only runtime dependencies as Flutter and `intl`.
- **Pluggable data backed calendars.** New `TabularLunarCalendarSystem` lets you
  drive the picker from a published dataset of Hijri month start dates (for an
  official or committee lunar calendar). Pass an instance through the new
  `calendarSystem` parameter, which takes precedence over `calendar`. The
  package ships only the mechanism and a documented schema, never any specific
  publisher's data. Malformed datasets are rejected rather than producing wrong
  dates.
- New public types: `DrumCalendarType`, `DrumCalendarSystem`,
  `GregorianCalendarSystem`, `HijriCalendarSystem`,
  `TabularLunarCalendarSystem`, `TabularLunarMonth`, and `CalendarDate`.
- New `showGregorianAlongside` flag (off by default) renders the Gregorian
  equivalent as a small secondary line in the header.
- Day, month, and year numbers now route through one locale aware numeral path,
  so a locale that uses Arabic-Indic digits renders them consistently across the
  drum, calendar, input, and header.
- No breaking changes. Every new parameter defaults to the previous Gregorian
  behavior, and all existing tests and goldens pass unchanged.

## 1.2.0

- **Time-only picking.** New `DrumTimePicker` widget and `showDrumTimePicker`
  function that return a `TimeOfDay`. Configurable for AM/PM (12 hour) or
  24 hour mode via `use24hFormat` (which falls back to
  `MediaQuery.alwaysUse24HourFormat`), with `minuteInterval` granularity.
- Example app gains a "Time only" screen (12 hour dialog, 24 hour dialog with
  5 minute steps, and an inline 15 minute picker).
- README rewritten and expanded: a pickers overview table plus dedicated
  date+time and time-only screenshots.

## 1.1.0

- **Date + time picking.** `DrumPicker` gains `pickTime`, `use24hFormat`, and
  `minuteInterval`. When `pickTime` is true, a compact time drum strip (hour,
  minute, and AM/PM in 12-hour mode) appears below the date selector and the
  confirmed value includes the chosen time.
- New `showDrumDateTimePicker` convenience function, the same API as
  `showDrumDatePicker` but returns a `DateTime` that carries the time.
- `use24hFormat` falls back to `MediaQuery.alwaysUse24HourFormat`; AM/PM labels
  and the header time are localized. `minuteInterval` snaps the initial minute
  and is asserted to divide 60.

## 1.0.0

Initial release.

- `showDrumDatePicker`, a drop-in replacement for Flutter's `showDatePicker`
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
