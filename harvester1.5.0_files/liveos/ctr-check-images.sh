#!/bin/bash -eu
# This file is a customized version of https://github.com/harvester/harvester-installer/blob/v1.5.0/package/harvester-os/files/usr/sbin/ctr-check-images.sh.
# The original version has been saved to ctr-check-images.sh.orig for convenience.
# The main changes are:
# - Remove the unnecessary unlimited wait logic

# The script reads a image list and waits until images in the list are presented.

sorted_list_file=$(mktemp)
sort $1 > $sorted_list_file

trap "rm -f $sorted_list_file" EXIT

lines=$(wc -l < $sorted_list_file)
echo Checking $lines images in $1...

    missing=$(ctr -n k8s.io images ls -q | grep -v ^sha256 | sort | comm -23 $sorted_list_file -)
    if [ -z "$missing" ]; then
        echo done
        exit
    fi

echo "Following images have not been imported:"
echo "$missing"
exit 1
