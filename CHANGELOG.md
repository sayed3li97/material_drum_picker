# Changelog

## 1.12.1

- Declare `screenshots` in `pubspec.yaml` so the drum, calendar, range, event
  marker, calendar system, form field, and drop-in images render on the
  package's pub.dev landing page. Documentation and metadata only; no code
  changes.

## 1.12.0

- **`DrumDateFormField`.** A `FormField<DateTime>` for date input inside a
  `Form`, the way `TextFormField` works for text. It shows the selected date in
  a decorated, read-only field, opens a `DrumPicker` dialog on tap, and takes
  part in `Form.validate`, `Form.save`, and `Form.reset`, reporting errors
  through its `InputDecoration` and calling `onChanged` and `onSaved`.
  - The value is always a Gregorian `DateTime`, displayed in the active
    `calendar` and `locale` (for example a Persian date for
    `DrumCalendarType.jalali`); pass `formatValue` to format it yourself.
  - Accepts the common picker options: `calendar`, `calendarSystem`,
    `disabledWeekdays`, `holidays`, `firstDayOfWeek`, `selectableDayPredicate`,
    `theme`, `labels`, and the initial mode.

## 1.11.0

- **Event markers.** The calendar grid can now act as a lightweight event
  calendar. Pass an `eventLoader` to `DrumPicker`, `showDrumDatePicker`, or the
  `DrumCalendarDatePicker` drop-in; it is called once per visible day with its
  canonical Gregorian date and returns a list of `DrumEventMarker`s.
  - Days with markers show a row of dots (up to `maxEventMarkers`, four by
    default). Each `DrumEventMarker` may set its own `color` (falling back to the
    new `eventMarkerColor` theme token) and a `semanticLabel`.
  - The event count is announced to screen readers.
  - Pass a `markerBuilder` to draw your own marker widget (for example a count
    badge) instead of the dots; it receives the full marker list.
  - Works with every calendar system (Gregorian, Hijri, Chinese, Jalali) and the
    working day and holiday rules.
- New `eventMarkerColor` token on `DrumPickerTheme`.
- **Date range selection, as a calendar or a drum.** New
  `showDrumDateRangePicker` (a drop in style replacement for Flutter's
  `showDateRangePicker`, returning a `DateTimeRange?`) and the inline
  `DrumDateRangePicker`. The user can pick on a Material 3 calendar grid (tap a
  start day then an end day, with the in-between days highlighted) or on a
  two-wheel drum (a Start roller and an End roller), switching between them with
  a toggle. Use `initialMode` (`DrumRangeMode`) and `showModeToggle` to choose
  the presentation. This replaces the previous v1.0 stub that threw
  `UnimplementedError`.
- **Multiple date selection.** New `showDrumMultiDatePicker` (returning
  `List<DateTime>?`) and the inline `DrumMultiDatePicker` let the user pick any
  number of individual days by tapping to toggle.
- Both honor every selection rule the single picker does: alternative calendars,
  working day and holiday rules (`disabledWeekdays`, `holidays`), a custom
  `firstDayOfWeek`, a `selectableDayPredicate`, and per instance theming.

## 1.10.0

- **Persian Solar Hijri (Jalali) calendar.** New `DrumCalendarType.jalali`
  presents every date mode (drum, calendar, and input) in the official calendar
  of Iran and Afghanistan, composed with the existing right to left layout,
  theming, working day and holiday rules, first day of week, and range or
  multiple selection. The returned value stays a Gregorian `DateTime`.
  - Persian month names and Eastern Arabic digits in a Persian (`fa`) locale,
    transliterated names (Farvardin ... Esfand) elsewhere.
  - Automatic leap year handling: the last month (Esfand) has 29 days, or 30 in
    a leap year; the first six months have 31 days and the next five have 30.
  - The conversion is purely arithmetic (the standard algorithm used by the
    Iranian civil calendar), so no dataset is shipped. The supported range is
    Jalali years 1178 to 1633 (Gregorian 1799 to 2255), verified day for day
    against a reference implementation.
- New public `JalaliCalendarSystem` for use through `calendarSystem`.

## 1.8.0

- **Drop-in replacement layer.** New widgets and mappings let you migrate from
  the built in pickers by changing only the widget name, while gaining every
  extra option this package offers.
  - `DrumCalendarDatePicker` mirrors Flutter's `CalendarDatePicker` (a header
    less inline grid with `onDateChanged`, `onDisplayedMonthChanged`, and
    `initialCalendarMode`).
  - `DrumCupertinoDatePicker` mirrors Cupertino's `CupertinoDatePicker` (a
    header less inline wheel with `mode`, `initialDateTime`, streaming
    `onDateTimeChanged`, `minimumDate`/`maximumDate`, `minuteInterval`,
    `use24hFormat`, `dateOrder`, `backgroundColor`, `showDayOfWeek`, and
    `itemExtent`).
  - `showDrumDatePicker` and `showDrumDateTimePicker` now accept Flutter's
    `initialEntryMode` (`DatePickerEntryMode`) and map it to the picker's mode
    and toggle.
- New `showHeader` flag on `DrumPicker` and `DrumTimePicker` for a bare,
  embeddable picker (used by the inline drop-ins). Defaults to true.
- The drop-ins also expose this package's extras that the originals lack:
  alternative calendars, working day and holiday rules, a custom first day of
  week, and theming.

## 1.7.0

- **Working days only.** New optional `disabledWeekdays` makes the given
  weekdays unselectable in every mode, using the `DateTime.weekday` convention.
  For a working days only picker pass the weekend, for example
  `{DateTime.saturday, DateTime.sunday}` (or `{DateTime.friday,
  DateTime.saturday}` in much of the Middle East).
- **Holidays.** New optional `holidays` (a `Set<DateTime>`) marks specific dates
  as unselectable, compared by calendar day and ignoring the time component.
- **First day of the week.** New optional `firstDayOfWeek` overrides the
  locale's start of week in calendar mode (`DateTime.monday` to
  `DateTime.sunday`).
- `disabledWeekdays`, `holidays`, and `selectableDayPredicate` combine: a day is
  selectable only when it passes all of them, consistently across the drum,
  calendar, and input modes. The opening date snaps to the nearest selectable
  day, so a default that lands on a weekend or holiday does not start disabled.
- All three options are available on `DrumPicker`, `showDrumDatePicker`, and
  `showDrumDateTimePicker`, and all are optional with no change to existing
  behavior.

## 1.6.0

- **Chinese lunisolar calendar.** Pass `calendar: DrumCalendarType.chinese` to
  present the drum, calendar, and input modes in the Chinese calendar. It fully
  supports leap months (a leap year has 13 months, with the leap month 闰月
  repeating the previous month's number), astronomically determined month
  lengths (29 or 30 days), traditional month names (正月 ... 十二月, 闰二月), and
  the sexagenary year with its zodiac animal (for example 癸卯, Rabbit) shown
  under the headline. The returned value is always a Gregorian `DateTime`.
- The month length and leap month data is computed from the BSD licensed sxtwl
  astronomical engine, cross validated against a second engine, and vendored as
  a pure Dart table (lunar years 1900-2100), so the package keeps its only
  runtime dependencies as Flutter and `intl`. No third party engine is shipped.
- New public type `ChineseCalendarSystem`, and `DrumCalendarType.chinese`.
- Core calendar API additions (non breaking): `CalendarDate.isLeapMonth`,
  `DrumCalendarSystem.monthsInYear`, `monthLabel`, and `yearAnnotation`, with
  defaults that leave the Gregorian and Hijri calendars unchanged. Custom
  `DrumCalendarSystem` implementations with leap months or a variable month
  count are now possible.

## 1.5.0

- **Month as a name or a number.** New `monthFormat` parameter
  (`DrumMonthFormat.name` or `.numeric`) switches the drum month column between
  the abbreviated month name (the default) and a zero padded number. It works
  with every calendar system and locale, since a numeric month is just the
  month index in the locale's digits.
- **Configurable typed date format.** New `inputFormat` parameter takes a
  `DrumDateFormat` that controls the keyboard input mode: the order of the day,
  month, and year fields, the separator, and whether the year is two or four
  digits. Build one from a pattern with `DrumDateFormat.parse('DD-MM-YYYY')`, or
  use a preset (`DrumDateFormat.mdy`, `.dmy`, `.ymd`). The format drives the
  field's value, hint, and parsing in whatever calendar the picker is using, and
  a two digit year is resolved into the supported range at the year nearest the
  current selection.
- Both additions default to the previous behavior (month names and `MM/DD/YYYY`)
  and are available on `DrumPicker`, `showDrumDatePicker`, and
  `showDrumDateTimePicker`. Existing output is unchanged.

## 1.4.0

- **Deep visual theming.** `DrumPickerTheme` gains a much larger token set:
  typography (`headlineTextStyle`, `helpTextStyle`, `secondaryTextStyle`,
  `columnLabelTextStyle`, `selectedItemTextStyle`, `unselectedItemTextStyle`),
  the calendar grid colors that were previously hard coded
  (`dayForegroundColor`, `selectedDayBackgroundColor`,
  `selectedDayForegroundColor`, `todayColor`, `disabledDayColor`), and shape and
  spacing (`dayShape`, `selectorBandRadius`, `headerPadding`). Text style tokens
  merge over the defaults, so you can change one field (for example the weight)
  without losing the themed color.
- **Per-instance theming.** `DrumPicker`, `DrumTimePicker`, and the
  `showDrum*Picker` functions take a new `theme` parameter. It is merged over any
  ambient `DrumPickerTheme` extension, so you can style a single picker without
  touching the app theme. The calendar grid now honors the theme tokens too
  (previously it always used the raw `ColorScheme`).
- **Overridable labels.** New `DrumPickerLabels` lets you translate or relabel
  the fixed UI strings that were not otherwise localized: the drum column
  headers (DAY, MONTH, YEAR), the time strip headers (HOUR, MIN, AM/PM), the
  mode toggle (Calendar, Drum, Input), and the default quick select chips.
- **Custom input decoration.** A new `inputDecoration` parameter lets the input
  mode field inherit your app's `InputDecorationTheme` or a custom decoration.
- Fully backward compatible: every new token and parameter defaults to the
  previous appearance and behavior, so existing output is unchanged.

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
