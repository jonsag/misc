#!/bin/bash

vncserver -kill :1> /dev/null 2>&1; vncserver -geometry 1024x768 -dpi 75 -depth 16 -once -localhost :1> /dev/null 2>&1; \

# screen -DR
echo "* connect to server with $ vncviewer -compresslevel 9 -depth 8 -quality 0 localhost:5900"
/bin/bash

# echo "* you are operating in a screen ed environment.  ctrl+a d to detach"
vncserver -kill :1> /dev/null 2>&1
echo 'server is closed'
