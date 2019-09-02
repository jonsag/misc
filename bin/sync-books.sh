#!/bin/bash

SERVER="192.168.10.6"

BOOKSDIR="/home/jon/Documents/CalibreLibrary"
GOOGLEDIR="/home/jon/GoogleDrive/CalibreLibrary"
SERVERPATH="/home/jon/mnt/usb/hg1/Calibre\ Library"
SERVERDIR="root@$SERVER:$SERVERPATH"

#OPTIONS="-avzh --progress --delete"
#EXCLUDE="--exclude metadata.db metadata_db_prefs_backup.json"

GOOGLEOPTIONS="-ruvzh --progress --delete"

GOOGLEINCLUDE="--include '*/'"
GOOGLEINCLUDE="$GOOGLEINCLUDE --include '*.epub'"
GOOGLEINCLUDE="$GOOGLEINCLUDE --include 'metadata.opf'"
GOOGLEINCLUDE="$GOOGLEINCLUDE --include 'cover.jpg'"

#GOOGLEEXCLUDE="--exclude=*"

GOOGLEEXCLUDE="--exclude '*'"
#GOOGLEEXCLUDE="--exclude=*.original_epub"
#GOOGLEEXCLUDE="$GOOGLEEXCLUDE --exclude=*.cbr"
#GOOGLEEXCLUDE="$GOOGLEEXCLUDE --exclude=*.cbz"
#GOOGLEEXCLUDE="$GOOGLEEXCLUDE --exclude=*.rtf"
#GOOGLEEXCLUDE="$GOOGLEEXCLUDE --exclude=*.pdf"
#GOOGLEEXCLUDE="$GOOGLEEXCLUDE --exclude=*.azw3"
#GOOGLEEXCLUDE="$GOOGLEEXCLUDE --exclude=*.lit"
#GOOGLEEXCLUDE="$GOOGLEEXCLUDE --exclude=*.mobi"
#GOOGLEEXCLUDE="$GOOGLEEXCLUDE --exclude=*.zip"

GOOGLEMAXSIZE="--max-size=10M"

SERVEROPTIONS="-pruvzh --progress --delete"
SERVEREXCLUDE=""
SERVERUSER="calibre"
SERVERGROUP="calibre"
#SERVERCHOWN="--chown=mythtv:users"
#SERVERUSERMAP="--usermap=jon:mythtv"
SERVERUSERMAP=""
#SERVERGOUPMAP="--groupmap=jon:users"
SERVERGOUPMAP=""
#SERVEREXCLUDE="--exclude·'*.original_epub'·'*.cbr'"

echo
echo "Syncing $BOOKSDIR with $GOOGLEDIR ..."
echo "----------------------------------------------------------------------------"
echo

echo "rsync $GOOGLEOPTIONS $GOOGLEINCLUDE $GOOGLEEXCLUDE $GOOGLEMAXSIZE $BOOKSDIR/* $GOOGLEDIR/"
#rsync $GOOGLEOPTIONS $GOOGLEINCLUDE $GOOGLEEXCLUDE $GOOGLEMAXSIZE "$BOOKSDIR"/* "$GOOGLEDIR"/

echo
echo "Syncing $BOOKSDIR with $SERVERDIR ..."
echo "----------------------------------------------------------------------------"
echo

echo "rsync $SERVEROPTIONS $SERVEREXCLUDE $SERVERCHOWN $SERVERUSERMAP $SERVERGROUPMAP $BOOKSDIR/* $SERVERDIR/"
rsync $SERVEROPTIONS $SERVEREXCLUDE $SERVERCHOWN $SERVERUSERMAP $SERVERGROUPMAP "$BOOKSDIR"/* "$SERVERDIR"/

echo
echo "Setting owner to $SERVERUSER and group to $SERVERGROUP for top .db-file..."
echo "ssh root@$SERVER  'chown $SERVERUSER:$SERVERGROUP $SERVERPATH/*.db'"
ssh root@$SERVER  'chown $SERVERUSER:$SERVERGROUP $SERVERPATH/*.db'
