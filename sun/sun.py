#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# Encoding: UTF-8

import matplotlib.pyplot as plt

import numpy as np

from datetime import date, timedelta, datetime

from dateutil import tz

from calendar import isleap

# from pytz import timezone

import suncalc

# https://pypi.org/project/suncalc/
# https://github.com/kylebarron/suncalc-py


def get_seconds(time_str):
    # print('Time in hh:mm:ss:', time_str)
    # split in hh, mm, ss
    hh, mm, ss = time_str.split(':')
    return int(hh) * 3600 + int(mm) * 60 + int(ss)


latitude = 58.74655
longitude = 16.91114

start_year = "2023"

time_zone = 'Europe/Stockholm'

from_zone = tz.gettz('UTC')
to_zone = tz.gettz(time_zone)


start_date = "%s-01-01" % start_year

start_time = datetime.strptime(start_date, "%Y-%m-%d")


if isleap(int(start_year)):
    days = 366
else:
    days = 365

data = [dict() for x in range(days)]

for day in range(days):
    new_day = start_time + timedelta(days=day)

    times = suncalc.get_times(new_day, longitude, latitude)

    sunrise = times['sunrise']
    sunrise = sunrise.replace(tzinfo=from_zone)
    sunrise_local = sunrise.astimezone(to_zone)

    solar_noon = times['solar_noon']
    solar_noon = solar_noon.replace(tzinfo=from_zone)
    solar_noon_local = solar_noon.astimezone(to_zone)

    sunset = times['sunset']
    sunset = sunset.replace(tzinfo=from_zone)
    sunset_local = sunset.astimezone(to_zone)

    '''print("Day no: %s \t Date: %s \t Sunrise: %s \t Solar noon: %s \t Sunset: %s" % (
        day + 1,
        new_day.strftime("%Y-%m-%d"),
        sunrise_local.strftime("%H:%M:%S"),
        solar_noon_local.strftime("%H:%M:%S"),
        sunset_local.strftime("%H:%M:%S")
    ))'''

    data[day] = {'day': new_day, 'sunrise': sunrise_local,
                 'solar_noon': solar_noon_local, 'sunset': sunset_local}


for i in range(days):

    # print(data[day])

    print("Day no: %s \t Date: %s \t Sunrise: %s \t Solar noon: %s \t Sunset: %s \t Length: %s" % (
        i + 1,
        data[i]['day'].strftime("%Y-%m-%d"),
        data[i]['sunrise'].strftime("%H:%M:%S"),
        data[i]['solar_noon'].strftime("%H:%M:%S"),
        data[i]['sunset'].strftime("%H:%M:%S"),
        (data[i]['sunset'] - data[i]['sunrise']).seconds / 60
    ))

day_x = []
sunrise_y = []
sunset_y = []
length_y = []

for j in range(days):
    day_x.append(data[j]['day'].strftime("%Y-%m-%d"))

    sunrise_y.append(get_seconds(
        data[j]['sunrise'].strftime("%H:%M:%S")) / 60 / 60)
    sunset_y.append(get_seconds(
        data[j]['sunset'].strftime("%H:%M:%S")) / 60 / 60)

    length_y.append((data[j]['sunset'] - data[j]['sunrise']).seconds / 60 / 60)

    '''sunrise_y.append(data[j]['sunrise'].strftime("%H:%M:%S"))
    sunset_y.append(data[j]['sunset'].strftime("%H:%M:%S"))

    length_y.append((data[j]['sunset'] - data[j]['sunrise']))'''

'''plt.plot(sunrise_y, label="Sunrise")
plt.plot(sunset_y, label="Sunset")
plt.plot(length_y, label="Day length, hours")

plt.legend()'''

# r = np.arange(0, 2, 0.01) # (<start value>, <end value>, <step>)
r = np.arange(0, days - 1, 1)  # (<start value>, <end value>, <step>)
# theta = 2 * np.pi * r

# fig, ax = plt.subplots(subplot_kw={'projection': 'polar'})

theta = list(range(0, days))
theta = [i * 2 * np.pi / days for i in theta]
# radii=np.random.rand(366)

fig = plt.figure(figsize=(10, 8), facecolor="lightgrey")

ax = plt.subplot(111, projection='polar')

ax.set_theta_zero_location('N')
lines, labels = plt.thetagrids((0, 30, 60, 90, 120, 150, 180, 210, 240, 270, 300, 330), labels=(
    'Jan', 'Feb', 'Mar', 'Apr', 'Mai', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'), fmt=None)

ax.plot(theta, length_y, label="Day length")
ax.plot(theta, sunrise_y, color="green", label="Sunrise")
ax.plot(theta, sunset_y, color="orange", label="Sunset")

ax.set_rmax(24)
ax.grid(True)

ax.set_title("Sun in %s @N%s, E%s" %
             (start_year, latitude, longitude), va='bottom')

ax.set_facecolor("grey")

angle = np.deg2rad(67.5)
ax.legend(loc="lower left",
          bbox_to_anchor=(0.7 + np.cos(angle)/2, .5 + np.sin(angle)/2))

plt.show()
