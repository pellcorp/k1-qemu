#!/bin/bash

# fixme - replace ifconfig with ip???
#sudo brctl addbr virbr0
#sudo ifconfig virbr0 192.168.5.1/24 up
#sudo ip tuntap add dev tap0 mode tap dev tap0
#sudo ifconfig tap0 192.168.5.11/24 up
#sudo brctl addif virbr0 tap0
 
sudo chown $USER image.qcow2 initrd.img vmlinux

# FIXME - I am not sure how to setup tab based networking :-(
# so just forward a bunch of the ports we need
NET_DEV="-device e1000,netdev=net"
NET_DEVICE="-netdev user,id=net,hostfwd=tcp::2222-:22,hostfwd=tcp::9999-:9999,hostfwd=tcp::4408-:4408,hostfwd=tcp::4407-:4407,hostfwd=tcp::8080-:80"

#NET_DEV="-netdev tap,id=tapnet,ifname=tap0,script=no"
#NET_DEVICE="-device e1000,netdev=tapnet"

qemu-system-mipsel -machine malta -cpu 4KEc -m 1G -drive file=image.qcow2  -kernel vmlinux -initrd initrd.img $NET_DEV $NET_DEVICE -nographic -append "root=LABEL=rootfs console=ttyS0"

