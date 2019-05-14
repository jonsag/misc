modify mouse/cursor speed

find mouse id
# xinput list

list properties for id
# xinput list-props 9

set Device Accel Constant Deceleration
# xinput set-prop 9 285 0.5
or
# xinput --set-prop 9 'Device Accel Constant Deceleration' 0.5
or
# xinput --set-prop 'Logitech USB Receiver' 'Device Accel Constant Deceleration' 0.5
