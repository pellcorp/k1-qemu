#!/bin/bash

echo "Chrooting to CrealityOS rootfs..."

mount -o bind /dev /root/rootfs/dev
mount -t proc /proc /root/rootfs/proc
mount -o bind /sys /root/rootfs/sys
mount -t devpts none /root/rootfs/dev/pts

# on the real k1, the /etc/resolv.conf points at /tmp/resolv.conf but we
# don't currently have the logic to override that
rm /root/rootfs/etc/resolv.conf
cp /etc/resolv.conf /root/rootfs/etc/resolv.conf

echo ""
echo "To fix the size of the console window, run: 'resize'"
echo "To setup default creality config files, run: '/etc/init.d/S55klipper_service start'"
echo ""

chroot /root/rootfs /bin/ash -l

