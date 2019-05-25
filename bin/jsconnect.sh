#!/bin/bash

# some initials checks

# check for configuration directory
if [ -d $HOME/.jsconnect ]; then
    echo "Directory $HOME/.jsconnect exists"
else
    mkdir $HOME/.jsconnect
fi

# set configuration and computers files
CONF=$HOME/.jsconnect/jsconnect.conf
COMPUTERS=$HOME/.jsconnect/jsconnect.computers
USERS=$HOME/.jsconnect/jsconnect.users

# check if configuration file exists
if [ -e $CONF ]; then
    echo "Configuration file $CONF exists"
else
    cp /etc/jsconnect/jsconnect.conf $CONF
fi

# read configuration
source $CONF

# check for computers file
if [ -e $COMPUTERS ]; then
    echo "Computers file $COMPUTERS exists"
else
    cp /etc/jsconnect/jsconnect.computers $COMPUTERS
fi

# check for users file
if [ -e $USERS ]; then
    echo "Users file $USERS exists"
else
    cp /etc/jsconnect/jsconnect.users $USERS
fi

# check for temporary directory
if [ -d $TEMPDIR ]; then
    echo "Temporary directory $TEMPDIR exists"
else
    mkdir $TEMPDIR
fi

# clean temporary directory
rm -f $TEMPDIR/jsconnect.* >> /dev/null

# read computers to temp file
gawk '$1 == "host" { print $2 }' $COMPUTERS >> $TEMPDIR/jsconnect.computers.tmp

# connect or transfer key
echo
echo "Connect or transfer key?"
echo "Type the number, then hit [Enter]"
echo
echo "1: Connect"
echo "2: Transfer key"
echo
echo -e "Your choice: \c"

# wait for user input
read CONNECT
echo

echo
echo "Enter the number of the host you wish to work with,"
echo "then press [Enter}!"
echo

# print the different computers with a number in front
for HOST in $( cat $TEMPDIR/jsconnect.computers.tmp ); do
    let HOSTNUMBER=$HOSTNUMBER+1
    echo $HOSTNUMBER: $HOST
    echo $HOSTNUMBER $HOST >> $TEMPDIR/jsconnect.computerslist.tmp
done

echo
echo -e "Your choice: \c"

# wait for user input
read CHOSENHOSTNUMBER
echo

CHOSENHOST=`gawk -v VAR=$CHOSENHOSTNUMBER '$1 == VAR { print $2 }' $TEMPDIR/jsconnect.computerslist.tmp`

ADDRESS=`gawk -v VAR=$CHOSENHOST '$2 == VAR { print $3 }' $COMPUTERS`

PORT=`gawk -v VAR=$CHOSENHOST '$2 == VAR { print $4 }' $COMPUTERS`

# read users to temp file
gawk -v VAR=$CHOSENHOST '$1 == VAR { print $2 }' $USERS >> $TEMPDIR/jsconnect.users.tmp

echo "Host $CHOSENHOST has the following users configured"
echo "Type the number, then hit [Enter]"
echo

# print the different users with a number in front
for USER in $( cat $TEMPDIR/jsconnect.users.tmp ); do
    let USERNUMBER=$USERNUMBER+1
    echo $USERNUMBER: $USER
    echo $USERNUMBER $USER >> $TEMPDIR/jsconnect.userslist.tmp
done

echo
echo -e "Your choice: \c"

# wait for user input
read CHOSENUSERNUMBER
echo

CHOSENUSER=`gawk -v VAR=$CHOSENUSERNUMBER '$1 == VAR { print $2 }' $TEMPDIR/jsconnect.userslist.tmp`

PASSWORD=`gawk -v VAR1=$CHOSENHOST -v VAR2=$CHOSENUSER '$1 == VAR1 && $2 == VAR2 { print $3 }' $USERS`

if [ $CONNECT == "2" ]; then
    if [ -e $HOME/.ssh/id_rsa.pub ]; then
	echo "Key $HOME/.ssh/id_rsa.pub exist"
    else
	echo "Key $HOME/.ssh/id_rsa.pub does not exist"
	echo "Creating it..."
	ssh-keygen
    fi

echo "Invoking ssh-copy-id -p $PORT -i $HOME/.ssh/id_rsa.pub $CHOSENUSER@$ADDRESS"
echo
echo "Use password $PASSWORD"
echo

ssh-copy-id "-p $PORT -i $HOME/.ssh/id_rsa.pub $CHOSENUSER@$ADDRESS"

exit
fi 

# type of connection
echo
echo "What type of connection would you like to make?"
echo "Type the number, then hit [Enter]"
echo
echo "1: ssh"
echo "2: ssh -X"
echo "3: ssh -Y"
echo "4: sftp"
echo
echo -e "Your choice: \c"

# wait for user input
read CONNECTIONTYPE
echo

echo
echo -e "You will be connected to $CHOSENHOST at $ADDRESS, \c"
#	resolveip $ADDRESS | gawk '{print $6}'
#	echo -e ", \c"
echo "on port $PORT as user $CHOSENUSER"
echo
resolveip $ADDRESS
echo
echo "Use password $PASSWORD"
echo

case $CONNECTIONTYPE in
    1)
	ssh $ADDRESS -p $PORT -l $CHOSENUSER
	;;
    2)
	ssh -X $ADDRESS -p $PORT -l $CHOSENUSER
	;;
    3)
	ssh -Y $ADDRESS -p $PORT -l $CHOSENUSER
	;;
    4)
	sftp -oPort=$PORT $CHOSENUSER@$ADDRESS
	;;
    *)
esac
