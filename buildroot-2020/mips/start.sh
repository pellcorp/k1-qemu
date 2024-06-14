#!/bin/bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd -P)"

cd $CURRENT_DIR
qemu-system-mipsel -M malta -kernel vmlinux  -drive file=rootfs.ext2,format=raw -append "rootwait root=/dev/hda" -net nic,model=pcnet -net user -nographic
