#!/bin/bash

# sudo pacman -S qemu-user-static

if [ "$(whoami)" != "root" ]; then
  echo "Must be run as root"
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

DIR=/home/jason/debinst

rm -rf $DIR
mkdir $DIR

echo "Creating base in $DIR ..."
debootstrap --foreign --arch mipsel --variant minbase bookworm $DIR http://ftp.au.debian.org/debian/ || exit $?

echo "Finishing setup of base in $DIR ..."
cp /usr/bin/qemu-mipsel-static $DIR/usr/bin
chroot $DIR/ /debootstrap/debootstrap --second-stage

echo "Installing additional packages ..."

# Install a simple fstab and set hostname
cp fstab "$DIR"/etc/fstab
echo "debian" > "$DIR"/etc/hostname

chroot "$DIR" apt-get update
chroot "$DIR" apt-get install -y --no-install-recommends locales
sed -i '/en_US.UTF-8/s/^# //;/en_US.UTF-8/s/^# //' "$DIR"/etc/locale.gen
chroot "$DIR" /usr/sbin/locale-gen
echo "LANG=en_US.UTF-8\nLANGUAGE=en_US.UTF-8" > "$DIR"/etc/default/locale
chroot "$DIR" apt-get install -y --no-install-recommends openssh-server adduser file squashfs-tools

echo "Installing kernel ..."
chroot "$DIR" apt-get install -y --no-install-recommends linux-image-4kc-malta

echo "Setting up debian user ..."
chroot "$DIR" /usr/sbin/adduser --gecos "Debian user,,," --disabled-password debian
echo "root:root" | chroot "$DIR" /usr/sbin/chpasswd
echo "debian:debian" | chroot "$DIR" /usr/sbin/chpasswd

echo "Setting up ssh ..."
ln -s /dev/null "$DIR"/etc/systemd/network/99-default.link
cp interfaces "$DIR"/etc/network/interfaces
cp resolv.conf "$DIR"/etc

cp keys/ssh_host_* "$DIR"/etc/ssh
chmod 600 "$DIR"/etc/ssh/ssh_host_*_key
echo 'PermitRootLogin yes' > "$DIR"/etc/ssh/sshd_config.d/permit_root.conf
mkdir -p "$DIR"/root/.ssh
mkdir -p "$DIR"/home/debian/.ssh
cat keys/ssh_user_*.pub > "$DIR"/root/.ssh/authorized_keys
cat keys/ssh_user_*.pub > "$DIR"/home/debian/.ssh/authorized_keys
chroot "$DIR" chown -Rc debian:debian /home/debian/.ssh
cp keys/ssh_user_*_key "$DIR"

ln -L "$DIR"/vmlinux "$DIR"/kernel
ln -L "$DIR"/initrd.img "$DIR"/initrd

echo "Creating qemu.tar.gz ..."

virt-make-fs --format=qcow2 --size=10G --partition=gpt --type=ext4 --label=rootfs $DIR/ image.qcow2
qemu-img convert -f qcow2 image.qcow2 -O qcow2 image2.qcow2
mv image2.qcow2 image.qcow2
cp $DIR/kernel .
cp $DIR/initrd .
tar -zcvf qemu.tar.gz kernel initrd image.qcow2

