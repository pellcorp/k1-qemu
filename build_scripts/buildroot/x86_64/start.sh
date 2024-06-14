#!/bin/bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd -P)"
cd $CURRENT_DIR

NET_USER="user,id=net,hostfwd=tcp::2222-:22,hostfwd=tcp::9999-:9999,hostfwd=tcp::4408-:4408,hostfwd=tcp::4409-:4409,hostfwd=tcp::9080-:80,hostfwd=tcp::7125-:7125"

qemu-system-x86_64 -M pc -kernel bzImage -drive file=rootfs.ext2,if=virtio,format=raw -append "rootwait root=/dev/vda console=tty1 console=ttyS0" -net nic,model=virtio -net $NET_USER -nographic
