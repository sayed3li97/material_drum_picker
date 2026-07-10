# material_drum_picker

[![pub package](https://img.shields.io/pub/v/material_drum_picker.svg)](https://pub.dev/packages/material_drum_picker)
[![pub points](https://img.shields.io/pub/points/material_drum_picker)](https://pub.dev/packages/material_drum_picker/score)
[![likes](https://img.shields.io/pub/likes/material_drum_picker)](https://pub.dev/packages/material_drum_picker/score)
[![CI](https://github.com/sayed3li97/material_drum_picker/actions/workflows/ci.yml/badge.svg)](https://github.com/sayed3li97/material_drum_picker/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

A Material Design 3 date, time, and date+time picker with an iOS style drum
roller. It offers full API parity with Flutter's `showDatePicker` and
`CupertinoDatePicker`, uses Material 3 color tokens, and ships three context
aware date modes (drum, calendar, and keyboard input).

## Showcase

Every look below is rendered straight from the package: the drum mode (with
day of week), the calendar mode (quick selects plus disabled weekends), the
keyboard input mode, a combined date and time picker, and a dark theme.

![material_drum_picker showcase](https://raw.githubusercontent.com/sayed3li97/material_drum_picker/main/doc/screenshots/showcase.png)

Run the live demo for every option with `cd example && flutter run`, then open
the **Showcase** screen.

## Features

- **Drum mode.** An iOS style scroll wheel. Ideal for birth dates and expiry
  dates.
- **Calendar mode.** A Material 3 calendar grid with year navigation and
  configurable quick select chips.
- **Input mode.** A keyboard text field with live `MM/DD/YYYY` validation.
- **Date and time.** Opt in with `pickTime: true` (or `showDrumDateTimePicker`)
  to add an hour and minute drum, plus an AM/PM column in 12 hour mode.
- **Time only.** Use `DrumTimePicker` or `showDrumTimePicker` to pick just a
  `TimeOfDay`, configurable for AM/PM or 24 hour mode.
- **Hijri (Umm al-Qura) calendar.** Set `calendar: DrumCalendarType.hijri` to
  show every date mode in the lunar Hijri calendar, composed with the existing
  right to left layout. The returned value stays a Gregorian `DateTime`.
- **Chinese (lunisolar) calendar.** Set `calendar: DrumCalendarType.chinese` for
  the Chinese calendar with full leap month support (12 or 13 months a year),
  astronomical month lengths, traditional month names, and the sexagenary year
  and zodiac.
- **Persian Solar Hijri (Jalali) calendar.** Set `calendar:
  DrumCalendarType.jalali` for the official calendar of Iran and Afghanistan,
  with Persian month names and digits and automatic leap year handling, computed
  arithmetically with no dataset.
- **Event markers.** Pass an `eventLoader` to show dots (or your own
  `markerBuilder` widget) under the days that have events, turning the calendar
  grid into a lightweight event calendar.
- **Pluggable data backed calendars.** Drive the picker from a published
  dataset of month start dates (for an official or committee lunar calendar)
  with `TabularLunarCalendarSystem`, passed through `calendarSystem`.
- **Date range and multiple date selection** via `showDrumDateRangePicker` /
  `DrumDateRangePicker` and `showDrumMultiDatePicker` / `DrumMultiDatePicker`.
- **Drop-in replacements** for `showDatePicker`, `showTimePicker`,
  `showDateRangePicker`, `CalendarDatePicker`, and `CupertinoDatePicker`: rename
  the widget and the swap is done, with every extra option available on top.
- **Full API parity** with `showDatePicker` and `CupertinoDatePicker`. Shared
  parameters keep the same names so migration is a one line change.
- **`selectableDayPredicate`** to disable weekends, holidays, or any custom
  rule, enforced in all three date modes.
- **Working days, holidays, and first day of week.** `disabledWeekdays` for a
  working days only picker, `holidays` for specific blocked dates, and
  `firstDayOfWeek` to start the week on any day. All optional.
- **`quickSelectOptions`** for custom chips such as Today, Next Monday, or
  +3 Days.
- **`columnOrder`** for Day/Month/Year, Month/Day/Year, or Year/Month/Day.
- **`monthFormat`** to show the drum month as a name or a number, and
  **`inputFormat`** to control the typed date layout (for example
  `DrumDateFormat.parse('DD-MM-YYYY')`).
- **Material 3 theming** through `ColorScheme` tokens, with per app or per
  picker overrides via the `DrumPickerTheme` extension.
- **Right to left support** for Arabic, Hebrew, and Persian, with the weekday
  and column order flipping automatically.
- **Accessibility:** 44dp touch targets, keyboard navigation in the calendar,
  screen reader semantics, and reduced motion support.
- **All six platforms:** Android, iOS, web, macOS, Windows, and Linux.
- Zero runtime dependencies beyond Flutter and `intl`.

See [COMPARISON.md](COMPARISON.md) for an honest, side by side comparison with
the most downloaded date pickers on pub.dev, including where each of them is the
better choice.

## Pickers at a glance

| Function | Returns | Use it for |
|---|---|---|
| `showDrumDatePicker` | `DateTime?` | A date |
| `showDrumDateTimePicker` | `DateTime?` | A date and a time |
| `showDrumTimePicker` | `TimeOfDay?` | A time only |

Each function has an inline widget equivalent (`DrumPicker` and
`DrumTimePicker`) for embedding in a form without a dialog.

### Date and time

![date and time picker](https://raw.githubusercontent.com/sayed3li97/material_drum_picker/main/doc/screenshots/datetime.png)

### Time only

![time picker](https://raw.githubusercontent.com/sayed3li97/material_drum_picker/main/doc/screenshots/time.png)

### Hijri (Umm al-Qura)

Show every date mode in the lunar Hijri calendar. The value you receive is still
a Gregorian `DateTime`.

```dart
final picked = await showDrumDatePicker(
  context: context,
  firstDate: DateTime(2000),
  lastDate: DateTime(2050),
  calendar: DrumCalendarType.hijri,
  locale: const Locale('ar'),
);
```

The built in lunar calendar is Umm al-Qura, the official civil calendar of
Saudi Arabia. The Persian solar (Jalali) calendar is a separate system, covered
in its own section below.

![Hijri calendar with Arabic right to left](https://raw.githubusercontent.com/sayed3li97/material_drum_picker/main/doc/screenshots/hijri.png)

The same picker in Arabic flips right to left, shows Arabic month names and
digits, and starts the week on Saturday, exactly the way the Gregorian calendar
localizes. Set `showGregorianAlongside: true` to show the Gregorian equivalent
under the headline.

### Chinese (lunisolar)

Pass `calendar: DrumCalendarType.chinese` to present every date mode in the
Chinese lunisolar calendar. The value you receive is still a Gregorian
`DateTime`.

```dart
final picked = await showDrumDatePicker(
  context: context,
  firstDate: DateTime(2000),
  lastDate: DateTime(2050),
  calendar: DrumCalendarType.chinese,
  locale: const Locale('zh'),
);
```

![Chinese lunisolar calendar with leap months](https://raw.githubusercontent.com/sayed3li97/material_drum_picker/main/doc/screenshots/chinese.png)

The Chinese calendar is the hardest to support correctly, and it is fully
handled: a leap year has **13 months** (the leap month 闰月 repeats the previous
month's number), month lengths (29 or 30 days) and the leap month placement are
astronomical, traditional month names are shown (正月 ... 十二月, with a 闰
prefix for the leap month), and the **sexagenary year and zodiac** (for example
癸卯, Rabbit) appear under the headline. English locales show numbered months
with a `Leap N` marker.

The month length and leap data is computed from the BSD licensed
[sxtwl](https://github.com/yuangu/sxtwl_cpp) astronomical engine, cross
validated against a second engine, and vendored as a pure Dart table for lunar
years 1900-2100. As with every Chinese calendar implementation, dates far in the
future are predictive, since official ephemerides are published only a few years
ahead.

### Persian Solar Hijri (Jalali)

Pass `calendar: DrumCalendarType.jalali` to present every date mode in the
Persian Solar Hijri (Jalali) calendar, the official calendar of Iran and
Afghanistan. The value you receive is still a Gregorian `DateTime`.

```dart
final picked = await showDrumDatePicker(
  context: context,
  firstDate: DateTime(2000),
  lastDate: DateTime(2050),
  calendar: DrumCalendarType.jalali,
  locale: const Locale('fa'),
);
```

![Persian Solar Hijri (Jalali) calendar with Persian right to left](https://raw.githubusercontent.com/sayed3li97/material_drum_picker/main/doc/screenshots/jalali.png)

The year begins at the vernal equinox (Nowruz, around 21 March). The first six
months have 31 days, the next five have 30, and the last month (Esfand) has 29
days, or 30 in a leap year, all handled automatically. In a Persian (`fa`)
locale the picker flips right to left, shows the Persian month names (فروردین
... اسفند) and Eastern Arabic digits, and starts the week on Saturday; English
locales show transliterated names (Farvardin ... Esfand). Set
`showGregorianAlongside: true` to show the Gregorian equivalent under the
headline.

Unlike the lunar calendars, the Jalali conversion is purely arithmetic (the
standard algorithm used by the Iranian civil calendar), so no dataset is
shipped. The supported range is Jalali years 1178 to 1633 (Gregorian 1799 to
2255), verified day for day against a reference implementation.

### Data backed calendars

Some official and committee lunar calendars are published as data, year by year,
and cannot be computed from a formula. Drive the picker from a dataset of month
start dates with `TabularLunarCalendarSystem`, passed through `calendarSystem`,
which takes precedence over `calendar`.

```dart
// Provide your own dataset of contiguous Hijri month starts, plus a trailing
// sentinel entry (the start of the month after the last selectable month).
final system = TabularLunarCalendarSystem.fromJsonList(jsonDecode(assetString));

final picked = await showDrumDatePicker(
  context: context,
  firstDate: system.minSupported,
  lastDate: system.maxSupported,
  calendarSystem: system,
  locale: const Locale('ar'),
);
```

Calendars such as Taqweem al-Hadi (the Bahraini Ja'fari calendar) are expressed
this way. The package ships only the mechanism and the documented schema, never
any specific publisher's data. Supply the dataset from your own app, with the
publisher's permission and attribution, and refresh it roughly once a Hijri
year. Compare your `lastDate` with `system.maxSupported` to detect that the data
is near its end.

### Event markers

Turn the calendar grid into a lightweight event calendar by returning markers
for the days that have events. Pass an `eventLoader`, called once per visible
day with its Gregorian date, and return a list of `DrumEventMarker`s. Days with
markers show a row of dots (up to `maxEventMarkers`, four by default), and the
event count is announced to screen readers.

![Event markers: colored dots and a custom badge](https://raw.githubusercontent.com/sayed3li97/material_drum_picker/main/doc/screenshots/events.png)

```dart
// Your own events, keyed by day.
final eventsByDay = <DateTime, List<Meeting>>{ /* ... */ };

showDrumDatePicker(
  context: context,
  firstDate: DateTime(2024, 1, 1),
  lastDate: DateTime(2024, 12, 31),
  initialEntryMode: DatePickerEntryMode.calendarOnly,
  eventLoader: (day) =>
      eventsByDay[DateUtils.dateOnly(day)]
          ?.map((m) => DrumEventMarker(color: m.color, semanticLabel: m.title))
          .toList() ??
      const [],
);
```

Each `DrumEventMarker` may set its own `color` (falling back to the
`eventMarkerColor` theme token) and a `semanticLabel` for accessibility. For
full control over what a day draws, pass a `markerBuilder` and return your own
widget (for example a count badge); return `null` to fall back to the dots. It
receives the full marker list, so you can show the exact count even past the dot
cap:

```dart
DrumCalendarDatePicker(
  initialDate: _date,
  firstDate: DateTime(2024, 1, 1),
  lastDate: DateTime(2024, 12, 31),
  onDateChanged: (d) => setState(() => _date = d),
  eventLoader: _load,
  markerBuilder: (context, day, markers) => Align(
    // Sit below the number, where the default dots go, so the day stays legible.
    alignment: Alignment.bottomCenter,
    child: Container(
      margin: const EdgeInsets.only(bottom: 3),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${markers.length}',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onError,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
    ),
  ),
);
```

Markers work in every calendar mode surface: `DrumPicker`, `showDrumDatePicker`,
and the `DrumCalendarDatePicker` drop-in, and compose with every calendar system
(Gregorian, Hijri, Chinese, Jalali) and the working day and holiday rules.

## Installation

```yaml
dependencies:
  material_drum_picker: ^1.2.0
```

Add `flutter_localizations` to your app if you have not already:

```yaml
dependencies:
  flutter_localizations:
    sdk: flutter
```

Then register the delegates in your `MaterialApp`:

```dart
MaterialApp(
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  supportedLocales: const [Locale('en'), /* your locales */],
)
```

## Quick start

### A date (drop in replacement for showDatePicker)

```dart
import 'package:material_drum_picker/material_drum_picker.dart';

final DateTime? picked = await showDrumDatePicker(
  context: context,
  firstDate: DateTime(1900),
  lastDate: DateTime(2100),
);
```

### A time only

```dart
final TimeOfDay? time = await showDrumTimePicker(
  context: context,
  initialTime: TimeOfDay.now(),
  use24hFormat: true,   // null follows MediaQuery.alwaysUse24HourFormat
  minuteInterval: 5,    // 0, 5, 10, ...
);
```

Inline, embedded in a form:

```dart
DrumTimePicker(
  initialTime: const TimeOfDay(hour: 9, minute: 0),
  use24hFormat: false,  // shows an AM/PM column
  minuteInterval: 15,
  showActions: false,
  onChanged: (time) => setState(() => _time = time),
)
```

### A date and time

```dart
final DateTime? when = await showDrumDateTimePicker(
  context: context,
  firstDate: DateTime(2020),
  lastDate: DateTime(2030),
  use24hFormat: true,
  minuteInterval: 15,
);
// `when` carries the chosen hour and minute.
```

### Birth date picker

```dart
final today = DateTime.now();
final birthDate = await showDrumDatePicker(
  context: context,
  initialMode: DrumPickerMode.drum,        // a wheel for distant dates
  firstDate: DateTime(today.year - 120),
  lastDate: DateTime(today.year - 18, today.month, today.day),
  columnOrder: DrumColumnOrder.dmy,        // Day, Month, Year
  showModeToggle: false,                   // lock to drum mode
  helpText: 'SELECT BIRTH DATE',
);
```

### Appointment picker without weekends

```dart
final appointment = await showDrumDatePicker(
  context: context,
  initialMode: DrumPickerMode.calendar,
  firstDate: DateTime.now(),
  lastDate: DateTime.now().add(const Duration(days: 90)),
  selectableDayPredicate: (day) =>
      day.weekday != DateTime.saturday && day.weekday != DateTime.sunday,
  confirmText: 'BOOK APPOINTMENT',
);
```

### Custom quick selects

```dart
showDrumDatePicker(
  context: context,
  firstDate: DateTime.now().add(const Duration(days: 1)),
  lastDate: DateTime.now().add(const Duration(days: 30)),
  quickSelectOptions: [
    DrumQuickSelect.relative(label: 'Express +1',  offset: const Duration(days: 1)),
    DrumQuickSelect.relative(label: 'Standard +3', offset: const Duration(days: 3)),
    DrumQuickSelect.relative(label: 'Economy +7',  offset: const Duration(days: 7)),
  ],
);
```

## API reference

### showDrumDatePicker and showDrumDateTimePicker

| Parameter | Type | Default | Description |
|---|---|---|---|
| `context` | `BuildContext` | required | Build context |
| `firstDate` | `DateTime` | required | Minimum selectable date |
| `lastDate` | `DateTime` | required | Maximum selectable date |
| `initialDate` | `DateTime?` | today | Pre selected date |
| `currentDate` | `DateTime?` | `DateTime.now()` | The "today" marker |
| `selectableDayPredicate` | `SelectableDayPredicate?` | null | Return false to disable a day |
| `disabledWeekdays` | `Set<int>?` | null | Weekdays (Mon=1..Sun=7) that cannot be selected |
| `holidays` | `Set<DateTime>?` | null | Specific dates that cannot be selected |
| `firstDayOfWeek` | `int?` | locale default | First weekday in calendar mode (Mon=1..Sun=7) |
| `initialMode` | `DrumPickerMode` | `.drum` | Starting date mode |
| `showModeToggle` | `bool` | `true` | Show the mode tabs |
| `columnOrder` | `DrumColumnOrder?` | locale default | Column order in drum mode |
| `monthFormat` | `DrumMonthFormat` | `.name` | Drum month as a name or a number |
| `inputFormat` | `DrumDateFormat` | `.mdy` | Typed input order, separator, year width |
| `showDayOfWeekInDrum` | `bool` | `false` | Show weekday in the drum day column |
| `showQuickSelects` | `bool` | `true` | Show quick select chips |
| `quickSelectOptions` | `List<DrumQuickSelect>?` | Today/Tomorrow/+7d | Custom chips |
| `pickTime` | `bool` | `false` | Also pick a time of day |
| `use24hFormat` | `bool?` | ambient | 24 hour time strip (no AM/PM) |
| `minuteInterval` | `int` | `1` | Minute granularity (a divisor of 60) |
| `helpText` | `String?` | `'SELECT DATE'` | Header label |
| `confirmText` | `String?` | `'OK'` | Confirm button text |
| `cancelText` | `String?` | `'Cancel'` | Cancel button text |
| `errorFormatText` | `String?` | `'Invalid format'` | Input mode format error |
| `errorInvalidText` | `String?` | `'Out of range'` | Input mode range error |
| `fieldHintText` | `String?` | `'MM/DD/YYYY'` | Input field hint |
| `fieldLabelText` | `String?` | `'Enter Date'` | Input field label |
| `locale` | `Locale?` | ambient | Locale override |
| `textDirection` | `TextDirection?` | ambient | Text direction override |
| `barrierDismissible` | `bool` | `true` | Tap outside to dismiss |
| `barrierColor` | `Color?` | `Colors.black54` | Barrier color |
| `barrierLabel` | `String?` | localized | Barrier accessibility label |
| `useRootNavigator` | `bool` | `true` | Use the root navigator |
| `routeSettings` | `RouteSettings?` | null | Route settings |
| `restorationId` | `String?` | null | State restoration id |
| `anchorPoint` | `Offset?` | null | Split screen anchor |
| `builder` | `TransitionBuilder?` | null | Wrap the dialog with a Theme, and so on |

`showDrumDateTimePicker` takes the same parameters and is simply
`showDrumDatePicker` with `pickTime` set to true.

### showDrumTimePicker

| Parameter | Type | Default | Description |
|---|---|---|---|
| `context` | `BuildContext` | required | Build context |
| `initialTime` | `TimeOfDay?` | now | Pre selected time |
| `use24hFormat` | `bool?` | ambient | 24 hour mode (no AM/PM column) |
| `minuteInterval` | `int` | `1` | Minute granularity (a divisor of 60) |
| `helpText` | `String?` | `'SELECT TIME'` | Header label |
| `confirmText` | `String?` | `'OK'` | Confirm button text |
| `cancelText` | `String?` | `'Cancel'` | Cancel button text |
| `locale` | `Locale?` | ambient | Locale override |
| `textDirection` | `TextDirection?` | ambient | Text direction override |
| `barrierDismissible` | `bool` | `true` | Tap outside to dismiss |
| `barrierColor` | `Color?` | `Colors.black54` | Barrier color |
| `barrierLabel` | `String?` | null | Barrier accessibility label |
| `useRootNavigator` | `bool` | `true` | Use the root navigator |
| `routeSettings` | `RouteSettings?` | null | Route settings |
| `anchorPoint` | `Offset?` | null | Split screen anchor |
| `builder` | `TransitionBuilder?` | null | Wrap the dialog with a Theme, and so on |

### Inline widgets

`DrumPicker` accepts every `showDrumDatePicker` parameter, plus the callbacks
`onChanged`, `onConfirmed`, `onCancelled`, and `onModeChanged`, and the
`showActions` flag. `DrumTimePicker` accepts every `showDrumTimePicker`
parameter, plus `onChanged`, `onConfirmed`, `onCancelled`, and `showActions`.
Set `showActions: false` to drop the built in Cancel and OK buttons and drive
the value yourself with `onChanged`.

### DrumColumnOrder

| Value | Format | Typical regions |
|---|---|---|
| `dmy` | 15 Jun 2024 | UK, Europe, MENA, Australia |
| `mdy` | Jun 15 2024 | United States, Canada |
| `ymd` | 2024 Jun 15 | Japan, China, Korea |
| `ydm` | 2024 15 Jun | Rarely used |

### DrumPickerMode

| Value | Best for |
|---|---|
| `drum` | Birth dates, expiry dates, distant past or future |
| `calendar` | Scheduling events, appointments, near future |
| `input` | Power users, accessibility tools, typed entry |

### DrumPickerTheme

`DrumPickerTheme` exposes the picker's colors, typography, shape, and spacing.
Apply it app wide through `ThemeData.extensions`, or to a single picker through
the `theme` parameter. A per instance `theme` is merged over the ambient
extension, which is merged over Material 3 defaults derived from your
`ColorScheme`, so you only set what you want to change.

```dart
// App wide:
ThemeData(
  useMaterial3: true,
  extensions: const [
    DrumPickerTheme(
      headerBackgroundColor: Color(0xFF004D40),
      headerTextColor: Colors.white,
      itemExtent: 48,
      visibleItemCount: 3,
    ),
  ],
)

// Just one picker, without touching the app theme:
DrumPicker(
  firstDate: DateTime(2000),
  lastDate: DateTime(2100),
  theme: const DrumPickerTheme(
    // Calendar grid selection (previously not themeable).
    selectedDayBackgroundColor: Colors.deepPurple,
    selectedDayForegroundColor: Colors.white,
    todayColor: Colors.deepPurple,
    // Square-ish day cells instead of circles.
    dayShape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
    // Typography tokens merge over the defaults, so this only changes weight.
    headlineTextStyle: TextStyle(fontWeight: FontWeight.w700),
    selectorBandRadius: 16,
  ),
)
```

Available tokens: `headerBackgroundColor`, `headerTextColor`,
`cardBackgroundColor`, `selectorBandColor`, `selectedItemColor`,
`unselectedItemColor`, `dayForegroundColor`, `selectedDayBackgroundColor`,
`selectedDayForegroundColor`, `todayColor`, `disabledDayColor`, `helpTextStyle`,
`headlineTextStyle`, `secondaryTextStyle`, `columnLabelTextStyle`,
`selectedItemTextStyle`, `unselectedItemTextStyle`, `dayShape`,
`selectorBandRadius`, `headerPadding`, `itemExtent`, and `visibleItemCount`.

### DrumPickerLabels

The drum column headers (DAY, MONTH, YEAR), the time strip headers (HOUR, MIN,
AM/PM), the mode toggle (Calendar, Drum, Input), and the default quick select
chips are fixed strings. Pass `DrumPickerLabels` to translate or relabel them:

```dart
DrumPicker(
  firstDate: DateTime(2000),
  lastDate: DateTime(2100),
  labels: const DrumPickerLabels(
    dayColumn: 'JOUR',
    monthColumn: 'MOIS',
    yearColumn: 'ANNEE',
    calendarMode: 'Calendrier',
    drumMode: 'Molette',
    inputMode: 'Saisie',
  ),
)
```

### Working days, holidays, and first day of week

![working days, a disabled holiday, and a Monday start](https://raw.githubusercontent.com/sayed3li97/material_drum_picker/main/doc/screenshots/working_days.png)

Three optional parameters cover the common business scheduling rules:

```dart
DrumPicker(
  firstDate: DateTime(2024, 1, 1),
  lastDate: DateTime(2024, 12, 31),
  // Only working days are selectable (pass the weekend to disable).
  disabledWeekdays: const {DateTime.saturday, DateTime.sunday},
  // Specific public holidays are blocked (time is ignored).
  holidays: {DateTime(2024, 12, 25), DateTime(2024, 1, 1)},
  // The calendar week starts on Monday.
  firstDayOfWeek: DateTime.monday,
)
```

- `disabledWeekdays`, `holidays`, and `selectableDayPredicate` are combined: a
  day is selectable only when it passes all of them, in the drum, calendar, and
  input modes alike.
- The opening date snaps to the nearest selectable day, so a default that lands
  on a weekend or holiday never starts on a disabled day.
- All three use the `DateTime.weekday` convention (`DateTime.monday` == 1 to
  `DateTime.sunday` == 7) and are null by default (nothing disabled, locale
  default week start).

### Custom input field decoration

Pass `inputDecoration` so the input mode field matches your form styling (for
example a filled field), instead of the default outlined border:

```dart
DrumPicker(
  firstDate: DateTime(2000),
  lastDate: DateTime(2100),
  inputDecoration: const InputDecoration(filled: true),
)
```

### Month as a name or a number, and a custom typed format

![month formats and a custom typed input format](https://raw.githubusercontent.com/sayed3li97/material_drum_picker/main/doc/screenshots/formats.png)

Use `monthFormat` to show the drum month column as a name (default) or as a
zero padded number. It works with every calendar system and locale.

```dart
DrumPicker(
  firstDate: DateTime(2000),
  lastDate: DateTime(2100),
  monthFormat: DrumMonthFormat.numeric, // 06 instead of Jun
)
```

Use `inputFormat` to control how the keyboard input mode lays out a date: the
order of the day, month, and year fields, the separator, and whether the year is
two or four digits. Build one from a pattern, or use a preset
(`DrumDateFormat.mdy`, `.dmy`, `.ymd`):

```dart
DrumPicker(
  firstDate: DateTime(2000),
  lastDate: DateTime(2100),
  inputFormat: DrumDateFormat.parse('DD-MM-YYYY'),
  // Other examples:
  //   DrumDateFormat.parse('YYYY.MM.DD')
  //   DrumDateFormat.parse('DD/MM/YY')   // two digit year
  //   DrumDateFormat.ymd                 // ISO style YYYY-MM-DD
)
```

The format drives how the field shows the current value, the hint, and how it
parses what the user types, in whatever calendar the picker is using. A two
digit year is resolved into the supported range at the year nearest the current
selection. For the drum wheel column order, use `columnOrder`.

## Localization

The pickers follow the ambient locale for month and weekday names, the first
day of the week, AM/PM labels, the column order, and right to left layout. Pass
`locale` and `textDirection` to override them for a single picker. The time
format follows `MediaQuery.alwaysUse24HourFormat` unless you set `use24hFormat`.

The calendar system is independent of locale and direction. You can combine any
calendar with any locale: for example Umm al-Qura with `en` shows Latin digits
and English Hijri month names, while Umm al-Qura with an Arabic locale shows the
Arabic month names and that locale's digits, flipping right to left exactly the
way the Gregorian calendar does.

## Date range and multiple dates

Pick a contiguous **range** or any **set of individual days**, with the same
rules as the single picker (calendars, working days, holidays, first day of
week, theming). The range picker offers **two presentations the user can switch
between** with a toggle: a Material 3 **calendar grid** and a **two-wheel drum**
(a Start roller and an End roller).

![date range as a calendar or a drum, and multiple selected days](https://raw.githubusercontent.com/sayed3li97/material_drum_picker/main/doc/screenshots/range.png)

Use `initialMode` (`DrumRangeMode.calendar` or `.drum`) to choose the first
view, and `showModeToggle` to let the end user switch (default `true`); set it
to `false` to lock one presentation:

```dart
DrumDateRangePicker(
  firstDate: DateTime(2024, 1, 1),
  lastDate: DateTime(2024, 12, 31),
  initialMode: DrumRangeMode.drum, // open on the two-wheel drum
  showModeToggle: true,            // ... but let the user switch to the grid
  onChanged: (range) => setState(() => _range = range),
);
```

### As a dialog

`showDrumDateRangePicker` is a drop-in style replacement for Flutter's
`showDateRangePicker` and returns a `DateTimeRange?`:

```dart
final range = await showDrumDateRangePicker(
  context: context,
  firstDate: DateTime(2024, 1, 1),
  lastDate: DateTime(2024, 12, 31),
  // Optional extras the built-in range picker lacks:
  disabledWeekdays: const {DateTime.saturday, DateTime.sunday},
  firstDayOfWeek: DateTime.monday,
);
if (range != null) {
  print('${range.start} to ${range.end}');
}

// Multiple individual days -> List<DateTime>?
final days = await showDrumMultiDatePicker(
  context: context,
  firstDate: DateTime(2024, 1, 1),
  lastDate: DateTime(2024, 12, 31),
);
```

### Inline (embedded in a form)

`DrumDateRangePicker` and `DrumMultiDatePicker` are header-less inline calendars.
Tap a start day then an end day for a range, or tap to toggle days for a set:

```dart
DrumDateRangePicker(
  firstDate: DateTime(2024, 1, 1),
  lastDate: DateTime(2024, 12, 31),
  initialDateRange: DateTimeRange(
    start: DateTime(2024, 6, 10),
    end: DateTime(2024, 6, 18),
  ),
  onChanged: (range) {
    // range is null until both ends are chosen
    if (range != null) setState(() => _range = range);
  },
);

DrumMultiDatePicker(
  firstDate: DateTime(2024, 1, 1),
  lastDate: DateTime(2024, 12, 31),
  onChanged: (dates) => setState(() => _dates = dates), // sorted List<DateTime>
);
```

## Drop-in replacements

This package mirrors the constructors and functions of Flutter's Material and
Cupertino pickers, so in most cases **you only change the widget name and the
swap is done**. Each replacement also unlocks options the originals do not have
(drum mode, calendar systems, working days and holidays, theming, and more),
all optional.

![drop in replacements, rename the widget and keep your code](https://raw.githubusercontent.com/sayed3li97/material_drum_picker/main/doc/screenshots/dropin.png)

| Flutter / Cupertino | This package | Shape |
|---|---|---|
| `showDatePicker(...)` | `showDrumDatePicker(...)` | modal, returns `DateTime?` |
| `showTimePicker(...)` | `showDrumTimePicker(...)` | modal, returns `TimeOfDay?` |
| `showDateRangePicker(...)` | `showDrumDateRangePicker(...)` | modal, returns `DateTimeRange?` |
| `CalendarDatePicker(...)` | `DrumCalendarDatePicker(...)` | inline grid, `onDateChanged` |
| `CupertinoDatePicker(...)` | `DrumCupertinoDatePicker(...)` | inline wheel, streaming `onDateTimeChanged` |

### Modal pickers

The shared parameters keep the same names, so usually only the function name
changes. `showDrumDatePicker` even accepts Flutter's `initialEntryMode`
(`DatePickerEntryMode`) and maps it for you:

```dart
// Before
showDatePicker(
  context: context,
  initialDate: myDate,
  firstDate: DateTime(1900),
  lastDate: DateTime(2100),
  initialEntryMode: DatePickerEntryMode.calendarOnly,
  selectableDayPredicate: myPredicate,
  helpText: 'PICK DATE',
);

// After, identical parameter names
showDrumDatePicker(
  context: context,
  initialDate: myDate,
  firstDate: DateTime(1900),
  lastDate: DateTime(2100),
  initialEntryMode: DatePickerEntryMode.calendarOnly,
  selectableDayPredicate: myPredicate,
  helpText: 'PICK DATE',
);
```

### Inline widgets

`DrumCalendarDatePicker` matches `CalendarDatePicker` (a header-less inline
grid), and `DrumCupertinoDatePicker` matches `CupertinoDatePicker` (a
header-less inline wheel that streams changes through `onDateTimeChanged`):

```dart
// Before
CupertinoDatePicker(
  mode: CupertinoDatePickerMode.date,
  initialDateTime: _date,
  onDateTimeChanged: (d) => setState(() => _date = d),
);

// After
DrumCupertinoDatePicker(
  mode: CupertinoDatePickerMode.date,
  initialDateTime: _date,
  onDateTimeChanged: (d) => setState(() => _date = d),
  // Optional extras the Cupertino widget lacks:
  calendar: DrumCalendarType.hijri,
  disabledWeekdays: const {DateTime.saturday, DateTime.sunday},
);
```

Notes on parity: a handful of Material-only parameters that have no equivalent
(for example `initialDatePickerMode` year view, or the entry-mode switch icons)
are accepted where it keeps the call compiling, and otherwise can simply be
removed. `CupertinoDatePickerMode.monthYear` is approximated with the full date
columns.

## Contributing

Contributions are welcome. Please read [CONTRIBUTING.md](CONTRIBUTING.md) for
the development setup and the checks that run in CI, and note the
[Code of Conduct](CODE_OF_CONDUCT.md). To report a security issue, see
[SECURITY.md](SECURITY.md).

## Roadmap

- **v1.0** Single date picker (drum, calendar, and input modes).
- **v1.1** Combined date and time picking (`pickTime`, `showDrumDateTimePicker`).
- **v1.2** Standalone time picker (`DrumTimePicker`, `showDrumTimePicker`).
- **v1.3** Hijri (Umm al-Qura) calendar and pluggable data backed calendars.
- **v1.6** Chinese lunisolar calendar with leap month support.
- **v1.8** Drop-in replacements for the Material and Cupertino pickers.
- **v1.10** Persian Solar Hijri (Jalali) calendar system.
- **v1.11** Date range and multiple date selection, and event markers in the
  calendar grid.

## License

MIT, 2026. See [LICENSE](LICENSE).
