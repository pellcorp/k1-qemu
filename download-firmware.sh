#!/bin/bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd -P)"

# if you look hard enough you can find the password on the interwebs in a certain discord
password="$(cat ~/.k1/firmware.passwd)"
version=1.3.3.8

if [ -z "$password" ]; then
    echo "Creality K1 firmware password missing - should be in ~/.k1/firmware.passwd!!!"
    exit 1
fi

download=$(wget -q https://www.creality.com/pages/download-k1-flagship -O- | grep -o  "\"\(.*\)V${version}.img\"" | head -1 | tr -d '"')
filename=$(basename $download)
directory=$(echo $filename | sed 's/\.img//g')
sub_directory="ota_v${version}"

if [ ! -f /tmp/$filename ]; then
    echo "Downloading $download -> /tmp/$filename ..."
    wget "$download" -O /tmp/$filename
fi

if [ -d /tmp/$filename ]; then
    rm -rf /tmp/$filename
fi

7z x /tmp/$filename -p"$password" -o/tmp
cat /tmp/$directory/$sub_directory/rootfs.squashfs.* > $CURRENT_DIR/rootfs.squashfs
rm -rf /tmp/$directory
