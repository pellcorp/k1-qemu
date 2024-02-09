sudo rm -rf ~/debinst
mkdir ~/debinst
sudo debootstrap --foreign --arch mipsel bookworm ~/debinst http://ftp.au.debian.org/debian/
# sudo pacman -S qemu-user-static
sudo cp /usr/bin/qemu-mipsel-static ~/debinst/usr/bin
sudo LC_CTYPE=en_US.UTF-8 LC_ALL=en_US.UTF-8 chroot ~/debinst/ qemu-mipsel-static /debootstrap/debootstrap --second-stage

ARCH="mipsel"
LINUX="linux-image-4kc-malta"
QEMU_ARCH="mipsel"
QEMU_MACHINE="malta"
QEMU_DISK="-drive file=image.qcow2"
QEMU_CPU="4KEc"
QEMU_NET_DEVICE="-device e1000,netdev=net"
CONSOLE="ttyS0"

    
DIR=~/debinst
# Install a simple fstab and set hostname
cp fstab "$DIR"/etc/fstab
echo "debian" > "$DIR"/etc/hostname

chroot "$DIR" apt-get update
chroot "$DIR" bash -c 'cat /var/lib/apt/lists/*_Packages  | grep '\''^\(Package\|Priority\): '\'' | grep -B 1 '\''^Priority: important'\'' | grep ^Package | cut -d'\'' '\'' -f2 | grep -v ^vim | grep -v ^isc-dhcp | xargs apt-get install -y --no-install-recommends'
chroot "$DIR" apt-get install -y --no-install-recommends openssh-server adduser update-initramfs file locales linux-image-4kc-malta squashfs-tools
chroot "$DIR" bash -c 'echo "LANG=en_US.UTF-8" > /etc/default/locale'
chroot "$DIR" locale-gen

# Create and set passwords for root and user debian
chroot "$DIR" /usr/sbin/adduser --gecos "Debian user,,," --disabled-password debian
echo "root:root" | chroot "$DIR" /usr/sbin/chpasswd
echo "debian:debian" | chroot "$DIR" /usr/sbin/chpasswd

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

chroot "$DIR" /usr/sbin/update-initramfs -k all -c

TARDISK="$DIR/image.tar.gz"
DISK="$DIR/image.qcow2"

LINUX_FILENAME="vmlinux"
INITRD_FILENAME="initrd.img"

ln -L "$DIR"/vmlinux "$DIR"/kernel
ln -L "$DIR"/initrd.img "$DIR"/initrd

virt-make-fs --format=qcow2 --size=10G --partition=gpt --type=ext4 --label=rootfs $DIR/ image.qcow2
qemu-img convert -f qcow2 image.qcow2 -O qcow2 image2.qcow2
mv image2.qcow2 image.qcow2
cp $DIR/kernel .
cp $DIR/initrd .
tar -zcvf qemu.tar.gz kernel initrd image.qcow2

