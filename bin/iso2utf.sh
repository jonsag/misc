#!/bin/bash

TYPE=$1

for FILE in *; do
    if [ ${FILE: -4} == ".$TYPE" ]; then
	echo "Converting" $FILE "..."
	cp "$FILE" "$FILE.iso-8859-1"
	iconv --from-code=ISO-8859-1 --to-code=UTF-8 "$FILE" > "$FILE.bak"
	mv "$FILE.bak" "$FILE"
    fi
done
