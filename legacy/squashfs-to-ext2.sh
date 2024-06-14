#!/bin/bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd -P)"

pushd $CURRENT_DIR > /dev/null
rm -rf squashfs-root
rm rootfs.ext2

sudo unsquashfs rootfs.squashfs
rm squashfs-root/etc/init.d/S02mount_mmc_ext4
rm squashfs-root/etc/init.d/S03ubusd
rm squashfs-root/etc/init.d/S04device_manager
rm squashfs-root/etc/init.d/S05cpu_reg
rm squashfs-root/etc/init.d/S11jpeg_display_shell
rm squashfs-root/etc/init.d/S12boot_display
rm squashfs-root/etc/init.d/S13board_init
rm squashfs-root/etc/init.d/S41bt_bsa_download_firmware
rm squashfs-root/etc/init.d/S43wifi_bcm_init_config
rm squashfs-root/etc/init.d/S44wifi_bcm_up
rm squashfs-root/etc/init.d/S57klipper_mcu

chown -h -R 0:0 $CURRENT_DIR/squashfs-root
chown -h -R 100:101 $CURRENT_DIR/squashfs-root/run/dbus
/home/jason/Development/k1_buildroot/build_output/buildroot/qemu/host/bin/makedevs -d full_devices_table.txt $CURRENT_DIR/squashfs-root
rm -rf squashfs-root/usr/lib/udev/hwdb.d/ $CURRENT_DIR/squashfs-root/etc/udev/hwdb.d/
find squashfs-root/run/ -mindepth 1 -prune -print0 | xargs -0r rm -rf --
find squashfs-root/tmp/ -mindepth 1 -prune -print0 | xargs -0r rm -rf --
/home/jason/Development/k1_buildroot/build_output/buildroot/qemu/host/sbin/mkfs.ext2 -d $CURRENT_DIR/squashfs-root/ -r 1 -N 0 -m 5 -L "rootfs" -I 256 -O ^64bit rootfs.ext2 "1024M"

#sudo dd if=/dev/zero of="rootfs.ext2" bs=1M count=1024
#sudo mke2fs -t ext2 -d squashfs-root/ "rootfs.ext2"
rm -rf squashfs-root
popd > /dev/null