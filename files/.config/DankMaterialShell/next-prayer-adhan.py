#!/usr/bin/env -S uv run --script --quiet

# -*- coding: utf-8 -*-
# pylint: disable=missing-docstring,invalid-name,line-too-long

# /// script
# requires-python = ">=3.9"
# dependencies = ["adhanpy"]
# ///

import os
import sys
from datetime import datetime, timedelta, timezone
from zoneinfo import ZoneInfo

from adhanpy.PrayerTimes import PrayerTimes
from adhanpy.calculation.CalculationMethod import CalculationMethod
from adhanpy.calculation.CalculationParameters import CalculationParameters
from adhanpy.calculation.HighLatitudeRule import HighLatitudeRule
from adhanpy.astronomy.SolarTime import SolarTime
from adhanpy.data.Coordinates import Coordinates
from adhanpy.util.DateComponents import DateComponents
from adhanpy.util.TimeComponents import TimeComponents

# city -> (latitude, longitude, timezone)
LOCATIONS = {
    "stockholm": (59.3293, 18.0686, "Europe/Stockholm"),
    "strangnas": (59.3773, 17.0303, "Europe/Stockholm"),
}

PRAYERS = ["Fajr", "Dhuhr", "Asr", "Maghrib", "Isha"]
METHOD = CalculationMethod.MUSLIM_WORLD_LEAGUE  # same as aladhan method 3
# angle-based high-latitude adjustment (aladhan's default) — without it,
# summer Fajr/Isha at Swedish latitudes land at absurd times like 00:54
PARAMS = CalculationParameters(method=METHOD)
PARAMS.high_latitude_rule = HighLatitudeRule.TWILIGHT_ANGLE

# current city persists here so the DMS widget can cycle it on click
STATE_FILE = os.path.join(
    os.environ.get("XDG_CACHE_HOME", os.path.expanduser("~/.cache")), "next-prayer-city"
)
CITIES = list(LOCATIONS)


def read_state():
    try:
        with open(STATE_FILE, encoding="utf8") as f:
            city = f.read().strip().lower()
            if city in LOCATIONS:
                return city
    except OSError:
        pass
    return CITIES[0]


ARG = (sys.argv[1] if len(sys.argv) > 1 else "").lower()

if ARG == "--toggle":
    current = read_state()
    with open(STATE_FILE, "w", encoding="utf8") as f:
        f.write(CITIES[(CITIES.index(current) + 1) % len(CITIES)])
    sys.exit(0)

CITY = ARG or read_state()

if CITY not in LOCATIONS:
    print(f"Unknown city: {CITY} (known: {', '.join(LOCATIONS)})")
    sys.exit(1)

latitude, longitude, tz_name = LOCATIONS[CITY]
ZONE = ZoneInfo(tz_name)


def maghrib_ceil(day):
    # adhanpy rounds Maghrib to the nearest minute, which can show a time before
    # actual sunset; use the raw solar sunset and ceil to the next whole minute.
    date = DateComponents.from_utc(day.astimezone(timezone.utc))
    solar = SolarTime(date, Coordinates(latitude, longitude))
    sunset = TimeComponents.from_float(solar.sunset).date_components(date).replace(tzinfo=timezone.utc).astimezone(ZONE)
    if sunset.second or sunset.microsecond:
        sunset += timedelta(minutes=1)
    return sunset.replace(second=0, microsecond=0)


def get_times(day):
    times = PrayerTimes((latitude, longitude), day, calculation_parameters=PARAMS, time_zone=ZONE)
    return {
        "Fajr": times.fajr,
        "Dhuhr": times.dhuhr,
        "Asr": times.asr,
        "Maghrib": maghrib_ceil(day),
        "Isha": times.isha,
    }


def get_prayer(now):
    timings = get_times(now)

    for prayer in PRAYERS:
        if timings[prayer] >= now:
            prayer_time = timings[prayer]
            break
    else:
        # past Isha: next prayer is tomorrow's Fajr
        prayer = "Fajr"
        prayer_time = get_times(now + timedelta(days=1))["Fajr"]

    return f"{CITY[:3].upper()} {prayer}: {prayer_time.strftime('%H:%M')}"


print(get_prayer(datetime.now(ZONE)), end="")
