# Why

Run mipsel qemu image so I can play around with creality firmware rootfs stuff

I found a blog which explained a few things to get me started, even though there were bugs:

https://boschko.ca/qemu-emulating-firmware/

Unfortunately the vmlinux-3.2.0-4-4kc-malta and debian_wheezy_mips_standard.qcow2 downloaded from https://people.debian.org/~aurel32/qemu/mipsel/ are too old!!!

# dqib

Found this project which builds new debian images of various things:

https://gitlab.com/giomasce/dqib

Unfortunately I am having some issues running it locally, as mipsel is no longer supported for debian-unstable, and the debian-stable suite seems
to stall out on the `chroot "$DIR"/chroot apt-get update` step.

Anyway, I found the very last mipsel build made which is available here:
https://gitlab.com/giomasce/dqib/-/jobs/4960385909

Useful info from here:
https://gitlab.com/giomasce/dqib/-/blob/d64002db448f4f3012183841cddbded6aed670d9/.gitlab-ci.yml

# Running the qemu image

## Network

#```
#sudo brctl addbr virbr0
#sudo ifconfig virbr0 192.168.5.1/24 up
# sudo ip tuntap del dev tap0 mode tap
#sudo ip tuntap add dev tap0 mode tap dev tap0
#sudo ifconfig tap0 192.168.5.11/24 up
#sudo brctl addif virbr0 tap0
#```

## Running it

#qemu-system-mips -M malta -kernel kernel -hda image.qcow2 -append "root=/dev/sda1" -netdev tap,id=tapnet,ifname=tap0,script=no -device rtl8139,netdev=tapnet -nographic

qemu-system-mipsel -machine malta -cpu 4KEc -m 1G -drive file=image.qcow2 -device e1000,netdev=net -netdev user,id=net,hostfwd=tcp::2222-:22 -kernel kernel -initrd initrd -nographic -append "root=LABEL=rootfs console=ttyS0"

## Copying k1 squashfs

scp -P 2222 rootfs.squashfs root@localhost:

Login as ssh and do:

mount -t squashfs /root/squashfs-tools /mnt
cp -av /mnt/. /root/squashfs
mount -o bind /dev /root/squashfs/dev
mount -t proc /proc /root/squashfs/proc
mount -o bind /sys /root/squashfs/sys
chroot squashfs/ /bin/ash
