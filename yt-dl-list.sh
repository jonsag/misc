#!/bin/bash

list=$1

regex='(https?|ftp|file)://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]'

line=0

echo

if [ -z $list ]; then
    echo "No file supplied"
    exit 1
fi

echo "Parsing $list..."
echo
echo

# (while read URL NAME; do [ "$URL" ] && youtube-dl -o "$NAME.%(episode)s.%(ext)s" "$URL"; done) < data.txt

while read URL NAME; do
    #let "$line+=1"

    if [ $URL != "" ]; then
    	if [[ ! $URL =~ ^\# ]] ; then
			line=$((line + 1))
			if [[ $URL =~ $regex ]]; then
			    echo
			    echo -e "Line: $line \n------------------------------"
			    echo -e "URL: $URL"
			    echo -e "Name: $NAME"
			    echo
			    [ "$URL" ] && youtube-dl -o "$NAME.%(episode)s.%(ext)s" "$URL"
			else
			    echo -e "$URL \nis not a valid URL"
			    exit 2
			fi
		else
			echo -e "\nSkipping comment line\n"
        fi	
    fi
done < $list
