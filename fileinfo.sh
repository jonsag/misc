#!/bin/bash

time=$(date +%g%m%d-%H%M%S)
convertToUTFsrt=convertToUTFsrt_$time.sh
removeBlanks=removeBlankssrt_$time.sh
log=fileinfo_$time.log

errors=0
isos=0
asciis=0
htmls=0

path=$1
if [ -z "$path" ]; then
    echo "No path given"
    echo "Usage: fileinfo.sh [path] [extension]"
    echo "Exiting..."
    exit 1
fi

extension=$2
if [ -z "$extension" ]; then
    echo "No extension given"
    echo "Usage: fileinfo.sh [path] [extension]"
    echo "Exiting..."
    exit 2
fi

echo "#!/bin/bash" > $convertToUTFsrt
echo "#!/bin/bash" > $removeBlanks
echo "Erroneously coded files:" > $log

echo
echo "Searching $PWD/$path for files with $extension extension"
echo

while read -rd $'\0' file; do
    echo "----------"
    file=$(echo $file | sed -e 's/\/.\//\//g')
    printf "%s$file\n"
    
    newfile=$(echo $file | sed -e 's/ /\\ /g' | sed -e "s/'/\\\'/g" | sed -e 's/'`echo -e "\x28"`'/\\'`echo -e "\x28"`'/g' | sed -e 's/'`echo -e "\x29"`'/\\'`echo -e "\x29"`'/g' | sed -e 's/\&/\\&/g')
    
    info=$(file -bi "$file")
    if [ $? = 0 ]; then
	echo $info
	
####################### iso-8859-1
	echo "$info" | grep -i iso-8859-1 > /dev/null
	if [ $? == 0 ]; then
	    errors=$(expr $errors + 1)
	    isos=$(expr $isos + 1)
	    
	    echo "This file is coded in iso-8859-1"
	    echo "iso2utf-specific.sh $newfile" >> $convertToUTFsrt
	    
	    echo "----------" >> $log
	    echo $file >> $log
	    echo "coded in iso-8859-1" >> $log
	    echo "----------" >> $log
	    echo >> $log
	fi

####################### us-ascii
	echo "$info" | grep -i us-ascii > /dev/null
	if [ $? == 0 ]; then
            errors=$(expr $errors + 1)
	    asciis=$(expr $asciis + 1)
	    
            echo "This file is coded in us-ascii"
            echo "#ascii2utf-specific.sh $newfile" >> $convertToUTFsrt
	    
            echo "----------" >> $log
            echo $file >> $log
            echo "coded in us-ascii" >> $log
            echo "----------" >> $log
            echo >> $log
	fi

####################### html
	echo "$info" | grep -i html > /dev/null
	if [ $? == 0 ]; then
	    errors=$(expr $errors + 1)
	    htmls=$(expr $htmls + 1)
	    
	    echo "This file is a html file"
	    echo "html2srt-specific.sh $newfile" >> $convertToUTFsrt
            echo "----------" >> $log
            echo $file >> $log
            echo "html file" >> $log

	    head "$file" | grep -i sami > /dev/null
	    if [ $? == 0 ]; then
		echo "and is probably a SAMI subtitle file"
		echo "and is probably a SAMI subtitle file" >> $log
	    fi
	    
            echo "----------" >> $log
            echo >> $log
	fi
	
	echo "----------"
	echo
    else
	echo "******************************** Error getting file info"
	echo
    fi

####################### &nbsp;

cat "$file" | grep -Fx '&nbsp;' > /dev/null
if [ $? == 0 ]; then
    errors=$(expr $errors + 1)
    blanks=$(expr $blanks + 1)

    echo "----------"
    printf "%s$file\n"
    echo "contains blank lines"
    echo "----------"

    echo "remove_blanks-specific.sh $newfile" >> $removeBlanks
    echo "----------" >> $log
    echo $file >> $log
    echo "blank lines" >> $log
    echo "----------" >> $log
    echo >> $log
fi
echo

done < <(find "$PWD/$path" -type f -name "*.$extension" -print0)

if [ $errors -gt 0 ]; then
    echo "There were $errors errors:"
    echo "iso-8859-1:  $isos"
    echo "us-ascii:    $asciis"
    echo "html:        $htmls"
    echo "blank lines: $blanks"
    echo
    echo "Logfile is at $log"
    echo "./$convertToUTFsrt to correct coding"
    echo "./$removeBlanks to remove blank lines"
    chmod +x $convertToUTFsrt
    chmod +x $removeBlanks
else
    echo "No errors found"
    rm $log
    rm $convertToUTFsrt
    em $removeBlanks
fi
