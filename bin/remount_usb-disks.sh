#!/bin/bash

serviceName="nfs-kernel-server"
mountPoint="/home/jon/mnt/usb"

arg1=$1
arg2=$2
arg3=$3

##### check if root
if [ "$EUID" -ne 0 ]; then
   echo -e %"ERROR: Must be root\n       Exiting ..."
   exit 4
fi

if [ $arg1 = "test" ] || [ $arg2 = "test" ] || [ $arg3 = "test" ]; then
    echo "Will run as test"
    test="true"
else
    test="false"
fi

exit

#################### server
echo
echo "Stopping nfs server..."
echo "----------"

if systemctl is-active $serviceName --quiet; then
    echo "Service '"$serviceName"' is running"
    if [ $test = "true" ]; then
	echo -e "--- Running in test-mode.\n    Will not stop service"
    else
	echo "Stopping ..."
	service $serviceName stop	
	if systemctl is-active $serviceName --quiet; then
	    echo -e "ERROR: Did not manage to stop service\n       Exiting.."
	    exit 1
	else
	    echo "Sopped service successfully"
	fi
    fi
else
    echo -e "WARNING: Service '"$serviceName"' is not running\n         Will try to start service in the end"
fi

#################### disks
echo
echo "Checking mounts ..."

for disk in "hg1" "io1" "sg1" "sg2" "wd1"; do
    echo
    echo "Testing $mountPoint/$disk ..."
    echo "----------"

    ##### check if device exist
    if [ -e /dev/$disk ]; then
	echo "Device '$disk' exists"
	##### check if device1 exists
	if [ -e /dev/$disk"1" ]; then
	    echo "Device '"$disk"1' exists"
	    ##### check if disk is mounted
	    if grep $mountPoint/$disk /etc/mtab > /dev/null 2>&1; then
		echo "$disk is mounted"
		##### unmount disk
		if [ $test = "true" ]; then
		    echo -e "--- Running in test-mode.\n    Will not unmount disk"
		else
		    umount $mountPoint/$disk
		    ##### check if unmount was successful
		    if grep $mountPoint/$disk /etc/mtab > /dev/null 2>&1; then
			echo -e "ERROR: Could not unmount disk\n       Exiting ..."
			exit 2
		    else
			echo "Successfully unmounted"
		    fi
		fi
	    else
		echo "ERROR: $disk is not mounted"
	    fi
	    ##### mount disk
	    if [ $test = "true" ]; then
		echo -e "--- Running in test-mode.\n    Will not mount disk"
	    else
		mount $mountPoint/$disk
		##### check if disk was successfully mounted
		if grep $mountPoint/$disk /etc/mtab > /dev/null 2>&1; then
		    echo "Successfully unmounted"
		else
		    echo -e "ERROR: Could not mount disk\n       Exiting ..."
		    exit 3
		fi
	    fi
	else
	    echo "ERROR: Device '"$disk"1' does not exist"
	fi
    else
	echo "ERROR: Device '$disk' does not exist"
    fi

done

#################### server
echo
echo "Checking nfs server..."
echo "----------"

if systemctl is-active $serviceName --quiet; then
    echo "Service '"$serviceName"' is running"
    if [ $test = "true" ]; then
	echo -e "--- Running in test-mode.\n    Will not restart service"
    else
	echo "Restarting ..."
	service $serviceName restart
    fi
else
    echo "WARNING: Service '"$serviceName"' is not running"
    if [ $test = "true" ]; then
	echo -e "--- Running in test-mode.\n    Will not start service"
    else
	echo "Starting ..."
	service $serviceName start
    fi
fi

if systemctl is-active $serviceName --quiet; then
    echo "Started successfully"
else
    echo "ERROR: Service did not start"
fi
