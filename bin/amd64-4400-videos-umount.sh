#!/bin/bash

mountPoint="$HOME/mnt/amd64-4400"

echo
echo "Mount point: $mountPoint"

#for resource in "iomega1" "seagate1" "seagate2" "wd1" "SG"; do
for resource in "Archived 1" "Danskt" "Isländskt" "Movies 1" "Movies 2" "Music Shows" "Music Videos" "Norskt" "Series 1" "Series 2" "Streaming" "Svenskt" "Temp"; do
    echo
    echo "Unmounting $resource..."
    umount "$mountPoint/$resource"
done
