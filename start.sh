#!/bin/bash

#set network
#sudo brctl addbr virbr0
#sudo ifconfig virbr0 192.168.5.1/24 up
#sudo ip tuntap add dev tap0 mode tap dev tap0
#sudo ifconfig tap0 192.168.5.11/24 up
#sudo brctl addif virbr0 tap0

sudo chown $USER image.qcow2 initrd.img vmlinux
qemu-system-mipsel -machine malta -cpu 4KEc -m 1G -drive file=image.qcow2 -device e1000,netdev=net -netdev user,id=net,hostfwd=tcp::2222-:22 -kernel vmlinux -initrd initrd.img -nographic -append "root=LABEL=rootfs console=ttyS0"

scp -P 2222 rootfs.squashfs root@localhost:

