#!/bin/bash

sudo mount -t squashfs ~/Downloads/rootfs.squashfs /mnt/squashfs
sudo virt-make-fs --format=qcow2 --size=8G --partition=mbr --type=ext4 --label=rootfs /mnt/squashfs/ /tmp/image.qcow2
qemu-img convert -f qcow2 /tmp/image.qcow2 -O qcow2 k1.qcow2
sudo rm /tmp/image.qcow2

