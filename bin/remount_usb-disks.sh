#!/bin/bash

serviceName="nfs-kernel-server"
mountPoint="/home/jon/mnt/usb"

# colours
def='\033[39m'
red='\033[31m'
yel='\033[33m'
gre='\033[32m'

##### check if root
if [ "$EUID" -ne 0 ]; then
   echo -e $red"ERROR"$def":   Must be root\n         Exiting ..."
   exit 4
fi

# arguments
arg1=$1
arg2=$2
arg3=$3

if [ "$arg1" == "test" ] || [ "$arg2" == "test" ] || [ "$arg3" == "test" ]; then
    echo -e "\n"$yel"NOTE"$def":    Will run as test"$def
    test="true"
else
    test="false"
fi

#################### server
echo -e "\nStopping nfs server ...\n----------"

if systemctl is-active $serviceName --quiet; then
    echo -e $gre"OK"$def":      Service '"$serviceName"' is running"
    if [ $test == "true" ]; then
	echo -e $yel"NOTE"$def":    Running in test-mode\n         Will not stop service"
    else
	echo "         Stopping ..."
	service $serviceName stop	
	if systemctl is-active $serviceName --quiet; then
	    echo -e $red"ERROR"$def":   Did not manage to stop service\n         Exiting.."
	    exit 1
	else
	    echo -e $gre"OK"$def":      Stopped service successfully"
	fi
    fi
else
    echo -e $yel"WARNING"$def": Service '"$serviceName"' is not running\n         Will try to start service in the end"
fi

#################### disks
echo -e "\nChecking mounts ..."

for disk in "hg1" "io1" "sg1" "sg2" "wd1"; do
    echo -e "\nTesting $mountPoint/$disk ...\n----------"

    ##### check if device exist
    if [ -e /dev/$disk ]; then
	echo -e $gre"OK"$def":      Device '/dev/$disk' exists"
	##### check if device1 exists
	if [ -e /dev/$disk"1" ]; then
	    echo -e $gre"OK"$def":      Device '"$disk"1' exists"
	    ##### check if disk is mounted
	    if grep $mountPoint/$disk /etc/mtab > /dev/null 2>&1; then
		echo -e $gre"OK"$def":      $disk is mounted"
		##### check if disk is in use
		if lsof $mountPoint/$disk > /dev/null 2>&1; then
		    echo -e $yel"WARNING"$def": Disk is in use\n         Will not unmount"
		else
		    ##### unmount disk
		    if [ $test == "true" ]; then
			echo -e $yel"NOTE"$def":    Running in test-mode.\n         Will not unmount disk"
		    else
			umount $mountPoint/$disk
			##### check if unmount was successful
			if grep $mountPoint/$disk /etc/mtab > /dev/null 2>&1; then
			    echo -e "ERROR: Could not unmount disk\n       Exiting ..."
			    exit 2
			else
			    echo -e $gre"OK"$def":      Successfully unmounted"
			fi
		    fi
		fi
	    else
		echo -e $red"ERROR"$def":   $disk is not mounted"
	    fi
	    ##### mount disk
	    if grep $mountPoint/$disk /etc/mtab > /dev/null 2>&1; then
		echo -e $yel"WARNING"$def": Disk is already mounted\n         Will not mount"
	    else
		if [ $test == "true" ]; then
		    echo -e $yel"NOTE"$def":    Running in test-mode.\n         Will not mount disk"
		else
		    mount $mountPoint/$disk
		    ##### check if disk was successfully mounted
		    if grep $mountPoint/$disk /etc/mtab > /dev/null 2>&1; then
			echo -e $gre"OK"$def":      Successfully unmounted"
		    else
			echo -e "ERROR: Could not mount disk\n       Exiting ..."
			exit 3
		    fi
		fi
	    fi
	else
	    echo -e $red"ERROR"$def":   Device '"$disk"1' does not exist"
	fi
    else
	echo $red"ERROR"$def":   Device '$disk' does not exist"
    fi

done

#################### server
echo -e "\nChecking nfs server...\n----------"

if systemctl is-active $serviceName --quiet; then
    echo -e $gre"OK"$def":      Service '"$serviceName"' is running"
    if [ $test == "true" ]; then
	echo -e $yel"NOTE"$def":    Running in test-mode.\n         Will not restart service"
    else
	echo "         Restarting ..."
	service $serviceName restart
    fi
else
    echo -e $yel"WARNING"$def": Service '"$serviceName"' is not running"
    if [ $test == "true" ]; then
	echo -e $yel"NOTE"$def":    Running in test-mode.\n         Will not start service"
    else
	echo "         Starting ..."
	service $serviceName start
    fi
fi

if systemctl is-active $serviceName --quiet; then
    echo -e $gre"OK"$def":      Started successfully"
else
    echo -e $red"ERROR"$def":   Service did not start"
fi
