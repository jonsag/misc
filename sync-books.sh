#!/bin/bash

BOOKSDIR="/home/jon/Calibre Library"
GOOGLEDIR="/home/jon/googledrive/Calibre Library"
SERVERDIR="root@amd64-4400:/home/mythtv/Calibre\ Library"

#OPTIONS="-avzh --progress --delete"
#EXCLUDE="--exclude metadata.db metadata_db_prefs_backup.json"

GOOGLEOPTIONS="-ruvzh --progress --delete"
GOOGLEEXCLUDE=""
GOOGLEEXCLUDE="--exclude=*.original_epub"
GOOGLEEXCLUDE="$GOOGLEEXCLUDE --exclude=*.cbr"
GOOGLEEXCLUDE="$GOOGLEEXCLUDE --exclude=*.cbz"
GOOGLEEXCLUDE="$GOOGLEEXCLUDE --exclude=*.rtf"
GOOGLEEXCLUDE="$GOOGLEEXCLUDE --exclude=*.pdf"
GOOGLEMAXSIZE="--max-size=10M"

SERVEROPTIONS="-pruvzh --progress --delete"
SERVEREXCLUDE=""
SERVERUSER="mythtv"
SERVERGROUP="users"
#SERVERCHOWN="--chown=mythtv:users"
#SERVERUSERMAP="--usermap=jon:mythtv"
SERVERUSERMAP=""
#SERVERGOUPMAP="--groupmap=jon:users"
SERVERGOUPMAP=""
#SERVEREXCLUDE="--exclude·'*.original_epub'·'*.cbr'"

#echo
#echo "Syncing $BOOKSDIR with $GOOGLEDIR ..."
#echo "----------------------------------------------------------------------------"
#echo

#echo "rsync $GOOGLEOPTIONS $GOOGLEEXCLUDE $GOOGLEMAXSIZE $BOOKSDIR/* $GOOGLEDIR/"
#rsync $GOOGLEOPTIONS $GOOGLEEXCLUDE $GOOGLEMAXSIZE "$BOOKSDIR"/* "$GOOGLEDIR"/

echo
echo "Syncing $BOOKSDIR with $SERVERDIR ..."
echo "----------------------------------------------------------------------------"
echo

echo "rsync $SERVEROPTIONS $SERVEREXCLUDE $SERVERCHOWN $SERVERUSERMAP $SERVERGROUPMAP $BOOKSDIR/* $SERVERDIR/"
rsync $SERVEROPTIONS $SERVEREXCLUDE $SERVERCHOWN $SERVERUSERMAP $SERVERGROUPMAP "$BOOKSDIR"/* "$SERVERDIR"/

echo
echo "Setting owner to $SERVERUSER and group to $SERVERGROUP for top .db-file..."
ssh root@amd64-4400  'chown $SERVERUSER:$SERVERGROUP /home/mythtv/Calibre\ Library/*.db'
