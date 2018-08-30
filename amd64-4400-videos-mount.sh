#!/bin/bash

mountPoint="$HOME/mnt/amd64-4400"

echo
echo "Mount point: $mountPoint"

for resource in "iomega1" "seagate1" "wd1"; do 
    echo
    echo "Mounting $resource..."
    mount "$mountPoint/$resource"
done
