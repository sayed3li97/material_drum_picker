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
- **Pluggable data backed calendars.** Drive the picker from a published
  dataset of month start dates (for an official or committee lunar calendar)
  with `TabularLunarCalendarSystem`, passed through `calendarSystem`.
- **Full API parity** with `showDatePicker` and `CupertinoDatePicker`. Shared
  parameters keep the same names so migration is a one line change.
- **`selectableDayPredicate`** to disable weekends, holidays, or any custom
  rule, enforced in all three date modes.
- **`quickSelectOptions`** for custom chips such as Today, Next Monday, or
  +3 Days.
- **`columnOrder`** for Day/Month/Year, Month/Day/Year, or Year/Month/Day.
- **Material 3 theming** through `ColorScheme` tokens, with per app overrides
  via the `DrumPickerTheme` extension.
- **Right to left support** for Arabic, Hebrew, and Persian, with the weekday
  and column order flipping automatically.
- **Accessibility:** 44dp touch targets, keyboard navigation in the calendar,
  screen reader semantics, and reduced motion support.
- **All six platforms:** Android, iOS, web, macOS, Windows, and Linux.
- Zero runtime dependencies beyond Flutter and `intl`.

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
Saudi Arabia. The Persian solar (Jalali) calendar is a separate system and is
not included; the abstraction is designed so it can be added later.

![Hijri calendar with Arabic right to left](https://raw.githubusercontent.com/sayed3li97/material_drum_picker/main/doc/screenshots/hijri.png)

The same picker in Arabic flips right to left, shows Arabic month names and
digits, and starts the week on Saturday, exactly the way the Gregorian calendar
localizes. Set `showGregorianAlongside: true` to show the Gregorian equivalent
under the headline.

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
| `initialMode` | `DrumPickerMode` | `.drum` | Starting date mode |
| `showModeToggle` | `bool` | `true` | Show the mode tabs |
| `columnOrder` | `DrumColumnOrder?` | locale default | Column order in drum mode |
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

Add it to `ThemeData.extensions` to override individual tokens:

```dart
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
```

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

## Migration from showDatePicker

Most parameters keep the same name, so usually only the function name changes:

```dart
// Before
showDatePicker(
  context: context,
  initialDate: myDate,
  firstDate: DateTime(1900),
  lastDate: DateTime(2100),
  selectableDayPredicate: myPredicate,
  helpText: 'PICK DATE',
  locale: myLocale,
);

// After, identical parameter names
showDrumDatePicker(
  context: context,
  initialDate: myDate,
  firstDate: DateTime(1900),
  lastDate: DateTime(2100),
  selectableDayPredicate: myPredicate,
  helpText: 'PICK DATE',
  locale: myLocale,
  initialMode: DrumPickerMode.calendar, // optional, same feel as showDatePicker
);
```

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
- **Next** Date range selection (`showDrumDateRangePicker`), and a Persian solar
  (Jalali) calendar system.

## License

MIT, 2026. See [LICENSE](LICENSE).
