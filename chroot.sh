#!/bin/bash

mount -o bind /dev /root/rootfs/dev
mount -t proc /proc /root/rootfs/proc
mount -o bind /sys /root/rootfs/sys
mount -t devpts none /root/rootfs/dev/pts
chroot /root/rootfs /bin/ash

