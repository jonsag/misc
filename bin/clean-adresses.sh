#!/bin/bash

FILE=$1
TIME=$(date +"%F-%H:%M:%S")
OUTFILE="Adresser_$TIME.vcard"
LASTENTRY="0"
ADDRESS=""
POSTCODE=""
POSTOFFICE=""
COUNTRYNAME=""
ERROR="no"

if [ -e $FILE.tmp ]; then
    rm $FILE.tmp
fi

# count lines in original file
echo "Original file line count:"
wc -l $FILE
echo

cp $FILE $FILE.bak

# remove every line that matches pattern
while read LINE; do
    echo "Removing lines containing " $LINE
    grep -v $LINE $FILE.bak > $FILE.tmp && mv $FILE.tmp $FILE.bak
done < $HOME/bin/matches
echo

# start up new vcard file
echo "Inserting vCard headers, and converting prefixes"
echo "BEGIN:VCARD" >> $FILE.tmp
echo "PROFILE:VCARD" >> $FILE.tmp
echo "VERSION:3.0" >> $FILE.tmp

# find out what number is in last column
while read LINE; do
    FOUND="no"
    ENTRY=$(echo $LINE | awk -F "\"*,\"*"  '{print $NF}')
    if [ $ENTRY != $LASTENTRY ]; then
        echo
        echo "Processing item no " $ENTRY
# check if we got any address
        if [ -z "$ADDRESS" ] && [ -z "$POSTCODE" ] && [ -z "$POSTOFFICE" ]; then
            NOADDRESS="yes"
        else
            if [ -z "$COUNTRYNAME" ]; then
                COUNTRYNAME="Sverige"
            fi
            echo "ADR:;;"$ADDRESS";"$POSTOFFICE";;"$POSTCODE";"$COUNTRYNAME >> $FILE.tmp
            ADDRESS=""
            POSTCODE=""
            POSTOFFICE=""
            COUNTRYNAME=""
        fi
        echo "END:VCARD" >> $FILE.tmp
        echo >> $FILE.tmp
        echo "BEGIN:VCARD" >> $FILE.tmp
        echo "PROFILE:VCARD" >> $FILE.tmp
        echo "VERSION:3.0" >> $FILE.tmp
    fi

# if line contains Name
    echo $LINE | grep '"Name"' > /dev/null
    if [ $? = 0 ]; then
#        echo "Line contains Name"
        echo $LINE | awk -F "\"*,\"*"  '{print "FN:" $2}' >> $FILE.tmp
        echo $LINE | awk -F "\"*,\"*"  '{print $2}' | awk '{print "N:" $2 ";" $1 ";;;"}' >> $FILE.tmp
        FOUND="yes"
    fi

# if line contains Telephone1
    echo $LINE | grep '"Telephone1"' > /dev/null
    if [ $? = 0 ]; then
#        echo "Line contains Telephone1"
        TELEPHONE1=$(echo $LINE | awk -F "\"*,\"*"  '{print $2}' | sed 's/[\ /._-]//g')
        if [[ $TELEPHONE1 == 070* ]] || [[ $TELEPHONE1 == 072* ]] || [[ $TELEPHONE1 == 073* ]] || [[ $TELEPHONE1 == 076* ]]; then
            TELEPHONE1=$(echo $TELEPHONE1 | sed 's/^.//')
            echo "TEL;TYPE=CELL:+46"$TELEPHONE1 >> $FILE.tmp
            FOUND="yes"
        else
            if [[ $TELEPHONE1 == +* ]]; then
                echo "TEL;TYPE=HOME:"$TELEPHONE1 >> $FILE.tmp
            elif [[ $TELEPHONE1 == 00* ]]; then
                TELEPHONE1=$(echo $TELEPHONE1 | sed 's/^..//')
                echo "TEL;TYPE=HOME:+"$TELEPHONE1 >> $FILE.tmp
            elif [[ $TELEPHONE1 == 0* ]]; then
                TELEPHONE1=$(echo $TELEPHONE1 | sed 's/^.//')
                echo "TEL;TYPE=HOME:+46"$TELEPHONE1 >> $FILE.tmp
            else
                echo "TEL;TYPE=HOME:+46155"$TELEPHONE1 >> $FILE.tmp
            fi
            FOUND="yes"
        fi
    fi

# if line contains Telephone2
    echo $LINE | grep '"Telephone2"' > /dev/null
    if [ $? = 0 ]; then
#        echo "Line contains Telephone2"
        TELEPHONE2=$(echo $LINE | awk -F "\"*,\"*"  '{print $2}' | sed 's/[\ /._-]//g')
        if [[ $TELEPHONE2 == 070* ]] || [[ $TELEPHONE2 == 072* ]] || [[ $TELEPHONE2 == 073* ]] || [[ $TELEPHONE2 == 076* ]]; then
            TELEPHONE2=$(echo $TELEPHONE2 | sed 's/^.//')
            echo "TEL;TYPE=CELL:+46"$TELEPHONE2 >> $FILE.tmp
            FOUND="yes"
        else
            if [[ $TELEPHONE2 == +* ]]; then
                echo "TEL;TYPE=WORK:"$TELEPHONE2 >> $FILE.tmp
            elif [[ $TELEPHONE2 == 00* ]]; then
                TELEPHONE2=$(echo $TELEPHONE2 | sed 's/^..//')
                echo "TEL;TYPE=WORK:+"$TELEPHONE2 >> $FILE.tmp
            elif [[ $TELEPHONE2 == 0* ]]; then
                TELEPHONE2=$(echo $TELEPHONE2 | sed 's/^.//')
                echo "TEL;TYPE=WORK:+46"$TELEPHONE2 >> $FILE.tmp
            else
                echo "TEL;TYPE=WORK:+46155"$TELEPHONE2 >> $FILE.tmp
            fi
            FOUND="yes"
        fi
    fi

# if line contains TeleFax
    echo $LINE | grep '"TeleFax"' > /dev/null
    if [ $? = 0 ]; then
#        echo "Line contains Telefax"
        TELEFAX=$(echo $LINE | awk -F "\"*,\"*"  '{print $2}' | sed 's/[\ /._-]//g')
        if [[ $TELEFAX == +* ]]; then
            echo "TEL;TYPE=FAX:"$TELEFAX >> $FILE.tmp
        elif [[ $TELEFAX == 00* ]]; then
            TELEFAX=$(echo $TELEFAX | sed 's/^..//')
            echo "TEL;TYPE=FAX:+"$TELEFAX >> $FILE.tmp
        elif [[ $TELEFAX == 0* ]]; then
            TELEFAX=$(echo $TELEFAX | sed 's/^.//')
            echo "TEL;TYPE=FAX:+46"$TELEFAX >> $FILE.tmp
        else
            echo "TEL;TYPE=FAX:+46155"$TELEFAX >> $FILE.tmp
        fi
        FOUND="yes"
    fi

# if line contains Email
    echo $LINE | grep '"Email"' > /dev/null
    if [ $? = 0 ]; then
#        echo "Line contains Email"
        echo $LINE | awk -F "\"*,\"*"  '{print "EMAIL;TYPE=INTERNET:" $2}' >> $FILE.tmp
        FOUND="yes"
    fi

# if line contains CompanyNo
    echo $LINE | grep '"CompanyNo"' > /dev/null
    if [ $? = 0 ]; then
#        echo "Line contains CompanyNo/birth date"
        BDAY=$(echo $LINE | awk -F "\"*,\"*"  '{print "19" substr($2, 0, length($2) -5)}')
        date -d $BDAY > /dev/null 2>&1
        if [ $? == 0 ]; then
            echo "BDAY:"$BDAY >> $FILE.tmp
        fi
            echo $LINE | awk -F "\"*,\"*"  '{print "NOTE:Org/Personnummer: " $2}' >> $FILE.tmp
        FOUND="yes"
    fi

# if line contains CustomerNo
    echo $LINE | grep '"CustomerNo"' > /dev/null
    if [ $? = 0 ]; then
#        echo "Line contains CustomerNo"
        echo $LINE | awk -F "\"*,\"*"  '{print "NOTE:Gamla kundnumret: " $2}' >> $FILE.tmp
        FOUND="yes"
    fi

# if line contains Address1
    echo $LINE | grep '"Address1"' > /dev/null
    if [ $? = 0 ]; then
#        echo "Line contains Address1"
        ADDRESS=$(echo $LINE | awk -F "\"*,\"*"  '{print $2}')
        FOUND="yes"
    fi

# if line contains PostCode
    echo $LINE | grep '"PostCode"' > /dev/null
    if [ $? = 0 ]; then
#        echo "Line contains PostCode"
        POSTCODE=$(echo $LINE | awk -F "\"*,\"*"  '{print $2}')
        FOUND="yes"
    fi

# if line contains PostOffice
    echo $LINE | grep '"PostOffice"' > /dev/null
    if [ $? = 0 ]; then
#        echo "Line contains PostOffice"
        POSTOFFICE=$(echo $LINE | awk -F "\"*,\"*"  '{print $2}')
        FOUND="yes"
    fi

# if line contains CountryName
    echo $LINE | grep '"CountryName"' > /dev/null
    if [ $? = 0 ]; then
#        echo "Line contains CountryName"
        COUNTRYNAME=$(echo $LINE | awk -F "\"*,\"*"  '{print $2}')
        FOUND="yes"
    fi

# if line contains Address2
    echo $LINE | grep '"Address2"' > /dev/null
    if [ $? = 0 ]; then
#        echo "Line contains Address2"
        echo $LINE | awk -F "\"*,\"*"  '{print "NOTE:Adress2: " $2}' >> $FILE.tmp
        FOUND="yes"
    fi

# if line contains Address3
    echo $LINE | grep '"Address3"' > /dev/null
    if [ $? = 0 ]; then
#        echo "Line contains Address2"
        echo $LINE | awk -F "\"*,\"*"  '{print "NOTE:Adress3: " $2}' >> $FILE.tmp
        FOUND="yes"
    fi

# if nothing above matched
    if [ $FOUND != "yes" ]; then
        echo $LINE | awk -F "\"*,\"*"  '{print "Line starting with " $1 " does not match any criteria"}'
        echo $LINE >> $FILE.tmp
        ERROR="yes"
    fi

    LASTENTRY=$ENTRY
done < $FILE.bak

echo "END:VCARD" >> $FILE.tmp

rm $FILE.bak
mv $FILE.tmp $OUTFILE
echo

if [ $ERROR == "yes" ]; then
    echo "There was an error finding matchings for all lines"
    echo
fi

echo "New file line count:"
wc -l $OUTFILE
