#!/bin/bash

XY_COORDINATE_VALUE=$1

# $ xinput --list --short
# ...
# ↳ Logitech USB Receiver                   	id=18	[slave  pointer  (2)]
# ...

# $ xinput --list-props 18 (or $ xinput --list-props 'Logitech USB Receiver')
# ...
# libinput Accel Speed (333):	1.000000
# ...

# $ xinput --set-prop 18 333 1 (or $ xinput --set-prop 'Logitech USB Receiver' 'libinput Accel Speed' 1)

# $ xinput --list-props 18 | grep Coordinate (or $ xinput --list-props 'Logitech USB Receiver' ...)
# Coordinate Transformation Matrix (186):	1.000000, 0.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000, 0.000000, 1.000000

ACCEL_SPEED=1

if [ -z $XY_COORDINATE_VALUE ]; then
    XY_COORDINATE_VALUE=2.4
fi

echo
echo "$ xinput --set-prop 'Logitech USB Receiver' 'libinput Accel Speed' $ACCEL_SPEED"
xinput --set-prop 'Logitech USB Receiver' 'libinput Accel Speed' $ACCEL_SPEED
echo
echo "$ xinput --set-prop 'Logitech USB Receiver' 'Coordinate Transformation Matrix' $XY_COORDINATE_VALUE 0 0 0 $XY_COORDINATE_VALUE 0 0 0 1" 
xinput --set-prop 'Logitech USB Receiver' 'Coordinate Transformation Matrix' $XY_COORDINATE_VALUE 0 0 0 $XY_COORDINATE_VALUE 0 0 0 1 

echo
echo "----------------------------------"
echo

echo "$ xinput --list-props 'Logitech USB Receiver' | grep 'libinput Accel Speed'"
echo
xinput --list-props 'Logitech USB Receiver' | grep 'libinput Accel Speed ('

echo
echo "----------------------------------"
echo

echo "$ xinput --list-props 'Logitech USB Receiver' | grep 'Coordinate Transformation Matrix'"
echo
xinput --list-props 'Logitech USB Receiver' | grep 'Coordinate Transformation Matrix'
echo
