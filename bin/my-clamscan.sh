#!/bin/bash
LOGFILE="/var/log/clamav/clamav-$(date +'%Y-%m-%d').log";
EMAIL_MSG="Please see the log file attached.";
EMAIL_FROM="jon-clam@HP-Pavillion-15";
EMAIL_TO="jonsagebrand@gmail.com";
DIRTOSCAN="$HOME";

echo "Starting scan"

for S in ${DIRTOSCAN}; do
    echo "Calculating size of $S ..."
    DIRSIZE=$(du -sh "$S" 2>/dev/null | cut -f1);

    echo "Amount of data to be scanned is "$DIRSIZE".";

    clamscan -ri "$S" >> "$LOGFILE";

    # get the value of "Infected lines"
    MALWARE=$(tail "$LOGFILE"|grep Infected|cut -d" " -f3);

    # if the value is not equal to zero, send an email with the log file attached
    if [ "$MALWARE" -ne "0" ];then
	# using heirloom-mailx below
	echo "$EMAIL_MSG"|mail -a "$LOGFILE" -s "Malware Found" -r "$EMAIL_FROM" "$EMAIL_TO";
    fi 

done

exit 0
