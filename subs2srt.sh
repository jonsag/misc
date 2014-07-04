#!/bin/bash

# converts subtitles to "srt" format
# uses: mplayer to detect movie framerate
#       subs (from Subtitles perl swiss army knife: http://karasik.eu.org/software/)

echo "subs2srt by l0co@wp.pl"

if [ ! "$#" = "2" ]; then
    if [ ! "$#" = "1" ]; then
        echo Usage: subs2srt.sh MOVIENAME SUBSNAME
        exit
    fi
    MOVIENAME=$1
    SUBSNAME="${MOVIENAME%.*}.txt"
else
    MOVIENAME=$1
    SUBSNAME=$2
fi

SRTNAME="${SUBSNAME%.*}.srt"

if [ "$SRTNAME" == "$SUBSNAME" ]; then
    SRTNAME="${SUBSNAME%.*}1.srt"
fi

echo "moviename: $MOVIENAME"
echo "subsname: $SUBSNAME"
echo "srtname: $SRTNAME"

if [ ! -f $MOVIENAME ]; then
    echo "Movie not found"
    exit
fi
if [ ! -f $SUBSNAME ]; then
    echo "Movie not found"
    exit
fi

# detect framerate

FRAMERATE=`mplayer -vo null -ao null -identify -frames 0 $MOVIENAME |grep ID_VIDEO_FPS| sed "s/ID_VIDEO_FPS=//"`
echo "framerate: $FRAMERATE"

# execute conversion
subs $SUBSNAME -r $FRAMERATE -c srt -o $SRTNAME
