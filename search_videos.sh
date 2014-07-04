#!/bin/bash

name=$1

echo "Searching for $name"

find $HOME/SG/Video/ $HOME/iomega1 $HOME/seagate1 -type f -iname '*$name*' -exec ls -alFh {} \;
