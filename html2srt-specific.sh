#!/bin/bash

sub=$1

echo
echo "Sub file is $sub"
subfixed=$(echo $sub | sed -e 's/ /\\ /g' | sed -e "s/'/\\\'/g" | sed -e 's/'`echo -e "\x28"`'/\\'`echo -e "\x28"`'/g' | sed -e 's/'`echo -e "\x29"`'/\\'`echo -e "\x29"`'/g' | sed -e 's/\&/\\&/g')
echo $subfixed
echo "----------"


dir=${subfixed%/*}
echo "Directory: $dir"
filename=${subfixed##*/}
file=${filename%.*}
echo "Basename: $file"
echo "----------"

fullsubpath=$dir/$file.srt
echo "Sub file: $fullsubpath"
#subinfo=$(file -bi "$fullsubpath")
subinfo=$(file -bi "$sub")
echo "Sub info: $subinfo"
head "$sub" | grep -i sami > /dev/null
if [ $? == 0 ]; then
    echo "Sami sub: yes"
    sami=1
fi
echo "----------"

for videotype in {avi,m4v,mp4,mkv,wmv}; do
    video=${sub%.*}.$videotype
    videofixed=$(echo $video | sed -e 's/ /\\ /g' | sed -e "s/'/\\\'/g" | sed -e 's/'`echo -e "\x28"`'/\\'`echo -e "\x28"`'/g' | sed -e 's/'`echo -e "\x29"`'/\\'`echo -e "\x29"`'/g' | sed -e 's/\&/\\&/g')
    if [ -e "$video" ]; then
	echo "Video is: $videofixed"
	file -bi "$video"
	typefound=$videotype
    fi
done
echo "----------"

#if [ $sami == 1 ]; then
#    echo "Converting sub from sami to srt..."
#    video=${sub%.*}.$typefound
#    videofixed=$(echo $video | sed -e 's/ /\\ /g' | sed -e "s/'/\\\'/g" | sed -e 's/'`echo -e "\x28"`'/\\'`echo -e "\x28"`'/g' | sed -e 's/'`echo -e "\x29"`'/\\'`echo -e "\x29"`'/g' | sed -e 's/\&/\\&/g')
#    echo "subs2srt.sh $videofixed $subfixed"
#    subs2srt.sh $videofixed $subfixed
#echo "----------"
#fi

mv "$sub" "${sub%.*}.sami"
echo "Renamed sub to ${sub%.*}.sami"
echo "----------"

MOVIENAME="${sub%.*}.$typefound"
SUBSNAME="${sub%.*}.sami"

SRTNAME="${SUBSNAME%.*}.srt"

if [ "$SRTNAME" == "$SUBSNAME" ]; then
    SRTNAME="${SUBSNAME%.*}1.srt"
fi

echo "moviename: $MOVIENAME"
echo "subsname: $SUBSNAME"
echo "srtname: $SRTNAME"
echo "----------"

if [ ! -f "$MOVIENAME" ]; then
    echo "Movie not found"
    exit
fi
if [ ! -f "$SUBSNAME" ]; then
    echo "Movie not found"
    exit
fi

# detect framerate                                                                                                                                                                  

#FRAMERATE=`mplayer -vo null -ao null -identify -frames 0 "$MOVIENAME" |grep ID_VIDEO_FPS| sed "s/ID_VIDEO_FPS=//"`
#echo "mplayer framerate: $FRAMERATE"
FRAMERATE=$(mediainfo --Inform="Video;%FrameRate%" "$MOVIENAME")
echo "mediainfo framerate: $FRAMERATE"

# execute conversion                                                                                                                                                                
subs "$SUBSNAME" -r $FRAMERATE -c srt -o "$SRTNAME"
