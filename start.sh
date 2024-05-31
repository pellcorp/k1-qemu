#!/bin/bash

if [ "$(whoami)" == "root" ]; then
  echo "Must not be run as root"
  exit 1
fi

# if we want to start from scratch
if [ "$1" = "-r" ]; then
    tar -xvf qemu.tar.gz
fi
sudo chown $USER image.qcow2 initrd.img vmlinux

# FIXME - I am not sure how to setup tab based networking :-(
# so just forward a bunch of the ports we need
NET_DEV="-device e1000,netdev=net"
NET_DEVICE="-netdev user,id=net,hostfwd=tcp::2222-:22,hostfwd=tcp::9999-:9999,hostfwd=tcp::4408-:4408,hostfwd=tcp::4409-:4409,hostfwd=tcp::9080-:80,hostfwd=tcp::7125-:7125"

# so far only -cpu 4KEc has worked for chroot of k1
sudo qemu-system-mipsel -machine malta -cpu 4KEc -m 2G -drive file=image.qcow2 -kernel vmlinux -initrd initrd.img $NET_DEV $NET_DEVICE -nographic -append "root=LABEL=rootfs console=ttyS0,115200"
