#!/bin/bash

sudo chown $USER image.qcow2 initrd.img vmlinux
qemu-system-mipsel -machine malta -cpu 4KEc -m 1G -drive file=image.qcow2 -device e1000,netdev=net -netdev user,id=net,hostfwd=tcp::2222-:22 -kernel vmlinux -initrd initrd.img -nographic -append "root=LABEL=rootfs console=ttyS0"

