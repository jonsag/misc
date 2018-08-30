#!/bin/bash

if [ -f videoPlaylist.m3u ]; then
	rm videoPlaylist.m3u
	echo "Deleted old playlist"
fi

for videoType in "asf" "avi" "flv" "mkv" "mp4" "mpeg" "mpg" "webm" "wmv"; do
	#echo $videoType
	find $PWD -iname "*.$videoType" >> videoPlaylist.m3u
done

videos=$(cat videoPlaylist.m3u | wc -l)

echo "Added $videos videofiles to videoPlaylist.m3u"
