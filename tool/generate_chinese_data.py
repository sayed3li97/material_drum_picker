#!/usr/bin/env python3
"""Generates lib/src/calendar/chinese/chinese_data.dart from the BSD licensed
sxtwl astronomical engine (https://github.com/yuangu/sxtwl_cpp).

The output is a pure Dart table of computed astronomical facts (new moon based
month starts and lengths, and leap month placement) for lunar years 1900-2100.
No part of sxtwl is shipped; only the computed table is vendored, the same way
the Umm al-Qura Hijri table is generated. Run with:

    python3 tool/generate_chinese_data.py

Then validate (this script also self checks every day in range against sxtwl).
"""
import sxtwl

FIRST_YEAR = 1900
LAST_YEAR = 2100


def gregorian_to_jdn(year, month, day):
    a = (14 - month) // 12
    y = year + 4800 - a
    m = month + 12 * a - 3
    return (day + (153 * m + 2) // 5 + 365 * y + y // 4 - y // 100 + y // 400
            - 32045)


def months_of_lunar_year(year):
    """Returns the ordered months of lunar [year] as a list of dicts with
    keys: civil (1-12), leap (bool), start_jdn, length (29/30)."""
    months = []
    current = None
    # Lunar year `year` month 1 begins in late Jan/Feb of solar `year` and ends
    # before month 1 of `year+1` (late Jan/Feb of `year+1`). Scan a safe window.
    d = sxtwl.fromSolar(year, 1, 1)
    end = sxtwl.fromSolar(year + 1, 3, 1)
    while True:
        if d.getLunarYear() == year:
            key = (d.getLunarMonth(), bool(d.isLunarLeap()))
            jdn = gregorian_to_jdn(d.getSolarYear(), d.getSolarMonth(),
                                   d.getSolarDay())
            if current is None or current['key'] != key:
                current = {
                    'key': key,
                    'civil': d.getLunarMonth(),
                    'leap': bool(d.isLunarLeap()),
                    'start_jdn': jdn,
                    'length': 1,
                }
                months.append(current)
            else:
                current['length'] += 1
        # Stop once we have passed this lunar year.
        if (d.getSolarYear(), d.getSolarMonth(), d.getSolarDay()) == \
                (end.getSolarYear(), end.getSolarMonth(), end.getSolarDay()):
            break
        d = d.after(1)
    return months


def main():
    start_jdn = []
    codes = []
    for year in range(FIRST_YEAR, LAST_YEAR + 1):
        months = months_of_lunar_year(year)
        assert len(months) in (12, 13), (year, len(months))
        start_jdn.append(months[0]['start_jdn'])
        leap_index = 0
        for i, m in enumerate(months):
            if m['leap']:
                leap_index = i + 1  # 1-based sequence position
            assert m['length'] in (29, 30), (year, m)
        bits = 0
        for i, m in enumerate(months):
            if m['length'] == 30:
                bits |= (1 << i)
        codes.append((leap_index << 16) | bits)

    # Self check: reconstruct every day from the table and compare to sxtwl.
    _validate(start_jdn, codes)

    _emit(start_jdn, codes)
    print(f'Wrote {len(codes)} years ({FIRST_YEAR}-{LAST_YEAR}).')


def _months_in_year(code):
    return 13 if (code >> 16) else 12


def _length_of(code, index):  # index 1-based
    return 30 if (code & (1 << (index - 1))) else 29


def _validate(start_jdn, codes):
    checked = 0
    for yi, code in enumerate(codes):
        year = FIRST_YEAR + yi
        n = _months_in_year(code)
        jdn = start_jdn[yi]
        for index in range(1, n + 1):
            length = _length_of(code, index)
            for day in range(1, length + 1):
                d = sxtwl.fromSolar(*_jdn_to_greg(jdn))
                assert d.getLunarYear() == year, (year, index, day, jdn)
                assert d.getLunarDay() == day, (year, index, day,
                                                d.getLunarDay())
                checked += 1
                jdn += 1
    print(f'Validated {checked} days against sxtwl with no mismatch.')


def _jdn_to_greg(jdn):
    a = jdn + 32044
    b = (4 * a + 3) // 146097
    c = a - (146097 * b) // 4
    d = (4 * c + 3) // 1461
    e = c - (1461 * d) // 4
    m = (5 * e + 2) // 153
    day = e - (153 * m + 2) // 5 + 1
    month = m + 3 - 12 * (m // 10)
    year = 100 * b + d - 4800 + m // 10
    return (year, month, day)


def _emit(start_jdn, codes):
    def fmt(values):
        lines = []
        for i in range(0, len(values), 12):
            chunk = ', '.join(str(v) for v in values[i:i + 12])
            lines.append('  ' + chunk + ',')
        return '\n'.join(lines)

    out = f'''// GENERATED FILE. Do not edit by hand.
//
// Produced by tool/generate_chinese_data.py from the BSD licensed sxtwl
// astronomical engine. Holds computed new moon based month starts, month
// lengths, and leap month placement for the Chinese lunisolar calendar, lunar
// years {FIRST_YEAR}-{LAST_YEAR}. Only this computed table is vendored, never
// any part of sxtwl itself.
library;

/// The first lunar year covered by the table.
const int kChineseFirstYear = {FIRST_YEAR};

/// The last lunar year covered by the table.
const int kChineseLastYear = {LAST_YEAR};

/// Julian Day Number of month 1 day 1 for each lunar year, starting at
/// [kChineseFirstYear].
const List<int> kChineseYearStartJdn = <int>[
{fmt(start_jdn)}
];

/// Packed year data, one entry per lunar year starting at [kChineseFirstYear].
///
/// `(leapIndex << 16) | monthLengthBits` where:
/// * `leapIndex` is 0 when the year has no leap month, otherwise the 1-based
///   sequence position of the leap month (so the year has 13 months).
/// * bit `i` of `monthLengthBits` is set when the `(i + 1)`-th month has 30
///   days, and clear when it has 29.
const List<int> kChineseYearCode = <int>[
{fmt(codes)}
];
'''
    path = 'lib/src/calendar/chinese/chinese_data.dart'
    with open(path, 'w') as f:
        f.write(out)


if __name__ == '__main__':
    main()
