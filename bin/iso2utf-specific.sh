#!/bin/bash

FILE=$1
if [ -z "$FILE" ]; then
    echo "No file given"
    echo "Exiting"
    exit 1
fi

echo "Converting $FILE ..."
cp "$FILE" "$FILE.iso-8859-1"
iconv --from-code=ISO-8859-1 --to-code=UTF-8 "$FILE" > "$FILE.bak"
mv "$FILE.bak" "$FILE"
