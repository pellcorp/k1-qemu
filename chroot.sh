#!/bin/bash

mount -t squashfs /root/rootfs.squashfs /mnt
mkdir -p /root/rootfs
cp -av /mnt/. /root/rootfs
umount /mnt
mount -o bind /dev /root/rootfs/dev
mount -t proc /proc /root/rootfs/proc
mount -o bind /sys /root/rootfs/sys
mount -t devpts none /root/rootfs/dev/pts

