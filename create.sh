#!/bin/bash

if [ "$(whoami)" != "root" ]; then
  echo "Must be run as root"
  exit 1
fi

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
chroot "$DIR" apt-get install -y --no-install-recommends systemd procps polkitd network-manager ifupdown iproute2 isc-dhcp-client squashfs-tools linux-image-4kc-malta

mkdir -p "$DIR"/etc/network/
#echo "Setting up ssh ..."
#ln -s /dev/null "$DIR"/etc/systemd/network/99-default.link
#cp interfaces "$DIR"/etc/network/
cp resolv.conf "$DIR"/etc
#cp "$DIR"/usr/share/sysvinit/inittab "$DIR"/etc/inittab
#sed -i 's,^NO_START=1,NO_START=0,' /etc/default/dropbear

#cp keys/ssh_host_* "$DIR"/etc/ssh
#chmod 600 "$DIR"/etc/ssh/ssh_host_*_key
#echo 'PermitRootLogin yes' >> "$DIR"/etc/ssh/sshd_config
#mkdir -p "$DIR"/root/.ssh
#cat keys/ssh_user_*.pub > "$DIR"/root/.ssh/authorized_keys
#cp keys/ssh_user_*_key "$DIR"
cp chroot.sh "$DIR"/root
# fixme - no idea why it loses the path this time!!!
chroot "$DIR" bash -c "PATH=/bin:/sbin:/usr/bin:/usr/sbin update-initramfs -k all -c" || exit $?

echo "Creating qemu.tar.gz ..."

virt-make-fs --format=qcow2 --size=8G --partition=mbr --type=ext4 --label=rootfs $DIR/ image.qcow2 || exit $?
qemu-img convert -f qcow2 image.qcow2 -O qcow2 image2.qcow2 || exit $?
mv image2.qcow2 image.qcow2
cp $DIR/vmlinux .
cp $DIR/initrd.img .
#tar -zcvf qemu.tar.gz vmlinux initrd.img image.qcow2

