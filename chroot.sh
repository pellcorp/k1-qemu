#!/bin/bash

mount -t squashfs /root/squashfs-tools /mnt
cp -av /mnt/. /root/squashfs
umount /mnt
mount -o bind /dev /root/squashfs/dev
mount -t proc /proc /root/squashfs/proc
mount -o bind /sys /root/squashfs/sys
mount -t devpts none /root/squashfs/dev/pts

chroot squashfs/ /bin/ash

