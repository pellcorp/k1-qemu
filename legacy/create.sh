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

# recreate the rootfs
if [ ! -f $CURRENT_DIR/rootfs.squashfs ]; then
  if [ -z "$K1_FIRMWARE_PASSWORD" ]; then
      echo "Creality K1 firmware password not defined, did you forget to: "
      echo "export K1_FIRMWARE_PASSWORD='the password from a certain discord'"
      exit 1
  fi

  commands="7z unsquashfs mksquashfs"
  for command in $commands; do
      command -v "$command" > /dev/null
      if [ $? -ne 0 ]; then
          echo "Command $command not found"
          exit 1
      fi
  done

  download="https://github.com/pellcorp/downloads/raw/main/creality/k1/firmware/CR4CU220812S11_ota_img_V6.1.3.3.8.img"
  filename="CR4CU220812S11_ota_img_V6.1.3.3.8.img"
  directory="CR4CU220812S11_ota_img_V6.1.3.3.8"
  sub_directory="ota_v6.1.3.3.8"

  if [ ! -f /tmp/$filename ]; then
      echo "Downloading $download -> /tmp/$filename ..."
      wget "$download" -O /tmp/$filename || exit $?
  fi

  if [ -d /tmp/$directory ]; then
      rm -rf /tmp/$directory
  fi

  7z x /tmp/$filename -p"$K1_FIRMWARE_PASSWORD" -o/tmp || exit $?
  cat /tmp/$directory/$sub_directory/rootfs.squashfs.* > $CURRENT_DIR/rootfs.squashfs || exit $?
  rm -rf /tmp/$directory
fi

if [ -f vmlinux ]; then
  rm vmlinux 
fi
if [ -f initrd.img ]; then
  rm initrd.img
fi
if [ -f image.qcow2 ]; then
  rm image.qcow2
fi

LANG=en_US.UTF-8
LANGUAGE=en_US.UTF-8
LC_ALL=en_US.UTF-8

# this is because manjaro defines all these envs and causes issues!
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
chroot "$DIR" apt-get install -y --no-install-recommends sysvinit-core sysv-rc orphan-sysvinit-scripts systemctl procps vim-tiny net-tools xterm patchelf inetutils-ping ifupdown iproute2 isc-dhcp-client dropbear openssh-sftp-server file binutils
chroot "$DIR" apt-get install -y --no-install-recommends linux-image-4kc-malta

# do not start dropbear by default
rm "$DIR"/etc/rc3.d/S01dropbear

cp $CURRENT_DIR/inittab "$DIR"/etc/ || exit $?
cp $CURRENT_DIR/resolv.conf "$DIR"/etc
cp $CURRENT_DIR/interfaces "$DIR"/etc/network/ || exit $?
cp $CURRENT_DIR/systemd "$DIR"/etc/apt/preferences.d/

if [ -f $CURRENT_DIR/rootfs.squashfs ]; then
  echo "Extracting firmware rootfs.squashfs to $DIR/root/rootfs ..."
  mkdir -p "$DIR"/root/rootfs
  unsquashfs -d "$DIR"/root/rootfs $CURRENT_DIR/rootfs.squashfs
  cp $CURRENT_DIR/chroot.sh "$DIR"/root
  
  cp $CURRENT_DIR/get_sn_mac.sh "$DIR"/root/rootfs/usr/bin/

  cp $CURRENT_DIR/script "$DIR"/root/rootfs/root/script
  cp $CURRENT_DIR/script.sh "$DIR"/root/rootfs/root/script.sh
  
  # this allows sftp sessions to work and bypass chroot.sh
  echo '[[ $- == *i* ]] || return' >> "$DIR"/root/.bashrc

  # automatically chroot upon login
  echo "./chroot.sh" >> "$DIR"/root/.bashrc
else
  echo "rootfs.squashfs not found!"
fi

echo "Creating qemu drive image ..."
virt-make-fs --format=qcow2 --size=8G --partition=mbr --type=ext4 --label=rootfs $DIR/ image.qcow2 || exit $?
qemu-img convert -f qcow2 image.qcow2 -O qcow2 image2.qcow2 || exit $?
mv image2.qcow2 image.qcow2
cp $DIR/vmlinux .
cp $DIR/initrd.img .

echo "Creating qemu.tar.gz ..."
rm qemu.tar.gz
tar -zcvf qemu.tar.gz vmlinux initrd.img image.qcow2
