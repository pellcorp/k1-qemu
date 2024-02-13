#!/bin/bash

if [ "$(whoami)" != "root" ]; then
  echo "Must be run as root"
  exit 1
fi

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd -P)"

ls /proc/sys/fs/binfmt_misc/qemu-mipsel > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "The /proc/sys/fs/binfmt_misc/qemu-mipsel is missing, seems like you got work to do!"
  exit 1
fi

LANG=en_US.UTF-8
LANGUAGE=en_US.UTF-8
LC_ALL=en_US.UTF-8
unset LC_PAPER
unset LC_NUMERIC
unset LC_IDENTIFICATION
unset LC_MEASUREMENT
unset LC_NAME
unset LC_TELEPHONE
unset LC_ADDRESS
unset LC_MONETARY
unset LC_TIME

# FIXME - hard coded for now
DIR=/var/tmp/debinst

rm -rf $DIR
mkdir $DIR

# ,openssh-server,squashfs-tools,
echo "Creating base in $DIR ..."
debootstrap --foreign --arch mipsel --variant minbase --include=locales bookworm $DIR http://ftp.au.debian.org/debian/ || exit $?

echo "Finishing setup of base in $DIR ..."
cp /usr/bin/qemu-mipsel-static $DIR/usr/bin
LANG=C.UTF-8 chroot $DIR/ /debootstrap/debootstrap --second-stage || exit $?

# Install a simple fstab and set hostname
cp fstab "$DIR"/etc/fstab
echo "debian" > "$DIR"/etc/hostname

sed -i '/en_US.UTF-8/s/^# //;/en_US.UTF-8/s/^# //' "$DIR"/etc/locale.gen
LANG=C.UTF-8 chroot "$DIR" /usr/sbin/locale-gen
echo "LANG=en_US.UTF-8" > "$DIR"/etc/default/locale
echo "LANGUAGE=en_US.UTF-8" >> "$DIR"/etc/default/locale
echo "root:root" | chroot "$DIR" /usr/sbin/chpasswd

echo "Installing additional packages ..."
chroot "$DIR" apt-get update
chroot "$DIR" apt-get install -y --no-install-recommends dropbear systemd procps polkitd network-manager ifupdown iproute2 isc-dhcp-client squashfs-tools linux-image-4kc-malta

cp $CURRENT_DIR/resolv.conf "$DIR"/etc

# fixme - no idea why it loses the path this time!!!
chroot "$DIR" bash -c "PATH=/bin:/sbin:/usr/bin:/usr/sbin update-initramfs -k all -c" || exit $?

if [ -f $CURRENT_DIR/rootfs.squashfs ]; then
  mkdir -p "$DIR"/root/rootfs
  unsquashfs -d "$DIR"/root/rootfs $CURRENT_DIR/rootfs.squashfs
  cp $CURRENT_DIR/chroot.sh "$DIR"/root
else
  echo "rootfs.squashfs not found!"
fi

echo "Overriding some scripts ..."
cp $CURRENT_DIR/get_sn_mac.sh "$DIR"/usr/bin/
cp "$DIR"/sbin/reboot "$DIR"/sbin/reboot.old
cp "$DIR"/usr/bin/find "$DIR"/usr/bin/find.old
cp "$DIR"/bin/rm "$DIR"/bin/rm.old
cp $CURRENT_DIR/script "$DIR"/sbin/reboot
cp $CURRENT_DIR/script "$DIR"/bin/rm
cp $CURRENT_DIR/script "$DIR"/usr/bin/find

echo "Creating qemu drive image ..."
virt-make-fs --format=qcow2 --size=8G --partition=mbr --type=ext4 --label=rootfs $DIR/ image.qcow2 || exit $?
qemu-img convert -f qcow2 image.qcow2 -O qcow2 image2.qcow2 || exit $?
mv image2.qcow2 image.qcow2
cp $DIR/vmlinux .
cp $DIR/initrd.img .

#echo "Creating qemu.tar.gz ..."
#tar -zcvf qemu.tar.gz vmlinux initrd.img image.qcow2

