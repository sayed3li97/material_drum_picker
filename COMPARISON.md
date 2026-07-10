# How material_drum_picker compares

A side by side look at `material_drum_picker` and the most downloaded date and
time pickers on pub.dev. The goal is to help you pick the right package, so the
weaknesses are listed as plainly as the strengths.

The competitors were chosen by pub.dev 30 day download volume at the time of
writing. Download numbers move around, so treat them as rough magnitudes, not
exact figures. Feature columns were read from each package's public API and
README; if something is out of date, please open an issue or a pull request.

## At a glance

| | material_drum_picker | table_calendar | syncfusion_flutter_datepicker | calendar_date_picker2 | flutter_datetime_picker_plus | omni_datetime_picker |
| --- | --- | --- | --- | --- | --- | --- |
| Rough monthly downloads | growing | very high | very high | high | medium | medium |
| License | MIT | Apache 2.0 | Commercial / free community | BSD 3 | MIT | MIT |
| Runtime dependencies | `intl` only | `intl`, `simple_gesture_detector` | Syncfusion core | `intl` | none | `intl` |
| Drum / wheel mode | yes | no | no | no | yes | no |
| Calendar grid mode | yes | yes | yes | yes | no | no |
| Keyboard input mode | yes | no | yes | no | no | no |
| Modes in one widget | yes (drum + calendar + input) | no | partial | no | no | no |
| Date range selection | yes | via range | yes | yes | no | yes |
| Multiple date selection | yes | via multi | yes | yes | no | no |
| Event markers | yes | yes | yes | no | no | no |
| Time picking | yes | no | via siblings | no | yes | yes |
| Gregorian calendar | yes | yes | yes | yes | yes | yes |
| Hijri calendar | yes | no | yes (separate widget) | no | no | no |
| Chinese lunisolar calendar | yes | no | no | no | no | no |
| Persian (Jalali) calendar | yes | no | no | no | no | no |
| Pluggable custom calendar | yes | no | no | no | no | no |
| Working day / holiday rules | yes | via builders | partial | partial | no | no |
| Material 3 theming extension | yes | manual | its own theming | partial | no | partial |
| Drop-in API parity helpers | yes | no | no | no | no | no |
| Right to left support | yes | yes | yes | yes | partial | yes |

## Where each package is the better choice

**table_calendar** is a full month and week event calendar view, not a picker.
If you need a scrollable calendar page with format toggling (month, two week,
week) and heavy per day customization as the centerpiece of a screen, it is
purpose built for that and has the largest community. `material_drum_picker` is
a picker with an event marker option, not a full calendar page.

**syncfusion_flutter_datepicker** is part of a large, commercially backed UI
suite. If you already use Syncfusion widgets, or want a single vendor with
support contracts, it is a natural fit. It is heavier and its licensing differs
from a permissive open source package.

**calendar_date_picker2** is a lean, focused Gregorian range and multi picker.
If all you need is single, range, or multi Gregorian selection with a small
dependency footprint, it does that well and is very popular for it.

**flutter_datetime_picker_plus** is a compact Cupertino style wheel picker with
no runtime dependencies. If you only want a bottom sheet wheel and nothing else,
it is minimal.

**omni_datetime_picker** combines date and time in one dialog with a clean
Material look. If a straightforward combined date plus time dialog is all you
need, it is simple to adopt.

## Where material_drum_picker leads

- **Every input style in one widget.** Drum wheel, calendar grid, and keyboard
  input, switchable by the user, from a single API. No competitor offers all
  three together.
- **The widest calendar support.** Gregorian, Hijri (Umm al-Qura), Chinese
  lunisolar, and Persian Solar Hijri (Jalali) out of the box, plus a pluggable
  `DrumCalendarSystem` for data backed committee calendars. The returned value
  is always a Gregorian `DateTime`.
- **Drop-in migration.** Named to mirror `showDatePicker`, `showTimePicker`,
  `CalendarDatePicker`, and `CupertinoDatePicker`, so you can often switch by
  renaming the widget and keep every extra option this package adds.
- **Material 3 theming** through a `ThemeExtension`, app wide or per instance.
- **A small footprint:** `intl` is the only runtime dependency, under the MIT
  license.

## The honest trade-offs

- **Adoption and maturity.** The established packages have far more downloads,
  more real world mileage, and larger issue histories. That is the main reason
  to prefer one of them today if broad community validation matters most to you.
- **Not a full calendar page.** If you want a scrolling month view as a screen's
  main content (the `table_calendar` use case), this package's event markers are
  a lighter feature, not a replacement for a dedicated calendar view.
- **Non-Gregorian ranges are far future predictive.** The lunar and lunisolar
  calendars are only as accurate as published astronomical data allows for dates
  far in the future, as is true of every implementation.

If a column here looks wrong for your version of a package, corrections are
welcome.
