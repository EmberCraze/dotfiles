#!/usr/bin/env python

# -*- coding: utf-8 -*-
# pylint: disable=missing-docstring,invalid-name,line-too-long

import json
import sys
import os
import io
import time
from datetime import datetime
from tempfile import gettempdir
from urllib.request import urlopen, Request
from urllib.error import HTTPError
from random import choice

CITY = sys.argv[1] if len(sys.argv) > 1 else "stockholm"
COUNTRY = sys.argv[2] if len(sys.argv) > 2 else "sweden"
TODAY_DATE = time.strftime("%d-%m-%Y", datetime.now().timetuple())
CACHE = os.path.join(gettempdir(), f".{CITY}-{COUNTRY}-{TODAY_DATE}.json")
RED = ""  # "#[fg=#ffa7c4]" if os.environ.get("TMUX") else "\033[1;31;40m"
PRAYERS = ["Fajr", "Dhuhr", "Asr", "Maghrib", "Isha"]

# https://aladhan.com/prayer-times-api#GetCalendarByCitys
METHOD = sys.argv[4] if len(sys.argv) > 4 else 3
AGENTS = [
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.113 Safari/537.36",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/35.0.1916.47 Safari/537.36",
    "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:54.0) Gecko/20100101 Firefox/54.0",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/601.7.7 (KHTML, like Gecko) Version/9.1.2 Safari/601.7.7",
    "Mozilla/5.0 (iPhone; CPU iPhone OS 11_0 like Mac OS X) AppleWebKit/604.1.38 (KHTML, like Gecko) Version/11.0 Mobile/15A372 Safari/604.1",
    "Mozilla",
]


def get_api():
    url = f"https://api.aladhan.com/v1/timingsByCity?city={CITY}&country={COUNTRY}"

    try:
        req = Request(url, data=None, headers={"User-Agent": choice(AGENTS)})
        with urlopen(req) as response:
            data = json.load(response)["data"]

            return {
                "timings": data["timings"],
                "readable_date": data["date"]["readable"],
            }
    except HTTPError as err:
        if err.code == 403:
            print(err)
        else:
            print("Something happened! Error code", err.code)
        return {}


def get_data():
    if os.path.isfile(CACHE) and os.access(CACHE, os.R_OK):
        with io.open(CACHE, encoding="utf8") as cache:
            return json.load(cache)
    else:
        data = get_api()
        with io.open(CACHE, "w", encoding="utf8") as cache:
            cache.write(json.dumps(data))

        return data


def get_prayer_time(prayer, readable_date, timings):
    return datetime.strptime(f"{readable_date} {timings[prayer]}", "%d %b %Y %H:%M")


def get_prayer(now):
    data = get_data()
    timings = data["timings"]
    readable_date = data["readable_date"]
    after_isha = get_prayer_time(PRAYERS[-1], readable_date, timings)

    if now > after_isha:
        fajr = PRAYERS[0]

        # result = "{prayer}: {time}".format(prayer=fajr, time=timings[fajr])
        result = f"{fajr}: {timings[fajr]}"
    else:
        for prayer in PRAYERS:
            prayer_time = get_prayer_time(prayer, readable_date, timings)

            if prayer_time >= now:
                now_timestamp = time.mktime(now.timetuple())
                prayer_time_timestamp = time.mktime(prayer_time.timetuple())
                time_remaning = int(prayer_time_timestamp - now_timestamp) / 60
                color = "" if time_remaning > 30 else RED

                result = f"{color}{CITY[:3].upper()} {prayer}: {timings[prayer]}"

                break

    return result


print(get_prayer(datetime.now()), end="")
