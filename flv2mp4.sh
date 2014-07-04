#!/bin/bash

# scan through all the files
for FILE in *; do

#if file is flv
    if [ ${FILE: -3} == "flv" ]; then
        echo "Converting "$FILE"..."
        echo "-------------------------------------------------"

        FILENAME="${FILE%.*}"

# streamcopy to mp4
        ffmpeg -i "$FILE" -vcodec copy -acodec copy "$FILENAME.mp4"

# if new mp4 file is larger than 15M, rename old flv to flv.bak
	SIZE=$(stat -c %s "$FILENAME.mp4")
	if [ $SIZE -ge 15000000 ]; then
            mv "$FILE" "$FILE.bak"
	fi

	echo
        echo "-------------------------------------------------"
        echo
    fi
done

# deleting mp4 files smaller than 1k
find . -maxdepth 1 -type f -name "*.mp4" -size -1k -exec rm -vf {} \;
echo
