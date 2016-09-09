#!/bin/bash

INFILE=$1

avconv·-i·$INFILE·-c:v·libx264·-crf·19·-c:a·copy·-strict·experimental·$INFILE.mp4

#ffmpeg -i $INFILE -c:v libx264 -crf 19 -c:a copy -strict experimental $INFILE.mp4
