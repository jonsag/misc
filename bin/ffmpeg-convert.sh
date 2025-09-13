#!/bin/bash

INFILE=$1
OUTFILE=$2

if [ -z $1 ] || [ -z $2 ]; then
    echo
    echo "No infile or no outfile"
    echo "Quitting..."
    exit 1
fi

if [ -f $INFILE ]; then
    echo
    echo "Converting $INFILE"
else
    echo "File $INFILE does not exist."
    echo "Quitting..."
    exit 2
fi

SCALE='-1:720'

VIDEO_CODEC='libx265'
VIDEO_BITRATE='3000k'

AUDIO_SAMPLE_RATE='22050'
AUDIO_CODEC='aac'
AUDIO_BITRATE='96k'

X265_PARAMETERS_PASS_1='-an -f null /dev/null'
X265_PARAMETERS_PASS_2='-ac 1'

LOG_LEVEL='-loglevel quiet -stats'

echo "----------------------------------------------------------------------------------"
echo "Output file name: $OUTFILE"
echo
echo "Video codec: $VIDEO_CODEC"
echo "Video bitrate: $VIDEO_BITRATE"
echo
echo "Audio codec: $AUDIO_CODEC"
echo "Audio bitrate: $AUDIO_BITRATE"
echo "----------------------------------------------------------------------------------"

echo
read -p "Continue? (Y/n)" -n 1 -r
echo
if [[ $REPLY =~ ^[Nn]$ ]]; then
    echo "Quitting..."
    exit 0
fi

echo
echo "First pass..."
echo "----------------------------------------------------------------------------------"
echo
ffmpeg -y -i $INFILE -vf scale=$SCALE -c:v $VIDEO_CODEC -b:v $VIDEO_BITRATE -x265-params pass=1 $X265_PARAMETERS_PASS_1 $LOG_LEVEL


echo
echo "Second pass..."
echo "----------------------------------------------------------------------------------"
echo
ffmpeg -i $INFILE -vf scale=$SCALE -c:v $VIDEO_CODEC -b:v $VIDEO_BITRATE -x265-params pass=2 -ac 1 -ar $AUDIO_SAMPLE_RATE -c:a $AUDIO_CODEC -b:a $AUDIO_BITRATE $LOG_LEVEL $OUTFILE

echo
echo "Finished"
