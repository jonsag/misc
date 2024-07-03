#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# Encoding: UTF-8


import os
import re
import sys

from tabulate import tabulate

path = os.getcwd()


def longest_item(list):
    max_len = 0

    for item in list:
        # print("%s: %s" % (item[0], len(item[0])))
        if len(item[0]) > max_len:
            max_len = len(item[0])

    return max_len


print("\nCurrent path: '%s'" % path)

############################### delete hyphens ###############################
dirs = []

print("\nFirst delete hyphen (-) at the end.")
print("-----------------------")

for item in os.listdir(path):
    if os.path.isdir(os.path.join(path, item)):
        if item.endswith("-"):
            dirs.append((item, "->", item[:-1]))

if len(dirs) != 0:
    print("Affected directories:")
    dirs.sort()

    headers = ["Old", "", "New"]
    print(tabulate(dirs, tablefmt="plain"))

    while True:
        inp = input("\nGo ahead and rename? (Y/n/q)")

        if inp == "" or inp.lower() == "y":
            print("Renaming %s directories..." % len(dirs))
            for item in dirs:
                if os.path.exists(os.path.join(path, item[2])):
                    print("\tSkipping '%s' %s '%s'." %
                          (item[0], item[1], item[2]))
                else:
                    os.rename(os.path.join(
                        path, item[0]), os.path.join(path, item[2]))

            break
        elif inp.lower() == "q":
            print("Quitting...")
            sys.exit(0)
        elif inp.lower() == "n":
            print("Nothing was renamed")
            break

        print("Only y (yes), n (no) and q (quit) is allowed. \nTry again!")

else:
    print("No matching directories found")

############################### delete hyphens with trailing numbers ###############################
dirs = []

print("\nSecond, delete hyphen with trailing numbers (-XX or -XXXX).")
print("-----------------------")

for item in os.listdir(path):
    if os.path.isdir(os.path.join(path, item)):
        # m = re.search(r'\-\d\d$', item)
        if re.search(r'\-\d\d$', item):
            dirs.append((item, "->", item[:-3]))
        elif re.search(r'\-\d\d\d\d$', item):
            dirs.append((item, "->", item[:-5]))
            
if len(dirs) != 0:
    print("Affected directories:")
    dirs.sort()

    headers = ["Old", "", "New"]
    print(tabulate(dirs, tablefmt="plain"))

    while True:
        inp = input("\nGo ahead and rename? (Y/n/q)")

        if inp == "" or inp.lower() == "y":
            print("Renaming %s directories..." % len(dirs))
            for item in dirs:
                if os.path.exists(os.path.join(path, item[2])):
                    print("\tSkipping '%s' %s '%s'." %
                          (item[0], item[1], item[2]))
                else:
                    os.rename(os.path.join(
                        path, item[0]), os.path.join(path, item[2]))
            break
        elif inp.lower() == "q":
            print("Quitting...")
            sys.exit(0)
        elif inp.lower() == "n":
            print("Nothing was renamed")
            break

        print("Only y (yes), n (no) and q (quit) is allowed. \nTry again!")

else:
    print("No matching directories found")

############################### add brackets around start year ###############################
dirs = []

print("\nThird, add parentheses, (), around trailing year.")
print("-----------------------")

for item in os.listdir(path):
    if os.path.isdir(os.path.join(path, item)):
        year = re.search(r'\ \d\d\d\d$', item)
        if year:
            dirs.append((item, "->", "%s (%s)" %
                        (item[:-5], (year.group()).lstrip(" "))))

if len(dirs) != 0:
    print("Affected directories:")
    dirs.sort()

    headers = ["Old", "", "New"]
    print(tabulate(dirs, tablefmt="plain"))

    while True:
        inp = input("\nGo ahead and rename? (Y/n/q)")

        if inp == "" or inp.lower() == "y":
            print("Renaming %s directories..." % len(dirs))
            for item in dirs:
                if os.path.exists(os.path.join(path, item[2])):
                    print("\tSkipping '%s' %s '%s'." %
                          (item[0], item[1], item[2]))
                else:
                    os.rename(os.path.join(
                        path, item[0]), os.path.join(path, item[2]))
            break
        elif inp.lower() == "q":
            print("Quitting...")
            sys.exit(0)
        elif inp.lower() == "n":
            print("Nothing was renamed")
            break

        print("Only y (yes), n (no) and q (quit) is allowed. \nTry again!")

else:
    print("No matching directories found")
